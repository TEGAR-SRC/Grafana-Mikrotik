#!/bin/bash

# Grafana Mikrotik Update Script
# by TEGAR-SRC

echo "==================================="
echo "Grafana Mikrotik Update Script"
echo "==================================="

# Navigate to the correct directory
if [ -d "/root/Grafana-Mikrotik" ]; then
    cd /root/Grafana-Mikrotik
elif [ -d "~/Grafana-Mikrotik" ]; then
    cd ~/Grafana-Mikrotik
elif [ -d "Grafana-Mikrotik" ]; then
    cd Grafana-Mikrotik
else
    echo "❌ Grafana-Mikrotik directory not found!"
    exit 1
fi

echo "📁 Current directory: $(pwd)"

# Backup current configuration
echo "💾 Backing up current configuration..."
BACKUP_DIR="backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p $BACKUP_DIR
cp -r prometheus/prometheus.yml $BACKUP_DIR/ 2>/dev/null || true
cp -r snmp/snmp.yml $BACKUP_DIR/ 2>/dev/null || true
cp -r .grafana $BACKUP_DIR/ 2>/dev/null || true
cp -r .prometheus $BACKUP_DIR/ 2>/dev/null || true
echo "✅ Backup saved to: $BACKUP_DIR"

# Pull latest changes
echo "📥 Pulling latest updates from GitHub..."
git pull origin main

# Check if there are updates
if [ $? -eq 0 ]; then
    echo "✅ Repository updated successfully!"
    
    # Ask if user wants to restart services
    echo ""
    read -p "🔄 Do you want to restart services to apply updates? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🛑 Stopping services..."
        docker-compose down
        
        echo "🚀 Starting services..."
        docker-compose up -d
        
        echo "⏳ Waiting for services to start..."
        sleep 10
        
        echo "📊 Checking service status..."
        docker-compose ps
        
        echo ""
        echo "==================================="
        echo "✅ Update Complete!"
        echo "==================================="
        echo "🌐 Grafana: http://localhost:3000"
        echo "📈 Prometheus: http://localhost:9090"
        echo "🔌 SNMP Exporter: http://localhost:9116"
        echo "==================================="
    else
        echo "⚠️  Services not restarted. Restart manually with: docker-compose restart"
    fi
else
    echo "❌ Failed to update repository!"
    echo "🔄 Restoring backup..."
    cp -r $BACKUP_DIR/* . 2>/dev/null || true
fi

# Show current monitoring IPs
echo ""
echo "📡 Currently Monitoring:"
grep -E "^\s*-\s+[0-9]+\." prometheus/prometheus.yml | sed 's/^[[:space:]]*- /   - /' || echo "   No IPs found"
