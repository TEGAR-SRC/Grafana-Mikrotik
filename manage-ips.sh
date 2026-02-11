#!/bin/bash

# Grafana Mikrotik IP Management Script
# by TEGAR-SRC

echo "==================================="
echo "Grafana Mikrotik IP Management"
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

# Function to show current IPs
show_ips() {
    echo ""
    echo "📡 Currently Monitoring IPs:"
    grep -E "^\s*-\s+[0-9]+\." prometheus/prometheus.yml | sed 's/^[[:space:]]*- /   - /' || echo "   No IPs found"
    echo ""
}

# Function to add IP
add_ip() {
    echo "➕ Add new IP address"
    read -p "Enter IP address: " new_ip
    
    # Validate IP format
    if [[ $new_ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        # Check if IP already exists
        if grep -q "$new_ip" prometheus/prometheus.yml; then
            echo "⚠️  IP $new_ip already exists!"
        else
            # Add IP to prometheus.yml
            sed -i "/targets:/a\        - $new_ip # mikrotik_ip" prometheus/prometheus.yml
            # Add IP to .prometheus file
            current_ips=$(grep MIKROTIK_IP .prometheus | cut -d'=' -f2)
            if [ -z "$current_ips" ]; then
                echo "MIKROTIK_IP=$new_ip" > .prometheus
            else
                echo "MIKROTIK_IP=$current_ips,$new_ip" > .prometheus
            fi
            echo "✅ IP $new_ip added successfully!"
            
            # Ask to restart
            read -p "🔄 Restart services to apply changes? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                docker-compose restart prometheus snmp_exporter
                echo "✅ Services restarted!"
            fi
        fi
    else
        echo "❌ Invalid IP address format!"
    fi
}

# Function to remove IP
remove_ip() {
    echo "➖ Remove IP address"
    show_ips
    read -p "Enter IP address to remove: " remove_ip
    
    if grep -q "$remove_ip" prometheus/prometheus.yml; then
        # Remove IP from prometheus.yml
        sed -i "/$remove_ip/d" prometheus/prometheus.yml
        # Remove IP from .prometheus file
        current_ips=$(grep MIKROTIK_IP .prometheus | cut -d'=' -f2 | sed "s/$remove_ip//g" | sed 's/,,/,/g' | sed 's/^,//g' | sed 's/,$//g')
        echo "MIKROTIK_IP=$current_ips" > .prometheus
        echo "✅ IP $remove_ip removed successfully!"
        
        # Ask to restart
        read -p "🔄 Restart services to apply changes? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker-compose restart prometheus snmp_exporter
            echo "✅ Services restarted!"
        fi
    else
        echo "❌ IP $remove_ip not found!"
    fi
}

# Function to update SNMP community
update_snmp() {
    echo "🔐 Update SNMP Community"
    current_community=$(grep "community:" snmp/snmp.yml | awk '{print $2}')
    echo "Current community: $current_community"
    read -p "Enter new community string: " new_community
    
    if [ ! -z "$new_community" ]; then
        sed -i "s/community: .*/community: $new_community/" snmp/snmp.yml
        echo "✅ SNMP community updated to: $new_community"
        
        # Ask to restart
        read -p "🔄 Restart services to apply changes? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker-compose restart snmp_exporter prometheus
            echo "✅ Services restarted!"
        fi
    fi
}

# Function to update Grafana credentials
update_grafana() {
    echo "👤 Update Grafana Credentials"
    current_user=$(grep GF_SECURITY_ADMIN_USER .grafana | cut -d'=' -f2)
    echo "Current username: $current_user"
    read -p "Enter new username (leave blank to keep $current_user): " new_user
    
    if [ ! -z "$new_user" ]; then
        sed -i "s/GF_SECURITY_ADMIN_USER=.*/GF_SECURITY_ADMIN_USER=$new_user/" .grafana
        echo "✅ Username updated to: $new_user"
    fi
    
    read -p "Enter new password: " new_pass
    if [ ! -z "$new_pass" ]; then
        sed -i "s/GF_SECURITY_ADMIN_PASSWORD=.*/GF_SECURITY_ADMIN_PASSWORD=$new_pass/" .grafana
        echo "✅ Password updated!"
        
        # Ask to restart
        read -p "🔄 Restart Grafana to apply changes? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker-compose restart grafana
            echo "✅ Grafana restarted!"
        fi
    fi
}

# Main menu
while true; do
    show_ips
    echo "Options:"
    echo "1) Add IP"
    echo "2) Remove IP"
    echo "3) Update SNMP Community"
    echo "4) Update Grafana Credentials"
    echo "5) Exit"
    read -p "Choose option (1-5): " choice
    
    case $choice in
        1) add_ip ;;
        2) remove_ip ;;
        3) update_snmp ;;
        4) update_grafana ;;
        5) exit 0 ;;
        *) echo "❌ Invalid option!" ;;
    esac
done
