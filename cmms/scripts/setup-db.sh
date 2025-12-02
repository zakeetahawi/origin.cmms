#!/bin/bash

# Setup PostgreSQL Database for Origin CMMS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${GREEN}====================================${NC}"
echo -e "${GREEN}  Setting up PostgreSQL Database    ${NC}"
echo -e "${GREEN}====================================${NC}"

# Load environment variables
if [ -f "$PROJECT_DIR/.env" ]; then
    export $(cat "$PROJECT_DIR/.env" | grep -v '^#' | xargs)
else
    echo -e "${RED}Error: .env file not found!${NC}"
    echo -e "${YELLOW}Please copy .env.example to .env and configure it${NC}"
    exit 1
fi

# Default values if not set in .env
DB_NAME=${DB_NAME:-origin}
DB_USER=${POSTGRES_USER:-rootUser}
DB_PASSWORD=${POSTGRES_PWD:-mypassword}
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}

echo -e "${YELLOW}Database Configuration:${NC}"
echo "  Host: $DB_HOST:$DB_PORT"
echo "  Database: $DB_NAME"
echo "  User: $DB_USER"
echo ""

# Check if PostgreSQL is running
echo -e "${YELLOW}Checking PostgreSQL service...${NC}"
if ! pg_isready -h $DB_HOST -p $DB_PORT > /dev/null 2>&1; then
    echo -e "${RED}PostgreSQL is not running on $DB_HOST:$DB_PORT${NC}"
    echo -e "${YELLOW}Attempting to start PostgreSQL...${NC}"
    
    # Try to start PostgreSQL (different commands for different systems)
    if command -v systemctl &> /dev/null; then
        sudo systemctl start postgresql || true
    elif command -v service &> /dev/null; then
        sudo service postgresql start || true
    else
        echo -e "${RED}Could not start PostgreSQL automatically. Please start it manually.${NC}"
        exit 1
    fi
    
    # Wait for PostgreSQL to start
    sleep 3
    
    if ! pg_isready -h $DB_HOST -p $DB_PORT > /dev/null 2>&1; then
        echo -e "${RED}Failed to start PostgreSQL${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}PostgreSQL is running${NC}"

# Create database and user
echo -e "${YELLOW}Creating database and user...${NC}"

# Try to connect as postgres user without sudo first
if PGPASSWORD=postgres psql -h localhost -U postgres -c '\q' 2>/dev/null; then
    echo -e "${GREEN}Connected as postgres user${NC}"
    
    # Create user if not exists
    PGPASSWORD=postgres psql -h localhost -U postgres <<EOF 2>/dev/null || true
DO
\$\$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_user
      WHERE  usename = '$DB_USER') THEN
      CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';
   END IF;
END
\$\$;
EOF

    # Create database if not exists
    PGPASSWORD=postgres psql -h localhost -U postgres <<EOF 2>/dev/null || true
SELECT 'CREATE DATABASE $DB_NAME OWNER $DB_USER'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$DB_NAME')\\gexec
EOF

    # Grant all privileges
    PGPASSWORD=postgres psql -h localhost -U postgres <<EOF 2>/dev/null || true
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
ALTER USER $DB_USER CREATEDB;
EOF

else
    echo -e "${YELLOW}Cannot connect as postgres user. Trying with sudo...${NC}"
    echo -e "${RED}This may require your system password${NC}"
    
    # Create user if not exists
    sudo -u postgres psql <<EOF 2>/dev/null || true
DO
\$\$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_user
      WHERE  usename = '$DB_USER') THEN
      CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';
   END IF;
END
\$\$;
EOF

    # Create database if not exists
    sudo -u postgres psql <<EOF 2>/dev/null || true
SELECT 'CREATE DATABASE $DB_NAME OWNER $DB_USER'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$DB_NAME')\\gexec
EOF

    # Grant all privileges
    sudo -u postgres psql <<EOF 2>/dev/null || true
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
ALTER USER $DB_USER CREATEDB;
EOF
fi

echo -e "${GREEN}Database setup completed successfully!${NC}"
echo ""
echo -e "${YELLOW}Connection string:${NC}"
echo "  jdbc:postgresql://$DB_HOST:$DB_PORT/$DB_NAME"
echo ""
echo -e "${GREEN}You can test the connection with:${NC}"
echo "  psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME"
