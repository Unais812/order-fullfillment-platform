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

func main() {
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
		orderID, ok := event.Payload["order_id"].(string)
		if !ok {
			return fmt.Errorf("missing order_id in payload")
		}

		// 1. Reserve inventory
		log.Printf("  -> Reserving inventory for order %s", orderID)
		inventoryPayload := map[string]interface{}{
			"order_id": orderID,
			"items":    event.Payload["items"],
		}
		if err := makeHTTPCall(client, services["inventory"], "/reserve", inventoryPayload); err != nil {
			log.Printf("  -> Inventory reservation failed: %v", err)
			// Cancel order
			cancelPayload := map[string]interface{}{"order_id": orderID, "new_status": "cancelled"}
			makeHTTPCall(client, services["order"], "/status", cancelPayload)
			return err
		}

		// 2. Process payment
		log.Printf("  -> Processing payment for order %s", orderID)
		paymentPayload := map[string]interface{}{
			"order_id": orderID,
			"amount":   event.Payload["total"],
		}
		if err := makeHTTPCall(client, services["payment"], "/charge", paymentPayload); err != nil {
			log.Printf("  -> Payment failed: %v", err)
			// Release inventory
			releasePayload := map[string]interface{}{"order_id": orderID}
			makeHTTPCall(client, services["inventory"], "/release", releasePayload)
			// Cancel order
			cancelPayload := map[string]interface{}{"order_id": orderID, "new_status": "cancelled"}
			makeHTTPCall(client, services["order"], "/status", cancelPayload)
			return err
		}

		// 3. Send confirmation notification
		log.Printf("  -> Sending order confirmation for %s", orderID)
		notificationPayload := map[string]interface{}{
			"template": "order_confirmed",
			"order_id": orderID,
			"email":    event.Payload["customer_email"],
		}
		makeHTTPCall(client, services["notification"], "/send", notificationPayload)

		// 4. Update order to confirmed
		log.Printf("  -> Confirming order %s", orderID)
		confirmPayload := map[string]interface{}{"order_id": orderID, "new_status": "confirmed"}
		if err := makeHTTPCall(client, services["order"], "/status", confirmPayload); err != nil {
			return err
		}

	case "order.status_changed":
		newStatus, _ := event.Payload["new_status"].(string)
		orderID, _ := event.Payload["order_id"].(string)

		switch newStatus {
		case "processing":
			// Create shipment
			log.Printf("  -> Creating shipment for order %s", orderID)
			shipmentPayload := map[string]interface{}{
				"order_id": orderID,
				"address":  event.Payload["shipping_address"],
			}
			if err := makeHTTPCall(client, services["shipping"], "/shipments", shipmentPayload); err != nil {
				return err
			}

		case "shipped":
			// Notify customer
			log.Printf("  -> Sending shipping notification for %s", orderID)
			notificationPayload := map[string]interface{}{
				"template":     "order_shipped",
				"order_id":     orderID,
				"email":        event.Payload["customer_email"],
				"tracking_url": event.Payload["tracking_url"],
			}
			makeHTTPCall(client, services["notification"], "/send", notificationPayload)

		case "delivered":
			log.Printf("  -> Sending delivery notification for %s", orderID)
			notificationPayload := map[string]interface{}{
				"template": "order_delivered",
				"order_id": orderID,
				"email":    event.Payload["customer_email"],
			}
			makeHTTPCall(client, services["notification"], "/send", notificationPayload)

		case "cancelled":
			// Release inventory
			log.Printf("  -> Releasing inventory reservation for %s", orderID)
			releasePayload := map[string]interface{}{"order_id": orderID}
			makeHTTPCall(client, services["inventory"], "/release", releasePayload)

			// Process refund if payment was made
			log.Printf("  -> Processing refund for %s", orderID)
			refundPayload := map[string]interface{}{"order_id": orderID}
			makeHTTPCall(client, services["payment"], "/refund", refundPayload)
		}

	case "payment.completed":
		orderID, _ := event.Payload["order_id"].(string)
		log.Printf("  -> Payment successful, confirming order %s", orderID)
		confirmPayload := map[string]interface{}{"order_id": orderID, "new_status": "confirmed"}
		if err := makeHTTPCall(client, services["order"], "/status", confirmPayload); err != nil {
			return err
		}

	case "payment.failed":
		orderID, _ := event.Payload["order_id"].(string)
		log.Printf("  -> Payment failed, cancelling order %s", orderID)
		
		// Release inventory reservation
		releasePayload := map[string]interface{}{"order_id": orderID}
		makeHTTPCall(client, services["inventory"], "/release", releasePayload)
		
		// Update order status to cancelled
		cancelPayload := map[string]interface{}{"order_id": orderID, "new_status": "cancelled"}
		makeHTTPCall(client, services["order"], "/status", cancelPayload)
		
		// Send payment failed notification
		notificationPayload := map[string]interface{}{
			"template": "payment_failed",
			"order_id": orderID,
			"email":    event.Payload["customer_email"],
		}
		makeHTTPCall(client, services["notification"], "/send", notificationPayload)

	case "shipment.created":
		orderID, _ := event.Payload["order_id"].(string)
		log.Printf("  -> Shipment created, updating order %s to processing", orderID)
		statusPayload := map[string]interface{}{"order_id": orderID, "new_status": "processing"}
		if err := makeHTTPCall(client, services["order"], "/status", statusPayload); err != nil {
			return err
		}

	case "shipment.delivered":
		orderID, _ := event.Payload["order_id"].(string)
		log.Printf("  -> Shipment delivered, updating order %s", orderID)
		
		// Update order status to delivered
		statusPayload := map[string]interface{}{"order_id": orderID, "new_status": "delivered"}
		makeHTTPCall(client, services["order"], "/status", statusPayload)
		
		// Send delivery notification
		notificationPayload := map[string]interface{}{
			"template": "order_delivered",
			"order_id": orderID,
			"email":    event.Payload["customer_email"],
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
