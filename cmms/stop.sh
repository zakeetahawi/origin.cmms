#!/bin/bash

# Stop Script for Atlas CMMS

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Stopping Atlas CMMS services...${NC}"
echo ""

# Function to stop process on port
stop_port() {
    local port=$1
    local name=$2
    
    pid=$(lsof -Pi :$port -sTCP:LISTEN -t 2>/dev/null)
    if [ ! -z "$pid" ]; then
        echo -e "${YELLOW}Stopping $name on port $port (PID: $pid)...${NC}"
        kill $pid 2>/dev/null || kill -9 $pid 2>/dev/null || true
        sleep 1
        echo -e "${GREEN}✓ $name stopped${NC}"
    else
        echo -e "${YELLOW}$name not running on port $port${NC}"
    fi
}

# Stop services by port
stop_port 3000 "Frontend"
stop_port 8080 "Backend API"

# Also try to stop by process name
if pgrep -f "spring-boot:run" > /dev/null; then
    echo -e "${YELLOW}Stopping Spring Boot processes...${NC}"
    pkill -f "spring-boot:run"
    echo -e "${GREEN}✓ Spring Boot stopped${NC}"
fi

if pgrep -f "react-scripts" > /dev/null; then
    echo -e "${YELLOW}Stopping React development server...${NC}"
    pkill -f "react-scripts"
    echo -e "${GREEN}✓ React stopped${NC}"
fi

echo ""
echo -e "${GREEN}All services stopped!${NC}"
