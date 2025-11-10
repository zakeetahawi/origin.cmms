#!/bin/bash

# Start Frontend (React) for Atlas CMMS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${GREEN}====================================${NC}"
echo -e "${GREEN}   Starting Atlas CMMS Frontend     ${NC}"
echo -e "${GREEN}====================================${NC}"

# Change to frontend directory
cd "$PROJECT_DIR/frontend"

# Load environment variables from parent .env
if [ -f "$PROJECT_DIR/.env" ]; then
    echo -e "${YELLOW}Loading environment variables from .env${NC}"
    export $(cat "$PROJECT_DIR/.env" | grep -v '^#' | xargs)
    
    # Also copy to local .env for React
    cat > .env.local << EOF
REACT_APP_API_URL=${PUBLIC_API_URL:-http://localhost:8080}
REACT_APP_GOOGLE_KEY=${GOOGLE_KEY:-}
REACT_APP_GOOGLE_TRACKING_ID=${GOOGLE_TRACKING_ID:-}
REACT_APP_MUI_X_LICENSE=${MUI_X_LICENSE:-}
REACT_APP_INVITATION_VIA_EMAIL=${INVITATION_VIA_EMAIL:-false}
REACT_APP_CLOUD_VERSION=${CLOUD_VERSION:-false}
REACT_APP_ENABLE_SSO=${ENABLE_SSO:-false}
REACT_APP_OAUTH2_PROVIDER=${OAUTH2_PROVIDER:-}
REACT_APP_LOGO_PATHS=${LOGO_PATHS:-}
REACT_APP_CUSTOM_COLORS=${CUSTOM_COLORS:-}
REACT_APP_BRAND_CONFIG=${BRAND_CONFIG:-}
EOF
else
    echo -e "${RED}Error: .env file not found!${NC}"
    echo -e "${YELLOW}Please copy .env.example to .env and configure it${NC}"
    exit 1
fi

echo -e "${YELLOW}Configuration:${NC}"
echo "  API URL: ${PUBLIC_API_URL:-http://localhost:8080}"
echo "  Frontend URL: http://localhost:3000"
echo "  Enable SSO: ${ENABLE_SSO:-false}"
echo ""

# Check if backend is running
echo -e "${YELLOW}Checking backend availability...${NC}"
if ! curl -s -o /dev/null -w "%{http_code}" ${PUBLIC_API_URL:-http://localhost:8080}/actuator/health | grep -q "200\|404"; then
    echo -e "${YELLOW}Warning: Backend is not responding at ${PUBLIC_API_URL:-http://localhost:8080}${NC}"
    echo -e "${YELLOW}Please make sure the backend is running (run $SCRIPT_DIR/run-backend.sh)${NC}"
    echo ""
    read -p "Do you want to continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo -e "${GREEN}Backend is available${NC}"
fi

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}Installing dependencies...${NC}"
    npm install
fi

# Generate runtime environment config
echo -e "${YELLOW}Generating runtime configuration...${NC}"
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

# Start the development server
echo -e "${BLUE}Starting React development server...${NC}"
echo -e "${YELLOW}The application will be available at: http://localhost:3000${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
echo ""

# Export environment variables for React
export API_URL=${PUBLIC_API_URL:-http://localhost:8080}
export NODE_ENV=development

# Start React development server
npm start
