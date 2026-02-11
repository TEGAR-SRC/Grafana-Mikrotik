#!/bin/bash

echo "🔧 Quick Fix for Prometheus Permission Issues"

cd /root/Grafana-Mikrotik || exit 1

# Stop all services
echo "🛑 Stopping services..."
docker-compose down

# Clean up prometheus data directory
echo "🧹 Cleaning up Prometheus data..."
sudo rm -rf prometheus/data/*
sudo chown -R 65534:65534 prometheus/data/ 2>/dev/null || true
sudo chmod -R 755 prometheus/data/ 2>/dev/null || true

# Remove old networks
echo "🗑️ Removing old networks..."
docker network prune -f

# Start services
echo "🚀 Starting services..."
docker-compose up -d

# Wait for services
echo "⏳ Waiting for services to start..."
sleep 15

# Check status
echo "📊 Checking status..."
docker-compose ps

# Test connectivity
echo ""
echo "🔍 Testing connectivity..."
if docker exec mk_grafana ping -c 1 mk_prometheus >/dev/null 2>&1; then
    echo "✅ Grafana can reach Prometheus!"
else
    echo "❌ Still having network issues"
fi

echo ""
echo "🌐 Grafana: http://localhost:3000"
echo "📊 Prometheus: http://localhost:9090"
