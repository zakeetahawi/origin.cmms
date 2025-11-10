#!/bin/bash

# Direct Backend Start with Environment Variables

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}====================================${NC}"
echo -e "${GREEN}  Starting Atlas CMMS Backend       ${NC}"
echo -e "${GREEN}     (Direct Method)                ${NC}"
echo -e "${GREEN}====================================${NC}"

cd /home/zakee/atlas/cmms/api

# Check if dependencies are installed
if [ ! -d "target" ]; then
    echo -e "${YELLOW}First time setup - Installing dependencies...${NC}"
    ./mvnw clean install -DskipTests
fi

echo -e "${BLUE}Starting Spring Boot application...${NC}"
echo -e "${YELLOW}The application will be available at: http://localhost:8080${NC}"
echo ""

# Run with all environment variables set directly
./mvnw spring-boot:run \
    -Dspring-boot.run.profiles=local \
    -Dspring-boot.run.jvmArguments=" \
        -Xmx2048m \
        -Dserver.port=8080 \
        -Dspring.datasource.url=jdbc:postgresql://localhost:5432/atlas \
        -Dspring.datasource.username=rootuser \
        -Dspring.datasource.password=5525 \
        -DDB_URL=localhost:5432/atlas \
        -DDB_USER=rootuser \
        -DDB_PWD=5525 \
        -DJWT_SECRET_KEY=xK8mP9qR2sT5vW7yA3bC6dE9fG2jH5kN8pQ \
        -DPUBLIC_API_URL=http://localhost:8080 \
        -DPUBLIC_FRONT_URL=http://localhost:3000 \
        -DSTORAGE_TYPE=LOCAL \
        -DENABLE_EMAIL_NOTIFICATIONS=false \
        -DINVITATION_VIA_EMAIL=false \
        -DLICENSE_FINGERPRINT_REQUIRED=false \
        -DSPRING_PROFILES_ACTIVE=local"
