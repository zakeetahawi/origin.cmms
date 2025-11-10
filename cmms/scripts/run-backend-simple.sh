#!/bin/bash

# Start Backend (Spring Boot) for Atlas CMMS - Simple Version

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}====================================${NC}"
echo -e "${GREEN}    Starting Atlas CMMS Backend     ${NC}"
echo -e "${GREEN}       (Simple Version)             ${NC}"
echo -e "${GREEN}====================================${NC}"

# Change to api directory
cd ../api

# Load environment variables
if [ -f ../.env ]; then
    echo -e "${YELLOW}Loading environment variables from .env${NC}"
    export $(cat ../.env | grep -v '^#' | xargs)
else
    echo -e "${RED}Error: .env file not found!${NC}"
    exit 1
fi

# Set database connection string
export DB_URL=${DB_HOST:-localhost}:${DB_PORT:-5432}/${DB_NAME:-atlas}

echo -e "${YELLOW}Configuration:${NC}"
echo "  Database: $DB_URL"
echo "  API URL: ${PUBLIC_API_URL:-http://localhost:8080}"
echo "  Frontend URL: ${PUBLIC_FRONT_URL:-http://localhost:3000}"
echo "  Storage Type: ${STORAGE_TYPE:-LOCAL}"
echo ""

# Check database connection
echo -e "${YELLOW}Checking database connection...${NC}"
PGPASSWORD=${POSTGRES_PWD} psql -h ${DB_HOST:-localhost} -p ${DB_PORT:-5432} -U ${POSTGRES_USER} -d ${DB_NAME:-atlas} -c '\q' 2>/dev/null
if [ $? -ne 0 ]; then
    echo -e "${RED}Cannot connect to database!${NC}"
    echo -e "${YELLOW}Please ensure PostgreSQL is running${NC}"
    exit 1
fi
echo -e "${GREEN}Database connection successful${NC}"

# Create storage directory for local storage
if [ "${STORAGE_TYPE}" = "LOCAL" ] || [ "${STORAGE_TYPE}" = "local" ]; then
    echo -e "${YELLOW}Creating local storage directory...${NC}"
    mkdir -p storage
    echo -e "${GREEN}Storage directory ready${NC}"
fi

# Check if dependencies are installed
if [ ! -d "target" ]; then
    echo -e "${YELLOW}First time setup - Installing dependencies...${NC}"
    ./mvnw clean install -DskipTests
fi

# Run the application
echo -e "${BLUE}Starting Spring Boot application...${NC}"
echo -e "${YELLOW}The application will be available at: ${PUBLIC_API_URL:-http://localhost:8080}${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
echo ""

# Set all required environment variables for Spring Boot
export SPRING_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE:-dev}

# Run Spring Boot with Maven
./mvnw spring-boot:run \
    -Dspring-boot.run.jvmArguments="-Xmx2048m" \
    -Dspring-boot.run.arguments="--server.port=8080"
