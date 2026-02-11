#!/bin/bash

echo "🔧 Fixing Grafana-Mikrotik network issues..."

# Navigate to the correct directory
if [ -d "/root/Grafana-Mikrotik" ]; then
    cd /root/Grafana-Mikrotik
elif [ -d "~/Grafana-Mikrotik" ]; then
    cd ~/Grafana-Mikrotik
else
    echo "❌ Grafana-Mikrotik directory not found!"
    echo "Please run this from the correct directory or clone the repository first."
    exit 1
fi

echo "📁 Current directory: $(pwd)"

# Stop all services
echo "🛑 Stopping services..."
docker-compose down

# Remove containers and networks
echo "🧹 Cleaning up containers and networks..."
docker-compose down --remove-orphans
docker network prune -f

# Start services again
echo "🚀 Starting services with new network configuration..."
docker-compose up -d

# Wait for services to start
echo "⏳ Waiting for services to initialize..."
sleep 20

# Check container status
echo "📊 Checking container status..."
docker-compose ps

# Check if services are healthy
echo "🔍 Checking service health..."
echo ""
echo "Prometheus health check:"
curl -s http://localhost:9090/api/v1/targets | head -c 200
echo ""
echo ""
echo "Grafana health check:"
curl -s http://localhost:3000/api/health | head -c 100
echo ""

# Check network connectivity between containers
echo "� Checking container network connectivity..."
if docker exec mk_grafana ping -c 1 mk_prometheus >/dev/null 2>&1; then
    echo "✅ Grafana can reach Prometheus"
else
    echo "❌ Grafana cannot reach Prometheus"
fi

# Show recent logs
echo ""
echo "📝 Recent logs:"
echo "=== Prometheus ==="
docker-compose logs --tail=10 prometheus
echo ""
echo "=== Grafana ==="
docker-compose logs --tail=10 grafana

echo ""
echo "==================================="
echo "✅ Fix complete!"
echo "🌐 Access Grafana: http://localhost:3000"
echo "📊 Access Prometheus: http://localhost:9090"
echo "==================================="
