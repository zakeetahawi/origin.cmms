#!/bin/bash

# Quick Start Script for Origin CMMS

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${MAGENTA}╔══════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║   Origin CMMS - Quick Start           ║${NC}"
echo -e "${MAGENTA}╚══════════════════════════════════════╝${NC}"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating .env file from template...${NC}"
    cp .env.example .env
    echo -e "${GREEN}.env file created${NC}"
fi

# Load environment variables
export $(cat .env | grep -v '^#' | xargs)

# Function to check if a port is in use
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Check PostgreSQL
echo -e "${YELLOW}Checking PostgreSQL...${NC}"
if ! pg_isready -h localhost -p 5432 > /dev/null 2>&1; then
    echo -e "${RED}PostgreSQL is not running!${NC}"
    echo -e "${YELLOW}Please start PostgreSQL first${NC}"
    exit 1
fi
echo -e "${GREEN}✓ PostgreSQL is running${NC}"

# Check database
echo -e "${YELLOW}Checking database...${NC}"
PGPASSWORD=${POSTGRES_PWD} psql -h localhost -U ${POSTGRES_USER} -d origin -c '\q' 2>/dev/null
if [ $? -ne 0 ]; then
    echo -e "${RED}Cannot connect to database!${NC}"
    echo -e "${YELLOW}Creating database...${NC}"
    
    # Try to create database
    PGPASSWORD=postgres psql -h localhost -U postgres <<EOF 2>/dev/null
CREATE USER ${POSTGRES_USER} WITH PASSWORD '${POSTGRES_PWD}';
CREATE DATABASE origin OWNER ${POSTGRES_USER};
GRANT ALL PRIVILEGES ON DATABASE origin TO ${POSTGRES_USER};
EOF
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Database created successfully${NC}"
    else
        echo -e "${RED}Failed to create database${NC}"
        echo -e "${YELLOW}Please run: cd scripts && ./setup-db.sh${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Database connection OK${NC}"
fi

# Check if backend is already running
if check_port 8080; then
    echo -e "${YELLOW}Backend is already running on port 8080${NC}"
    read -p "Do you want to stop it? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        pid=$(lsof -Pi :8080 -sTCP:LISTEN -t)
        kill $pid 2>/dev/null
        sleep 2
    fi
fi

# Check if frontend is already running
if check_port 3000; then
    echo -e "${YELLOW}Frontend is already running on port 3000${NC}"
    read -p "Do you want to stop it? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        pid=$(lsof -Pi :3000 -sTCP:LISTEN -t)
        kill $pid 2>/dev/null
        sleep 2
    fi
fi

echo ""
echo -e "${BLUE}Starting services...${NC}"
echo ""

# Start backend
echo -e "${YELLOW}Starting backend...${NC}"
cd api
if [ ! -d "target" ]; then
    echo -e "${YELLOW}Installing backend dependencies...${NC}"
    ./mvnw clean install -DskipTests
fi

# Start backend in background
nohup ./mvnw spring-boot:run > ../backend.log 2>&1 &
backend_pid=$!
echo -e "${GREEN}✓ Backend started (PID: $backend_pid)${NC}"
cd ..

# Wait for backend to start
echo -e "${YELLOW}Waiting for backend to initialize...${NC}"
for i in {1..30}; do
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/actuator/health | grep -q "200\|404"; then
        echo -e "${GREEN}✓ Backend is ready${NC}"
        break
    fi
    sleep 2
    echo -n "."
done
echo ""

# Start frontend
echo -e "${YELLOW}Starting frontend...${NC}"
cd frontend
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}Installing frontend dependencies...${NC}"
    npm install
fi

# Generate runtime config
cat > public/runtime-env.js << EOF
window.__RUNTIME_CONFIG__ = {
  NODE_ENV: "development",
  REACT_APP_API_URL: "${PUBLIC_API_URL:-http://localhost:8080}",
  REACT_APP_GOOGLE_KEY: "${GOOGLE_KEY:-}",
  REACT_APP_GOOGLE_TRACKING_ID: "${GOOGLE_TRACKING_ID:-}",
  REACT_APP_MUI_X_LICENSE: "${MUI_X_LICENSE:-}",
  REACT_APP_INVITATION_VIA_EMAIL: ${INVITATION_VIA_EMAIL:-false},
  REACT_APP_CLOUD_VERSION: ${CLOUD_VERSION:-false},
  REACT_APP_ENABLE_SSO: ${ENABLE_SSO:-false},
  REACT_APP_OAUTH2_PROVIDER: "${OAUTH2_PROVIDER:-}",
  REACT_APP_LOGO_PATHS: "${LOGO_PATHS:-}",
  REACT_APP_CUSTOM_COLORS: "${CUSTOM_COLORS:-}",
  REACT_APP_BRAND_CONFIG: "${BRAND_CONFIG:-}"
};
EOF

# Start frontend
echo -e "${GREEN}✓ Starting frontend...${NC}"
echo ""
echo -e "${MAGENTA}╔══════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║       Application is Starting!       ║${NC}"
echo -e "${MAGENTA}╚══════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}URLs:${NC}"
echo -e "  ${BLUE}Frontend:${NC} http://localhost:3000"
echo -e "  ${BLUE}Backend API:${NC} http://localhost:8080"
echo -e "  ${BLUE}API Docs:${NC} http://localhost:8080/swagger-ui/"
echo ""
echo -e "${YELLOW}Logs:${NC}"
echo -e "  Backend: tail -f backend.log"
echo ""
echo -e "${YELLOW}To stop all services, run: ./stop.sh${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop the frontend${NC}"
echo ""

# Start frontend in foreground
npm start
