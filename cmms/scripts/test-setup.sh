#!/bin/bash

# Test Setup for Origin CMMS

# Don't exit on error for test script
set +e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}====================================${NC}"
echo -e "${BLUE}   Testing Origin CMMS Setup        ${NC}"
echo -e "${BLUE}====================================${NC}"
echo ""

# Function to check command
check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "✅ $1: ${GREEN}Installed${NC}"
        $1 --version 2>&1 | head -1 || $1 -version 2>&1 | head -1 || true
    else
        echo -e "❌ $1: ${RED}Not found${NC}"
        return 1
    fi
}

# Function to check file
check_file() {
    if [ -f "$1" ]; then
        echo -e "✅ $2: ${GREEN}Found${NC}"
    else
        echo -e "❌ $2: ${RED}Not found${NC}"
        return 1
    fi
}

# Function to check port
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "⚠️  Port $1: ${YELLOW}In use${NC}"
    else
        echo -e "✅ Port $1: ${GREEN}Available${NC}"
    fi
}

echo -e "${YELLOW}1. Checking Required Software:${NC}"
echo ""

# Check Java
check_command java

# Check Node.js
check_command node

# Check npm
check_command npm

# Check PostgreSQL
check_command psql

# Check Git
check_command git

echo ""
echo -e "${YELLOW}2. Checking Project Structure:${NC}"
echo ""

# Check critical files
check_file "$PROJECT_DIR/.env" ".env configuration"
check_file "$PROJECT_DIR/api/mvnw" "Maven wrapper"
check_file "$PROJECT_DIR/api/pom.xml" "Backend POM"
check_file "$PROJECT_DIR/frontend/package.json" "Frontend package.json"

echo ""
echo -e "${YELLOW}3. Checking Ports:${NC}"
echo ""

check_port 3000  # Frontend
check_port 5432  # PostgreSQL
check_port 8080  # Backend
check_port 9000  # MinIO
check_port 9001  # MinIO Console

echo ""
echo -e "${YELLOW}4. Checking Environment Variables:${NC}"
echo ""

if [ -f "$PROJECT_DIR/.env" ]; then
    source "$PROJECT_DIR/.env"
    
    # Check critical variables
    if [ -z "$POSTGRES_USER" ]; then
        echo -e "⚠️  POSTGRES_USER: ${YELLOW}Not set${NC}"
    else
        echo -e "✅ POSTGRES_USER: ${GREEN}Set${NC} ($POSTGRES_USER)"
    fi
    
    if [ -z "$POSTGRES_PWD" ]; then
        echo -e "⚠️  POSTGRES_PWD: ${YELLOW}Not set${NC}"
    else
        echo -e "✅ POSTGRES_PWD: ${GREEN}Set${NC}"
    fi
    
    if [ -z "$JWT_SECRET_KEY" ]; then
        echo -e "⚠️  JWT_SECRET_KEY: ${YELLOW}Not set${NC}"
    else
        echo -e "✅ JWT_SECRET_KEY: ${GREEN}Set${NC}"
    fi
fi

echo ""
echo -e "${YELLOW}5. Checking Database Connection:${NC}"
echo ""

if [ ! -z "$POSTGRES_USER" ] && [ ! -z "$POSTGRES_PWD" ]; then
    PGPASSWORD=$POSTGRES_PWD psql -h localhost -p 5432 -U $POSTGRES_USER -l 2>/dev/null > /dev/null
    if [ $? -eq 0 ]; then
        echo -e "✅ Database connection: ${GREEN}OK${NC}"
        
        # Check if origin database exists
        PGPASSWORD=$POSTGRES_PWD psql -h localhost -p 5432 -U $POSTGRES_USER -l 2>/dev/null | grep origin > /dev/null
        if [ $? -eq 0 ]; then
            echo -e "✅ Origin database: ${GREEN}Exists${NC}"
        else
            echo -e "⚠️  Origin database: ${YELLOW}Not created yet${NC}"
            echo -e "   Run: ${BLUE}$SCRIPT_DIR/setup-db.sh${NC} to create it"
        fi
    else
        echo -e "❌ Database connection: ${RED}Failed${NC}"
        echo -e "   Make sure PostgreSQL is running"
    fi
else
    echo -e "⚠️  Cannot test database: ${YELLOW}Credentials not configured${NC}"
fi || true

echo ""
echo -e "${YELLOW}6. Checking MinIO:${NC}"
echo ""

if [ -f "$PROJECT_DIR/.bin/minio" ]; then
    echo -e "✅ Local MinIO: ${GREEN}Installed${NC}"
elif command -v minio &> /dev/null; then
    echo -e "✅ System MinIO: ${GREEN}Installed${NC}"
else
    echo -e "⚠️  MinIO: ${YELLOW}Not installed${NC}"
    echo -e "   Run: ${BLUE}$SCRIPT_DIR/install-minio.sh${NC} to install it"
fi

echo ""
echo -e "${BLUE}====================================${NC}"
echo -e "${BLUE}         Test Complete             ${NC}"
echo -e "${BLUE}====================================${NC}"
echo ""

echo -e "${GREEN}Next Steps:${NC}"
echo "1. Configure .env file if needed"
echo "2. Run ${BLUE}$SCRIPT_DIR/setup-db.sh${NC} to setup database"
echo "3. Run ${BLUE}$SCRIPT_DIR/start-all.sh${NC} to start the application"
