#!/bin/bash

# Start Backend with correct configuration

# Kill any existing backend processes
echo "Stopping any existing backend processes..."
pkill -f "spring-boot:run|ApiApplication|8080" 2>/dev/null || true
sleep 2

# Start backend
echo "Starting backend on port 8080..."
cd /home/zakee/atlas/cmms/api

# Run with MinIO configuration
./mvnw spring-boot:run \
  -Dspring-boot.run.jvmArguments=" \
    -Xmx2048m \
    -Dstorage.minio.endpoint=http://localhost:9000 \
    -Dstorage.minio.bucket=atlas-bucket \
    -Dstorage.minio.access-key=minio \
    -Dstorage.minio.secret-key=minio123 \
    -Dstorage.minio.public-endpoint=http://localhost:9000 \
    -Dfrontend.url=http://localhost:3000"
