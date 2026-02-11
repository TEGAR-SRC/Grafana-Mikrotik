#!/bin/bash

# Grafana Mikrotik Quick Installer
# by TEGAR-SRC

echo "==================================="
echo "Grafana Mikrotik Quick Installer"
echo "==================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "Docker installed. Please logout and login again, then run this script again."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Clone the repository
echo "Cloning Grafana Mikrotik repository..."
git clone https://github.com/TEGAR-SRC/Grafana-Mikrotik.git
cd Grafana-Mikrotik

# Create necessary directories
echo "Setting up directories..."
mkdir -p prometheus/data
mkdir -p grafana/provisioning/dashboards
mkdir -p grafana/provisioning/datasources

# Set permissions
echo "Setting permissions..."
sudo chown -R $USER:$USER prometheus/data
sudo chmod -R 755 prometheus/data

# Start services
echo "Starting Grafana and Prometheus..."
docker-compose up -d

echo ""
echo "==================================="
echo "Installation Complete!"
echo "==================================="
echo "Grafana Dashboard: http://localhost:3000"
echo "Username: xxken"
echo "Password: xxkenxyz"
echo ""
echo "Prometheus: http://localhost:9090"
echo ""
echo "SNMP Exporter: http://localhost:9116"
echo ""
echo "Monitoring IPs:"
echo "- 10.10.10.1"
echo "- 172.16.1.1"
echo "- 103.144.46.1"
echo "- 103.144.46.18"
echo "- 103.144.46.219"
echo ""
echo "To stop services: docker-compose down"
echo "To restart: docker-compose restart"
echo "==================================="
