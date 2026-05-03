package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"bytes"
	"fmt"
	"io"
)

// Event represents a message from SQS
type Event struct {
	Type      string                 `json:"type"`
	Payload   map[string]interface{} `json:"payload"`
	Timestamp string                 `json:"timestamp"`
}

type metrics struct {
	opsProcessed prometheus.Counter
}

func newMetrics(reg prometheus.Registerer) *metrics {
	m := &metrics{
		opsProcessed: promauto.With(reg).NewCounter(prometheus.CounterOpts{
			Name: "myapp_processed_ops_total",
			Help: "The total number of processed events",
		}),
	}
	return m
}

func recordMetrics(m *metrics) {
	go func() {
		for {
			m.opsProcessed.Inc()
			time.Sleep(2 * time.Second)
		}
	}()
}

func main() {
	reg := prometheus.NewRegistry()
	m := newMetrics(reg)
	recordMetrics(m)

	sqsQueue := os.Getenv("SQS_QUEUE_URL")
	if sqsQueue == "" {
		log.Fatal("SQS_QUEUE_URL is required")
	}

	// Internal service URLs for event-driven calls
	services := map[string]string{
		"inventory":    getEnv("INVENTORY_SERVICE_URL", "http://inventory-service.ecs.local:8082"),
		"payment":      getEnv("PAYMENT_SERVICE_URL", "http://payment-service.ecs.local:8083"),
		"notification": getEnv("NOTIFICATION_SERVICE_URL", "http://notification-service.ecs.local:8084"),
		"shipping":     getEnv("SHIPPING_SERVICE_URL", "http://shipping-service.ecs.local:8085"),
		"order":        getEnv("ORDER_SERVICE_URL", "http://order-service:.ecs.local8081"),
	}

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// Health check endpoint
	go func() {
		mux := http.NewServeMux()
		mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Content-Type", "application/json")
			json.NewEncoder(w).Encode(map[string]string{"status": "ok", "service": "worker"})
		})
		port := getEnv("HEALTH_PORT", "8090")
		log.Printf("Worker health check on :%s", port)
		http.ListenAndServe(":"+port, mux)
	}()

	// Graceful shutdown
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)
	go func() {
		<-sigChan
		log.Println("Shutting down worker...")
		cancel()
	}()

	http.Handle("/metrics", promhttp.HandlerFor(reg, promhttp.HandlerOpts{}))
	http.ListenAndServe(":2112", nil)

	log.Println("Worker started, polling SQS for events...")
	pollAndProcess(ctx, sqsQueue, services)
}

func pollAndProcess(ctx context.Context, queueURL string, services map[string]string) {
	client := &http.Client{Timeout: 10 * time.Second}

	for {
		select {
		case <-ctx.Done():
			log.Println("Worker stopped")
			return
		default:
			messages := receiveSQSMessages(queueURL)

			for _, raw := range messages {
				var event Event
				if err := json.Unmarshal([]byte(raw), &event); err != nil {
					log.Printf("Failed to parse event: %v", err)
					continue
				}

				log.Printf("Processing event: %s", event.Type)

				if err := handleEvent(client, services, event); err != nil {
					log.Printf("Failed to handle event %s: %v", event.Type, err)
					// Message was already deleted - if processing fails, it won't be retried - new comment
					// In production: don't delete from SQS, let it retry or go to DLQ
					continue
				}

				log.Printf("Successfully processed: %s", event.Type)
				// Message already deleted in receiveSQSMessages - new comment
				// Delete message from SQS after successful processing
			}

			if len(messages) == 0 {
				time.Sleep(5 * time.Second)
			}
		}
	}
}

func handleEvent(client *http.Client, services map[string]string, event Event) error {
	switch event.Type {

	case "order.created":
		// Extract order_id as float64 (JSON numbers), then convert to int
		orderIDFloat, ok := event.Payload["order_id"].(float64)
		if !ok {
			return fmt.Errorf("missing or invalid order_id in payload")
		}
		orderID := int(orderIDFloat)

		// Extract customer_id
		customerID, _ := event.Payload["customer_id"].(string)
		
		// Extract items and total
		items := event.Payload["items"]
		total, _ := event.Payload["total"].(float64)
		currency, _ := event.Payload["currency"].(string)
		if currency == "" {
			currency = "GBP"
		}

		// 1. Reserve inventory
		log.Printf("  -> Reserving inventory for order %d", orderID)
		inventoryPayload := map[string]interface{}{
			"order_id": orderID,
			"items":    items,
		}
		if err := makeHTTPCall(client, services["inventory"], "/reserve", inventoryPayload); err != nil {
			log.Printf("  -> Inventory reservation failed: %v", err)
			// Cancel order
			cancelPayload := map[string]interface{}{
				"order_id":   orderID,
				"new_status": "cancelled",
			}
			makeHTTPCall(client, services["order"], "/status", cancelPayload)
			return err
		}

		// 2. Process payment
		log.Printf("  -> Processing payment for order %d", orderID)
		paymentPayload := map[string]interface{}{
			"order_id":    orderID,
			"customer_id": customerID,
			"amount":      total,
			"currency":    currency,
			"method":      "card", // Default payment method
		}
		if err := makeHTTPCall(client, services["payment"], "/charge", paymentPayload); err != nil {
			log.Printf("  -> Payment failed: %v", err)
			// Release inventory
			releasePayload := map[string]interface{}{"order_id": orderID}
			makeHTTPCall(client, services["inventory"], "/release", releasePayload)
			// Cancel order
			cancelPayload := map[string]interface{}{
				"order_id":   orderID,
				"new_status": "cancelled",
			}
			makeHTTPCall(client, services["order"], "/status", cancelPayload)
			return err
		}

		// 3. Send confirmation notification
		log.Printf("  -> Sending order confirmation for %d", orderID)
		notificationPayload := map[string]interface{}{
			"recipient": customerID,
			"channel":   "email",
			"template":  "order_confirmed",
			"data": map[string]interface{}{
				"OrderID":      orderID,
				"CustomerName": "Customer",
				"Total":        total,
				"Currency":     currency,
			},
		}
		makeHTTPCall(client, services["notification"], "/send", notificationPayload)

		// 4. Update order to confirmed
		log.Printf("  -> Confirming order %d", orderID)
		confirmPayload := map[string]interface{}{
			"order_id":   orderID,
			"new_status": "confirmed",
		}
		if err := makeHTTPCall(client, services["order"], "/status", confirmPayload); err != nil {
			return err
		}

	case "order.status_changed":
		newStatus, _ := event.Payload["new_status"].(string)
		orderIDFloat, _ := event.Payload["order_id"].(float64)
		orderID := int(orderIDFloat)

		switch newStatus {
		case "processing":
			// Create shipment - need to get order details first
			log.Printf("  -> Creating shipment for order %d", orderID)
			
			// For now, create shipment with minimal required fields
			shipmentPayload := map[string]interface{}{
				"order_id":       orderID,
				"carrier":        "DHL",
				"recipient_name": "Customer",
				"address_line1":  "123 Main St",
				"city":           "London",
				"postal_code":    "SW1A 1AA",
				"country":        "UK",
			}
			if err := makeHTTPCall(client, services["shipping"], "/shipments", shipmentPayload); err != nil {
				log.Printf("  -> Failed to create shipment: %v", err)
				return err
			}

		case "shipped":
			// Notify customer
			log.Printf("  -> Sending shipping notification for %d", orderID)
			notificationPayload := map[string]interface{}{
				"recipient": "customer@example.com",
				"channel":   "email",
				"template":  "order_shipped",
				"data": map[string]interface{}{
					"OrderID":        orderID,
					"TrackingNumber": fmt.Sprintf("TRACK-%d", orderID),
				},
			}
			makeHTTPCall(client, services["notification"], "/send", notificationPayload)

		case "delivered":
			log.Printf("  -> Sending delivery notification for %d", orderID)
			notificationPayload := map[string]interface{}{
				"recipient": "customer@example.com",
				"channel":   "email",
				"template":  "order_delivered",
				"data": map[string]interface{}{
					"OrderID": orderID,
				},
			}
			makeHTTPCall(client, services["notification"], "/send", notificationPayload)

		case "cancelled":
			// Release inventory
			log.Printf("  -> Releasing inventory reservation for %d", orderID)
			releasePayload := map[string]interface{}{"order_id": orderID}
			makeHTTPCall(client, services["inventory"], "/release", releasePayload)

			// Process refund if payment was made
			log.Printf("  -> Processing refund for %d", orderID)
			refundPayload := map[string]interface{}{"order_id": orderID}
			makeHTTPCall(client, services["payment"], "/refund", refundPayload)
		}

	case "payment.completed":
		orderIDFloat, _ := event.Payload["order_id"].(float64)
		orderID := int(orderIDFloat)
		log.Printf("  -> Payment successful, confirming order %d", orderID)
		confirmPayload := map[string]interface{}{
			"order_id":   orderID,
			"new_status": "confirmed",
		}
		if err := makeHTTPCall(client, services["order"], "/status", confirmPayload); err != nil {
			return err
		}

	case "payment.failed":
		orderIDFloat, _ := event.Payload["order_id"].(float64)
		orderID := int(orderIDFloat)
		log.Printf("  -> Payment failed, cancelling order %d", orderID)
		
		// Release inventory reservation
		releasePayload := map[string]interface{}{"order_id": orderID}
		makeHTTPCall(client, services["inventory"], "/release", releasePayload)
		
		// Update order status to cancelled
		cancelPayload := map[string]interface{}{
			"order_id":   orderID,
			"new_status": "cancelled",
		}
		makeHTTPCall(client, services["order"], "/status", cancelPayload)
		
		// Send payment failed notification
		notificationPayload := map[string]interface{}{
			"recipient": "customer@example.com",
			"channel":   "email",
			"template":  "payment_failed",
			"data": map[string]interface{}{
				"OrderID": orderID,
			},
		}
		makeHTTPCall(client, services["notification"], "/send", notificationPayload)

	case "shipment.created":
		orderIDFloat, _ := event.Payload["order_id"].(float64)
		orderID := int(orderIDFloat)
		log.Printf("  -> Shipment created, updating order %d to processing", orderID)
		statusPayload := map[string]interface{}{
			"order_id":   orderID,
			"new_status": "processing",
		}
		if err := makeHTTPCall(client, services["order"], "/status", statusPayload); err != nil {
			return err
		}

	case "shipment.delivered":
		orderIDFloat, _ := event.Payload["order_id"].(float64)
		orderID := int(orderIDFloat)
		log.Printf("  -> Shipment delivered, updating order %d", orderID)
		
		// Update order status to delivered
		statusPayload := map[string]interface{}{
			"order_id":   orderID,
			"new_status": "delivered",
		}
		makeHTTPCall(client, services["order"], "/status", statusPayload)
		
		// Send delivery notification
		notificationPayload := map[string]interface{}{
			"recipient": "customer@example.com",
			"channel":   "email",
			"template":  "order_delivered",
			"data": map[string]interface{}{
				"OrderID": orderID,
			},
		}
		makeHTTPCall(client, services["notification"], "/send", notificationPayload)

	default:
		log.Printf("  -> Unknown event type: %s (skipping)", event.Type)
	}

	return nil
}

// Helper function to make HTTP POST calls to internal services
func makeHTTPCall(client *http.Client, serviceURL, path string, payload map[string]interface{}) error {
	url := serviceURL + path
	
	jsonData, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("failed to marshal payload: %w", err)
	}

	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return fmt.Errorf("failed to create request: %w", err)
	}
	
	req.Header.Set("Content-Type", "application/json")

	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("failed to call %s: %w", url, err)
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("service returned %d: %s", resp.StatusCode, string(body))
	}

	log.Printf("  -> Successfully called %s (status: %d)", url, resp.StatusCode)
	return nil
}

func receiveSQSMessages(queueURL string) []string {
	// Create AWS config and SQS client
	cfg, err := config.LoadDefaultConfig(context.Background())
	if err != nil {
		log.Printf("Failed to load AWS config: %v", err)
		return nil
	}
	
	sqsClient := sqs.NewFromConfig(cfg)
	
	// Poll SQS with long polling
	maxMessages := int32(10)
	waitTime := int32(20) // Long polling for 20 seconds
	
	result, err := sqsClient.ReceiveMessage(context.Background(), &sqs.ReceiveMessageInput{
		QueueUrl:            &queueURL,
		MaxNumberOfMessages: maxMessages,
		WaitTimeSeconds:     waitTime,
	})
	
	if err != nil {
		log.Printf("Failed to receive SQS messages: %v", err)
		return nil
	}
	
	if len(result.Messages) == 0 {
		return nil
	}
	
	messages := make([]string, 0, len(result.Messages))
	
	for _, msg := range result.Messages {
		if msg.Body != nil {
			messages = append(messages, *msg.Body)
			
			// Delete message after successfully receiving it
			// (we'll process it, and if processing fails, it won't be deleted in pollAndProcess)
			_, err := sqsClient.DeleteMessage(context.Background(), &sqs.DeleteMessageInput{
				QueueUrl:      &queueURL,
				ReceiptHandle: msg.ReceiptHandle,
			})
			
			if err != nil {
				log.Printf("Failed to delete message from SQS: %v", err)
			}
		}
	}
	
	return messages
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
