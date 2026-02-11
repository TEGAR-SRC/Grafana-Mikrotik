#!/bin/bash

# Grafana Mikrotik Quick Installer
# by TEGAR-SRC

echo "==================================="
echo "Grafana Mikrotik Quick Installer"
echo "==================================="

# Check OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    MSYS*)      MACHINE=MSys;;
    *)          MACHINE="UNKNOWN:${OS}"
esac

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed."
    echo "📦 Installing Docker..."
    
    if [[ "$MACHINE" == "Linux" ]]; then
        # For Ubuntu/Debian
        if command -v apt-get &> /dev/null; then
            echo "Installing Docker on Ubuntu/Debian..."
            sudo apt-get update
            sudo apt-get install -y ca-certificates curl gnupg lsb-release
            sudo mkdir -p /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt-get update
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        # For CentOS/RHEL/Fedora
        elif command -v yum &> /dev/null; then
            echo "Installing Docker on CentOS/RHEL..."
            sudo yum install -y yum-utils
            sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        else
            echo "❌ Unsupported Linux distribution. Please install Docker manually."
            exit 1
        fi
        
        # Start and enable Docker
        sudo systemctl start docker
        sudo systemctl enable docker
        sudo usermod -aG docker $USER
        
    elif [[ "$MACHINE" == "Mac" ]]; then
        echo "Please install Docker Desktop for Mac from: https://www.docker.com/products/docker-desktop"
        echo "After installation, run this script again."
        exit 1
    else
        echo "❌ Please install Docker manually for your OS: https://www.docker.com/get-started"
        exit 1
    fi
    
    echo "✅ Docker installed successfully!"
    echo "⚠️  Please logout and login again, then run this script again."
    exit 0
fi

echo "✅ Docker is already installed!"

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed."
    echo "📦 Installing Docker Compose..."
    
    if [[ "$MACHINE" == "Linux" ]]; then
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    else
        echo "❌ Please install Docker Compose manually"
        exit 1
    fi
    
    echo "✅ Docker Compose installed!"
else
    echo "✅ Docker Compose is already installed!"
fi

# Clone the repository
if [ ! -d "Grafana-Mikrotik" ]; then
    echo "📥 Cloning Grafana Mikrotik repository..."
    git clone https://github.com/TEGAR-SRC/Grafana-Mikrotik.git
    cd Grafana-Mikrotik
else
    echo "📁 Grafana-Mikrotik directory already exists, updating..."
    cd Grafana-Mikrotik
    git pull origin main
fi

# Create necessary directories
echo "📁 Setting up directories..."
mkdir -p prometheus/data
mkdir -p grafana/provisioning/dashboards
mkdir -p grafana/provisioning/datasources

# Set permissions
echo "🔐 Setting permissions..."
sudo chown -R $USER:$USER prometheus/data 2>/dev/null || true
chmod -R 755 prometheus/data 2>/dev/null || true

# Stop existing containers if running
echo "🛑 Stopping existing containers (if any)..."
docker-compose down 2>/dev/null || true

# Start services
echo "🚀 Starting Grafana and Prometheus..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 10

# Check if services are running
echo "🔍 Checking service status..."
if docker-compose ps | grep -q "Up"; then
    echo ""
    echo "==================================="
    echo "✅ Installation Complete!"
    echo "==================================="
    echo "📊 Grafana Dashboard: http://localhost:3000"
    echo "📈 Prometheus: http://localhost:9090"
    echo "🔌 SNMP Exporter: http://localhost:9116"
    echo ""
    echo "📡 Monitoring IPs:"
    echo "   - 10.10.10.1"
    echo "   - 172.16.1.1"
    echo "   - 103.144.46.1"
    echo "   - 103.144.46.18"
    echo "   - 103.144.46.219"
    echo ""
    echo "🔧 Commands:"
    echo "   Stop services: docker-compose down"
    echo "   Restart: docker-compose restart"
    echo "   View logs: docker-compose logs -f"
    echo "==================================="
else
    echo ""
    echo "❌ Error: Some services failed to start!"
    echo "📝 Check logs with: docker-compose logs"
fi
