#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CMMS_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"
MOBILE_DIR="$CMMS_DIR/mobile"

# Check if mobile directory exists
if [ ! -d "$MOBILE_DIR" ]; then
    echo "Error: Mobile directory not found at $MOBILE_DIR"
    exit 1
fi

# Get local IP address
if command -v ip &> /dev/null; then
    IP_ADDRESS=$(ip addr show | grep "inet " | grep -v 127.0.0.1 | grep -v 172. | awk '{print $2}' | cut -d/ -f1 | head -n 1)
else
    IP_ADDRESS=$(hostname -I | awk '{print $1}')
fi

if [ -z "$IP_ADDRESS" ]; then
    echo "Could not detect local IP address. Please set API_URL manually in $MOBILE_DIR/.env"
    exit 1
fi

echo "Detected Local IP: $IP_ADDRESS"
echo "Setting API_URL to http://$IP_ADDRESS:8080"

# Create or update .env file in mobile directory
echo "API_URL=http://$IP_ADDRESS:8080" > "$MOBILE_DIR/.env"

# Navigate to mobile directory and start
cd "$MOBILE_DIR"
npm start
