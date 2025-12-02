#!/bin/bash

# Setup MinIO bucket for Atlas CMMS

echo "Setting up MinIO..."

# Wait for MinIO to be ready
sleep 2

# Export MinIO credentials
export MINIO_ROOT_USER=minio
export MINIO_ROOT_PASSWORD=minio123

# Create MinIO configuration
cat > ~/.mc/config.json << EOF
{
  "version": "10",
  "aliases": {
    "local": {
      "url": "http://localhost:9000",
      "accessKey": "minio",
      "secretKey": "minio123",
      "api": "s3v4"
    }
  }
}
EOF

# Try using MinIO CLI if available
if command -v mc &> /dev/null; then
    echo "Using MinIO Client..."
    mc alias set local http://localhost:9000 minio minio123
    mc mb local/atlas-bucket --ignore-existing
    mc policy set public local/atlas-bucket
    echo "Bucket created successfully!"
else
    echo "MinIO Client not found, creating bucket via API..."
    # Create bucket using API
    curl -X PUT \
        -H "Host: localhost:9000" \
        -H "Date: $(date -R)" \
        -H "Content-Type: application/xml" \
        -H "Authorization: AWS minio:minio123" \
        http://localhost:9000/atlas-bucket 2>/dev/null || true
    echo "Bucket creation attempted!"
fi

echo "MinIO is ready!"
echo "Console: http://localhost:9001"
echo "API: http://localhost:9000"
echo "Access Key: minio"
echo "Secret Key: minio123"
