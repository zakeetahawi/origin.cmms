#!/bin/bash

# Stop All Services for Atlas CMMS

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}====================================${NC}"
echo -e "${YELLOW}    Stopping Atlas CMMS Services    ${NC}"
echo -e "${YELLOW}====================================${NC}"
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
        echo -e "${GREEN}$name stopped${NC}"
    else
        echo -e "${YELLOW}$name not running on port $port${NC}"
    fi
}

# Stop services by port
stop_port 3000 "Frontend"
stop_port 8080 "Backend API"
stop_port 9000 "MinIO"
stop_port 9001 "MinIO Console"

# Also try to stop by process name
echo ""
echo -e "${YELLOW}Checking for running processes...${NC}"

# Stop Spring Boot
if pgrep -f "spring-boot:run" > /dev/null; then
    echo -e "${YELLOW}Stopping Spring Boot processes...${NC}"
    pkill -f "spring-boot:run"
    echo -e "${GREEN}Spring Boot stopped${NC}"
fi

# Stop React
if pgrep -f "react-scripts" > /dev/null; then
    echo -e "${YELLOW}Stopping React development server...${NC}"
    pkill -f "react-scripts"
    echo -e "${GREEN}React stopped${NC}"
fi

# Stop MinIO
if pgrep -f ".bin/minio" > /dev/null; then
    echo -e "${YELLOW}Stopping MinIO...${NC}"
    pkill -f ".bin/minio"
    echo -e "${GREEN}MinIO stopped${NC}"
fi

# Stop Node processes
if pgrep -f "node.*frontend" > /dev/null; then
    echo -e "${YELLOW}Stopping Node.js processes...${NC}"
    pkill -f "node.*frontend"
    echo -e "${GREEN}Node.js processes stopped${NC}"
fi

echo ""
echo -e "${GREEN}All services stopped successfully!${NC}"
echo ""

# Show status
echo -e "${YELLOW}Current service status:${NC}"
echo -n "  Frontend (3000): "
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${RED}Still running${NC}"
else
    echo -e "${GREEN}Stopped${NC}"
fi

echo -n "  Backend (8080): "
if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${RED}Still running${NC}"
else
    echo -e "${GREEN}Stopped${NC}"
fi

echo -n "  MinIO (9000): "
if lsof -Pi :9000 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${RED}Still running${NC}"
else
    echo -e "${GREEN}Stopped${NC}"
fi
