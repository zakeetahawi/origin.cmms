#!/bin/bash

# Install MinIO for local storage

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}====================================${NC}"
echo -e "${BLUE}    Installing MinIO Server         ${NC}"
echo -e "${BLUE}====================================${NC}"
echo ""

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Map architecture names
case $ARCH in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64|arm64)
        ARCH="arm64"
        ;;
    *)
        echo -e "${RED}Unsupported architecture: $ARCH${NC}"
        exit 1
        ;;
esac

echo -e "${YELLOW}Detected OS: $OS, Architecture: $ARCH${NC}"

# Set download URL
MINIO_URL="https://dl.min.io/server/minio/release/${OS}-${ARCH}/minio"

# Create bin directory if not exists
mkdir -p ../.bin

# Download MinIO
echo -e "${YELLOW}Downloading MinIO...${NC}"
wget -q --show-progress -O ../.bin/minio "$MINIO_URL"

# Make executable
chmod +x ../.bin/minio

# Verify installation
if [ -f ../.bin/minio ]; then
    echo -e "${GREEN}MinIO downloaded successfully!${NC}"
    
    # Get version
    ../.bin/minio --version
    
    # Create data directory
    mkdir -p ../minio-data
    
    echo ""
    echo -e "${GREEN}MinIO installation completed!${NC}"
    echo ""
    echo -e "${YELLOW}To start MinIO manually:${NC}"
    echo "  cd .."
    echo "  .bin/minio server minio-data --address \":9000\" --console-address \":9001\""
    echo ""
    echo -e "${YELLOW}Default credentials (from .env):${NC}"
    echo "  Access Key: ${MINIO_USER:-minio}"
    echo "  Secret Key: ${MINIO_PASSWORD:-minio123}"
    echo ""
    echo -e "${YELLOW}URLs:${NC}"
    echo "  API: http://localhost:9000"
    echo "  Console: http://localhost:9001"
    
    # Update scripts to use local MinIO
    echo ""
    echo -e "${YELLOW}Updating scripts to use local MinIO...${NC}"
    
    # Update run-backend.sh to use local minio
    sed -i 's|minio server|../.bin/minio server|g' run-backend.sh 2>/dev/null || true
    sed -i 's|pgrep -x "minio"|pgrep -f ".bin/minio"|g' run-backend.sh 2>/dev/null || true
    
    # Update start-all.sh to use local minio
    sed -i 's|minio server|../.bin/minio server|g' start-all.sh 2>/dev/null || true
    sed -i 's|pgrep -x "minio"|pgrep -f ".bin/minio"|g' start-all.sh 2>/dev/null || true
    sed -i 's|pkill -f "minio"|pkill -f ".bin/minio"|g' start-all.sh 2>/dev/null || true
    
    # Update stop-all.sh
    sed -i 's|pgrep -x "minio"|pgrep -f ".bin/minio"|g' stop-all.sh 2>/dev/null || true
    sed -i 's|pkill -x "minio"|pkill -f ".bin/minio"|g' stop-all.sh 2>/dev/null || true
    
    echo -e "${GREEN}Scripts updated to use local MinIO${NC}"
else
    echo -e "${RED}Failed to download MinIO${NC}"
    exit 1
fi
