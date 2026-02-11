#!/bin/bash

echo "🔍 Quick SNMP Test for CORE-BGP"
echo "==============================="

IP="103.144.46.219"
COMMUNITY="xxkenxyz"

echo "Testing SNMP on $IP..."
echo ""

# Test ping
if ping -c 1 -W 2 $IP >/dev/null 2>&1; then
    echo "✅ Ping OK"
else
    echo "❌ Ping FAILED"
    exit 1
fi

# Install snmp tools if not present
if ! command -v snmpwalk >/dev/null 2>&1; then
    echo "📦 Installing SNMP tools..."
    apt-get update >/dev/null 2>&1
    apt-get install -y snmp snmp-tools >/dev/null 2>&1
fi

# Test SNMP
echo ""
echo "🔌 Testing SNMP connection..."
if snmpwalk -v2c -c $COMMUNITY $IP 1.3.6.1.2.1.1.1.0 >/dev/null 2>&1; then
    echo "✅ SNMP Connection OK"
    
    # Get device info
    echo ""
    echo "📛 Device Information:"
    sysname=$(snmpwalk -v2c -c $COMMUNITY $IP 1.3.6.1.2.1.1.5.0 2>/dev/null | cut -d'"' -f2)
    echo "   System Name: $sysname"
    
    sysdesc=$(snmpwalk -v2c -c $COMMUNITY $IP 1.3.6.1.2.1.1.1.0 2>/dev/null | cut -d'"' -f2)
    echo "   Description: $sysdesc"
    
    # Get interfaces
    echo ""
    echo "🔌 Network Interfaces:"
    snmpwalk -v2c -c $COMMUNITY $IP 1.3.6.1.2.1.2.2.1.2 2>/dev/null | while read line; do
        ifnum=$(echo $line | cut -d'.' -f10 | cut -d' ' -f1)
        ifname=$(echo $line | cut -d'"' -f2)
        ifstatus=$(snmpwalk -v2c -c $COMMUNITY $IP 1.3.6.1.2.1.2.2.1.8.$ifnum 2>/dev/null | awk '{print $NF}')
        
        if [ "$ifstatus" = "1" ]; then
            status="UP"
        else
            status="DOWN"
        fi
        
        echo "   Interface $ifnum: $ifname ($status)"
    done
    
    # Test through SNMP exporter
    echo ""
    echo "🔍 Testing through SNMP Exporter..."
    if curl -s "http://localhost:9116/snmp?module=mikrotik&target=$IP" | grep -q "ifNumber"; then
        echo "✅ SNMP Exporter can connect!"
    else
        echo "❌ SNMP Exporter failed"
    fi
    
else
    echo "❌ SNMP FAILED - Check community string or firewall"
    echo ""
    echo "💡 Debugging tips:"
    echo "   1. Verify community: /snmp community print"
    echo "   2. Check firewall: /ip firewall filter print"
    echo "   3. Try from Mikrotik itself: /tool snmp-get address=127.0.0.1 oid=.1.3.6.1.2.1.1.1.0"
fi

echo ""
echo "==============================="
