#!/bin/bash

# Start All Services for Origin CMMS (without Docker)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Change to project directory
cd "$PROJECT_DIR"

echo -e "${MAGENTA}╔══════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║      Origin CMMS - Local Setup        ║${NC}"
echo -e "${MAGENTA}╚══════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Project directory: $PROJECT_DIR${NC}"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}First time setup detected!${NC}"
    echo -e "${YELLOW}Creating .env file from template...${NC}"
    cp .env.example .env
    echo -e "${GREEN}.env file created${NC}"
    echo -e "${RED}Please edit .env file with your configuration before continuing${NC}"
    echo -e "${YELLOW}Especially configure:${NC}"
    echo "  - POSTGRES_USER and POSTGRES_PWD"
    echo "  - JWT_SECRET_KEY (use a random string)"
    echo "  - PUBLIC_API_URL and PUBLIC_FRONT_URL if not using localhost"
    echo ""
    read -p "Press Enter after you've configured .env file..." 
fi

# Function to check if a port is in use
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to stop a service on a port
stop_service_on_port() {
    local port=$1
    local service=$2
    if check_port $port; then
        echo -e "${YELLOW}Port $port is already in use (possibly $service running)${NC}"
        read -p "Do you want to stop it? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            pid=$(lsof -Pi :$port -sTCP:LISTEN -t 2>/dev/null)
            if [ ! -z "$pid" ]; then
                kill $pid 2>/dev/null || true
                sleep 2
                echo -e "${GREEN}Service on port $port stopped${NC}"
            fi
        fi
    fi
}

# Check ports
echo -e "${YELLOW}Checking ports...${NC}"
stop_service_on_port 5432 "PostgreSQL"
stop_service_on_port 8080 "Backend API"
stop_service_on_port 3000 "Frontend"
stop_service_on_port 9000 "MinIO"
stop_service_on_port 9001 "MinIO Console"

# Menu
echo ""
echo -e "${BLUE}What would you like to do?${NC}"
echo "1) Setup database (first time only)"
echo "2) Start backend only"
echo "3) Start frontend only"
echo "4) Start everything (backend + frontend)"
echo "5) Start with MinIO (backend + frontend + MinIO)"
echo "6) Stop all services"
echo "7) Check service status"
echo "8) Exit"
echo ""
read -p "Enter your choice (1-8): " choice

case $choice in
    1)
        echo -e "${GREEN}Setting up database...${NC}"
        "$SCRIPT_DIR/setup-db.sh"
        ;;
    2)
        echo -e "${GREEN}Starting backend...${NC}"
        "$SCRIPT_DIR/run-backend.sh"
        ;;
    3)
        echo -e "${GREEN}Starting frontend...${NC}"
        "$SCRIPT_DIR/run-frontend.sh"
        ;;
    4)
        echo -e "${GREEN}Starting all services...${NC}"
        echo -e "${YELLOW}Starting backend in background...${NC}"
        nohup "$SCRIPT_DIR/run-backend.sh" > "$PROJECT_DIR/backend.log" 2>&1 &
        backend_pid=$!
        echo "Backend PID: $backend_pid"
        
        echo -e "${YELLOW}Waiting for backend to start...${NC}"
        sleep 10
        
        echo -e "${YELLOW}Starting frontend...${NC}"
        "$SCRIPT_DIR/run-frontend.sh"
        ;;
    5)
        echo -e "${GREEN}Starting all services with MinIO...${NC}"
        
        # Load environment
        export $(cat "$PROJECT_DIR/.env" | grep -v '^#' | xargs)
        
        # Start MinIO
        if ! pgrep -f "minio" > /dev/null; then
            echo -e "${YELLOW}Starting MinIO...${NC}"
            
            # Check if local MinIO exists
            if [ -f "$PROJECT_DIR/.bin/minio" ]; then
                MINIO_CMD="$PROJECT_DIR/.bin/minio"
            elif command -v minio > /dev/null 2>&1; then
                MINIO_CMD="minio"
            else
                echo -e "${RED}MinIO is not installed!${NC}"
                echo -e "${YELLOW}Please run: $SCRIPT_DIR/install-minio.sh first${NC}"
                exit 1
            fi
            
            mkdir -p "$PROJECT_DIR/minio-data"
            nohup $MINIO_CMD server "$PROJECT_DIR/minio-data" --address ":9000" --console-address ":9001" > "$PROJECT_DIR/minio.log" 2>&1 &
            minio_pid=$!
            echo "MinIO PID: $minio_pid"
            echo -e "${GREEN}MinIO Console: http://localhost:9001${NC}"
            sleep 3
        fi
        
        # Start backend
        echo -e "${YELLOW}Starting backend in background...${NC}"
        nohup "$SCRIPT_DIR/run-backend.sh" > "$PROJECT_DIR/backend.log" 2>&1 &
        backend_pid=$!
        echo "Backend PID: $backend_pid"
        
        echo -e "${YELLOW}Waiting for backend to start...${NC}"
        sleep 10
        
        # Start frontend
        echo -e "${YELLOW}Starting frontend...${NC}"
        "$SCRIPT_DIR/run-frontend.sh"
        ;;
    6)
        echo -e "${YELLOW}Stopping all services...${NC}"
        pkill -f "spring-boot:run" 2>/dev/null || true
        pkill -f "react-scripts" 2>/dev/null || true
        pkill -f ".bin/minio" 2>/dev/null || true
        echo -e "${GREEN}All services stopped${NC}"
        ;;
    7)
        echo -e "${BLUE}Service Status:${NC}"
        echo ""
        
        # Check PostgreSQL
        if pgrep -x "postgres" > /dev/null; then
            echo -e "PostgreSQL: ${GREEN}Running${NC}"
        else
            echo -e "PostgreSQL: ${RED}Not running${NC}"
        fi
        
        # Check Backend
        if check_port 8080; then
            echo -e "Backend API (8080): ${GREEN}Running${NC}"
        else
            echo -e "Backend API (8080): ${RED}Not running${NC}"
        fi
        
        # Check Frontend
        if check_port 3000; then
            echo -e "Frontend (3000): ${GREEN}Running${NC}"
        else
            echo -e "Frontend (3000): ${RED}Not running${NC}"
        fi
        
        # Check MinIO
        if check_port 9000; then
            echo -e "MinIO (9000): ${GREEN}Running${NC}"
        else
            echo -e "MinIO (9000): ${RED}Not running${NC}"
        fi
        ;;
    8)
        echo -e "${GREEN}Goodbye!${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice!${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}Done!${NC}"
echo ""
echo -e "${YELLOW}Useful URLs:${NC}"
echo "  Frontend: http://localhost:3000"
echo "  Backend API: http://localhost:8080"
echo "  MinIO Console: http://localhost:9001 (if running)"
echo ""
echo -e "${YELLOW}To check logs:${NC}"
echo "  Backend: tail -f $PROJECT_DIR/backend.log"
echo "  MinIO: tail -f $PROJECT_DIR/minio.log"
