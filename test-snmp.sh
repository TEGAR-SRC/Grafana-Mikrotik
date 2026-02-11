#!/bin/bash

echo "🔍 SNMP Connection Test Script"
echo "=============================="

cd /root/Grafana-Mikrotik || exit 1

# IPs to test
IPS=("10.10.10.1" "172.16.1.1" "103.144.46.1" "103.144.46.18" "103.144.46.219")
COMMUNITY="xxkenxyz"

echo "Testing SNMP connectivity to Mikrotik devices..."
echo ""

# Test each IP
for ip in "${IPS[@]}"; do
    echo "📡 Testing $ip:"
    
    # Test if IP is reachable
    if ping -c 1 -W 2 $ip >/dev/null 2>&1; then
        echo "   ✅ Ping OK"
        
        # Test SNMP
        if command -v snmpwalk >/dev/null 2>&1; then
            if snmpwalk -v2c -c $COMMUNITY $ip 1.3.6.1.2.1.1.1.0 >/dev/null 2>&1; then
                echo "   ✅ SNMP OK"
                
                # Get system info
                sysname=$(snmpwalk -v2c -c $COMMUNITY $ip 1.3.6.1.2.1.1.5.0 2>/dev/null | cut -d'"' -f2)
                echo "   📛 Device: $sysname"
                
                # Get interfaces count
                ifcount=$(snmpwalk -v2c -c $COMMUNITY $ip 1.3.6.1.2.1.2.1.0 2>/dev/null | awk '{print $NF}')
                echo "   🔌 Interfaces: $ifcount"
                
            else
                echo "   ❌ SNMP FAILED - Check community string or SNMP service"
            fi
        else
            echo "   ⚠️  snmpwalk not installed, installing..."
            apt-get update >/dev/null 2>&1
            apt-get install -y snmp >/dev/null 2>&1
            
            if snmpwalk -v2c -c $COMMUNITY $ip 1.3.6.1.2.1.1.1.0 >/dev/null 2>&1; then
                echo "   ✅ SNMP OK (after installing snmp tools)"
            else
                echo "   ❌ SNMP FAILED"
            fi
        fi
    else
        echo "   ❌ Ping FAILED - Device not reachable"
    fi
    echo ""
done

echo "=============================="
echo "🔍 Checking SNMP Exporter Status..."

# Check if SNMP exporter is running
if docker ps | grep -q mk_snmp_exporter; then
    echo "✅ SNMP Exporter is running"
    
    # Test SNMP exporter
    echo ""
    echo "Testing SNMP Exporter endpoints:"
    for ip in "${IPS[@]}"; do
        echo "📡 Testing $ip through exporter:"
        if curl -s "http://localhost:9116/snmp?module=mikrotik&target=$ip" | grep -q "mikrotik"; then
            echo "   ✅ Exporter can connect to $ip"
        else
            echo "   ❌ Exporter failed to connect to $ip"
        fi
    done
else
    echo "❌ SNMP Exporter is not running!"
fi

echo ""
echo "=============================="
echo "📊 Prometheus Targets Check:"
curl -s http://localhost:9090/api/v1/targets | grep -o '"health":"[^"]*"' | sort | uniq -c

echo ""
echo "=============================="
echo "💡 If SNMP is failing, check on Mikrotik:"
echo "   /snmp set enabled=yes"
echo "   /snmp community add name=$COMMUNITY addresses=0.0.0.0/0"
