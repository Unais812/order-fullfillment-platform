#!/bin/bash

apt update -y
apt install -y docker.io docker-compose git

systemctl enable docker
systemctl start docker

mkdir -p /opt/observability
cd /opt/observability

cat <<EOF > docker-compose.yml

version: "3"

services:

  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    ports:
      - "9090:9090"
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=30d'

  grafana:
    image: grafana/grafana
    volumes:
      - grafana-data:/var/lib/grafana
      - ./grafana-datasources.yml:/etc/grafana/provisioning/datasources/datasources.yml
    ports:
      - "3000:3000"
volumes:  
  prometheus-data:
  grafana-data:

EOF



cat <<'EOF' > prometheus.yml

global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'api-gateway'
    static_configs:
      - targets: ['api-gateway.ecs.internal:8080']

  - job_name: 'order-service'
    static_configs:
      - targets: ['order-service.ecs.internal:8081']

  - job_name: 'payment-service'
    static_configs:
      - targets: ['payment-service.ecs.internal:8083']

  - job_name: 'inventory-service'
    static_configs:
      - targets: ['inventory-service.ecs.internal:8082']

  - job_name: 'notification-service'
    static_configs:
      - targets: ['notification-service.ecs.internal:8084']

  - job_name: 'shipping-service'
    static_configs:
      - targets: ['shipping-service.ecs.internal:8085']

  - job_name: 'dashboard-api'
    static_configs:
      - targets: ['dashboard-api.ecs.internal:8086']
  
      
EOF

cat <<EOF > grafana-datasources.yml

apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    
  - name: CloudWatch
    type: cloudwatch
    access: proxy
    isDefault: true
    editable: true

    jsonData:
      authType: default
      defaultRegion: eu-north-1
      assumeRoleArn: ""
      customMetricsNamespaces: ""
EOF

cd /opt/observability

sudo docker-compose up -d

echo "Observability stack started successfully!"