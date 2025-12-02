#!/bin/bash

# Start Backend (Spring Boot) for Atlas CMMS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Initialize SDKMAN if available
if [ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${GREEN}====================================${NC}"
echo -e "${GREEN}    Starting Atlas CMMS Backend     ${NC}"
echo -e "${GREEN}====================================${NC}"

# Change to api directory
cd "$PROJECT_DIR/api"

# Load environment variables (copy from .env.example if missing)
if [ -f "$PROJECT_DIR/.env" ]; then
    echo -e "${YELLOW}Loading environment variables from .env${NC}"
    export $(cat "$PROJECT_DIR/.env" | grep -v '^#' | xargs)
else
    if [ -f "$PROJECT_DIR/.env.example" ]; then
        echo -e "${YELLOW}.env not found — copying .env.example to .env and using defaults${NC}"
        cp "$PROJECT_DIR/.env.example" "$PROJECT_DIR/.env"
        export $(cat "$PROJECT_DIR/.env" | grep -v '^#' | xargs)
    else
        echo -e "${RED}Error: .env file not found and no .env.example available!${NC}"
        echo -e "${YELLOW}Please create a .env based on .env.example and configure it${NC}"
        exit 1
    fi
fi

# Set database connection string
export DB_URL=${DB_HOST:-localhost}:${DB_PORT:-5432}/${DB_NAME:-atlas}

echo -e "${YELLOW}Configuration:${NC}"
echo "  Database: $DB_URL"
echo "  API URL: ${PUBLIC_API_URL:-http://localhost:8080}"
echo "  Frontend URL: ${PUBLIC_FRONT_URL:-http://localhost:3000}"
echo "  Storage Type: ${STORAGE_TYPE:-minio}"
echo ""

# Check if MinIO is needed and running (for local storage)
if [ "${STORAGE_TYPE:-minio}" = "minio" ] || [ "${STORAGE_TYPE:-minio}" = "MINIO" ]; then
    echo -e "${YELLOW}Checking MinIO service...${NC}"
    # Check if MinIO is accessible (health endpoint)
    HEALTH_URL="${PUBLIC_MINIO_ENDPOINT:-http://localhost:9000}/minio/health/live"
    if ! curl -s -o /dev/null -w "%{http_code}" "$HEALTH_URL" | grep -q "200"; then
        echo -e "${YELLOW}MinIO is not running. Starting MinIO...${NC}"
        # Start MinIO in background if not running
        if ! pgrep -f ".bin/minio" > /dev/null; then
            # Check if local MinIO exists
            if [ -f "$PROJECT_DIR/.bin/minio" ]; then
                MINIO_CMD="$PROJECT_DIR/.bin/minio"
            elif command -v minio > /dev/null 2>&1; then
                MINIO_CMD="minio"
            else
                echo -e "${RED}MinIO is not installed!${NC}"
                echo -e "${YELLOW}Please run: $SCRIPT_DIR/install-minio.sh${NC}"
                exit 1
            fi

            # Ensure data directory exists
            mkdir -p "$PROJECT_DIR/minio-data"

            # Export credentials for recent MinIO versions
            export MINIO_ROOT_USER=${MINIO_USER:-minio}
            export MINIO_ROOT_PASSWORD=${MINIO_PASSWORD:-minio123}

            # Start MinIO server (bind to all interfaces)
            nohup "$MINIO_CMD" server "$PROJECT_DIR/minio-data" --address "0.0.0.0:9000" --console-address "0.0.0.0:9001" > "$PROJECT_DIR/minio.log" 2>&1 &
            sleep 2
            echo -e "${GREEN}MinIO started in background (logs: $PROJECT_DIR/minio.log)${NC}"
            echo -e "${YELLOW}MinIO Console: http://localhost:9001${NC}"
            echo -e "${YELLOW}Access Key: ${MINIO_ROOT_USER}${NC}"
            echo -e "${YELLOW}Secret Key: ${MINIO_ROOT_PASSWORD}${NC}"
        else
            echo -e "${GREEN}MinIO process already running${NC}"
        fi
    else
        echo -e "${GREEN}MinIO is running${NC}"
    fi
fi

# Check database connection
echo -e "${YELLOW}Checking database connection...${NC}"
PGPASSWORD=${POSTGRES_PWD} psql -h ${DB_HOST:-localhost} -p ${DB_PORT:-5432} -U ${POSTGRES_USER} -d ${DB_NAME:-atlas} -c '\q' 2>/dev/null
if [ $? -ne 0 ]; then
    echo -e "${RED}Cannot connect to database!${NC}"
    echo -e "${YELLOW}Please ensure PostgreSQL is running and database is configured${NC}"
    echo -e "${YELLOW}Run: $SCRIPT_DIR/setup-db.sh to setup the database${NC}"
    exit 1
fi
echo -e "${GREEN}Database connection successful${NC}"

# Check if dependencies are installed
if [ ! -d "target" ]; then
    echo -e "${YELLOW}First time setup - Installing dependencies...${NC}"
    ./mvnw clean install -DskipTests
fi

# Run the application
echo -e "${BLUE}Starting Spring Boot application...${NC}"
echo -e "${YELLOW}The application will be available at: ${PUBLIC_API_URL:-http://localhost:8080}${NC}"
echo ""

# Set all required environment variables for Spring Boot
export SPRING_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE:-dev}

# Run Spring Boot with Maven
# Run Spring Boot with Maven
./mvnw spring-boot:run -DskipTests \
    -Dspring-boot.run.jvmArguments="-Xmx2048m" \
    -Dspring-boot.run.arguments="--server.port=8080"
