#!/bin/bash

# Unified Run Script for Atlas CMMS (Backend + Frontend + Mobile Web)

set -e

# ============================================
# IMPORTANT: Set Java 21 BEFORE anything else
# ============================================
if [ -d "$HOME/.sdkman/candidates/java/21.0.9-tem" ]; then
    export JAVA_HOME="$HOME/.sdkman/candidates/java/21.0.9-tem"
elif [ -d "$HOME/.sdkman/candidates/java/current" ]; then
    export JAVA_HOME="$HOME/.sdkman/candidates/java/current"
fi
export PATH="$JAVA_HOME/bin:$PATH"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}JAVA_HOME: $JAVA_HOME${NC}"
echo -e "${BLUE}Java: $(java -version 2>&1 | head -1)${NC}"

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$PROJECT_DIR/logs"

mkdir -p "$LOG_DIR"

# Functions
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

stop_service() {
    local port=$1
    local name=$2
    if check_port $port; then
        echo -e "${YELLOW}Stopping $name on port $port...${NC}"
        pid=$(lsof -Pi :$port -sTCP:LISTEN -t)
        kill -9 $pid 2>/dev/null || true
        echo -e "${GREEN}$name stopped.${NC}"
    fi
}

start_backend() {
    echo -e "${CYAN}Starting Backend (Spring Boot)...${NC}"
    stop_service 8080 "Backend"
    cd "$PROJECT_DIR/api"
    nohup mvn spring-boot:run -DskipTests > "$LOG_DIR/backend.log" 2>&1 &
    echo -e "${GREEN}Backend started in background. Logs: $LOG_DIR/backend.log${NC}"
}

start_frontend() {
    echo -e "${CYAN}Starting Frontend (React)...${NC}"
    stop_service 3000 "Frontend"
    cd "$PROJECT_DIR/frontend"
    nohup npm start > "$LOG_DIR/frontend.log" 2>&1 &
    echo -e "${GREEN}Frontend started in background. Logs: $LOG_DIR/frontend.log${NC}"
}

start_mobile() {
    echo -e "${CYAN}Starting Mobile Web (Expo)...${NC}"
    stop_service 19006 "Mobile Web"
    stop_service 19007 "Mobile Web"
    stop_service 8081 "Metro Bundler"
    cd "$PROJECT_DIR/mobile"
    export NODE_OPTIONS="--openssl-legacy-provider"
    nohup npx expo start --web --clear > "$LOG_DIR/mobile.log" 2>&1 &
    echo -e "${GREEN}Mobile Web started in background. Logs: $LOG_DIR/mobile.log${NC}"
}

stop_all() {
    echo -e "${RED}Stopping all services...${NC}"
    stop_service 8080 "Backend"
    stop_service 3000 "Frontend"
    stop_service 19006 "Mobile Web (19006)"
    stop_service 19007 "Mobile Web (19007)"
    stop_service 8081 "Metro Bundler"
    pkill -f "spring-boot:run" || true
    pkill -f "react-scripts" || true
    pkill -f "expo start" || true
    echo -e "${GREEN}All services stopped.${NC}"
}

check_status() {
    echo -e "\n${BLUE}--- Service Status ---${NC}"
    if check_port 8080; then echo -e "Backend (8080): ${GREEN}RUNNING${NC}"; else echo -e "Backend (8080): ${RED}STOPPED${NC}"; fi
    if check_port 3000; then echo -e "Frontend (3000): ${GREEN}RUNNING${NC}"; else echo -e "Frontend (3000): ${RED}STOPPED${NC}"; fi
    if check_port 19006 || check_port 19007; then echo -e "Mobile Web: ${GREEN}RUNNING${NC}"; else echo -e "Mobile Web: ${RED}STOPPED${NC}"; fi
    echo ""
}

# Menu Loop
while true; do
    echo -e "\n${MAGENTA}╔══════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║    Atlas CMMS - Unified Launcher     ║${NC}"
    echo -e "${MAGENTA}╚══════════════════════════════════════╝${NC}"
    echo "1) Start ALL (Backend + Frontend + Mobile)"
    echo "2) Start Backend Only"
    echo "3) Start Frontend Only"
    echo "4) Start Mobile Web Only"
    echo "5) Stop ALL"
    echo "6) Check Status"
    echo "7) View Logs (Tail)"
    echo "8) Exit"
    
    read -p "Select an option [1-8]: " choice
    
    case $choice in
        1)
            stop_all
            start_backend
            echo -e "${YELLOW}Waiting 10s for Backend...${NC}"
            sleep 10
            start_frontend
            start_mobile
            check_status
            ;;
        2)
            start_backend
            ;;
        3)
            start_frontend
            ;;
        4)
            start_mobile
            ;;
        5)
            stop_all
            check_status
            ;;
        6)
            check_status
            ;;
        7)
            echo "Select log to view:"
            echo "1) Backend"
            echo "2) Frontend"
            echo "3) Mobile"
            read -p "Log [1-3]: " log_choice
            case $log_choice in
                1) tail -f "$LOG_DIR/backend.log" ;;
                2) tail -f "$LOG_DIR/frontend.log" ;;
                3) tail -f "$LOG_DIR/mobile.log" ;;
                *) echo "Invalid log choice" ;;
            esac
            ;;
        8)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            ;;
    esac
    
    read -p "Press Enter to continue..."
done
