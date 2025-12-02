#!/bin/bash

# Simple Start Script for Origin CMMS
# This script starts the application without MinIO complications

echo "========================================="
echo "   Origin CMMS - Simple Start"
echo "========================================="

# Kill any existing processes
pkill -f "spring-boot:run" 2>/dev/null || true
pkill -f "react-scripts" 2>/dev/null || true
pkill -f "minio" 2>/dev/null || true

# Start MinIO first
echo "Starting MinIO..."
cd /home/zakee/origin/cmms
mkdir -p minio-data
export MINIO_ROOT_USER=minio
export MINIO_ROOT_PASSWORD=minio123
/home/zakee/origin/cmms/.bin/minio server ./minio-data --address ":9000" --console-address ":9001" > minio.log 2>&1 &
sleep 3
echo "MinIO started on http://localhost:9001 (user: minio, pass: minio123)"

# Start Backend with correct configuration
echo "Starting Backend..."
cd /home/zakee/origin/cmms/api
./mvnw spring-boot:run \
  -Dspring-boot.run.jvmArguments=" \
    -Dstorage.minio.endpoint=http://localhost:9000 \
    -Dstorage.minio.bucket=origin-bucket \
    -Dstorage.minio.access-key=minio \
    -Dstorage.minio.secret-key=minio123 \
    -Dstorage.minio.public-endpoint=http://localhost:9000" \
  > ../backend.log 2>&1 &

echo "Waiting for Backend to start..."
sleep 15

# Start Frontend
echo "Starting Frontend..."
cd /home/zakee/origin/cmms/frontend
npm start > ../frontend.log 2>&1 &

echo ""
echo "========================================="
echo "   Application Starting!"
echo "========================================="
echo ""
echo "URLs:"
echo "  Frontend: http://localhost:3000"
echo "  Backend API: http://localhost:8080"
echo "  MinIO Console: http://localhost:9001"
echo ""
echo "Logs:"
echo "  tail -f /home/zakee/origin/cmms/backend.log"
echo "  tail -f /home/zakee/origin/cmms/frontend.log"
echo "  tail -f /home/zakee/origin/cmms/minio.log"
echo ""
echo "To stop all: pkill -f 'spring-boot:run|react-scripts|minio'"
