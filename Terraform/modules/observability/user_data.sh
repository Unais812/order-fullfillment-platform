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
    ports:
      - "9090:9090"

  loki:
    image: grafana/loki
    command: -config.file=/etc/loki/local-config.yaml
    ports:
      - "3100:3100"

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"

  cloudwatch-exporter:
    image: prom/cloudwatch-exporter
    ports:
      - "9106:9106"

EOF


cat <<EOF > prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:

  - job_name: cloudwatch
    static_configs:
      - targets: ['localhost:9106']

EOF


docker compose up -d