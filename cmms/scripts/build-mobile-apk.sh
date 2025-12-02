#!/bin/bash

# Ensure we are in the mobile directory
cd mobile

# Get local IP address for API_URL
if command -v ip &> /dev/null; then
    IP_ADDRESS=$(ip addr show | grep "inet " | grep -v 127.0.0.1 | grep -v 172. | awk '{print $2}' | cut -d/ -f1 | head -n 1)
else
    IP_ADDRESS=$(hostname -I | awk '{print $1}')
fi

if [ -z "$IP_ADDRESS" ]; then
    echo "WARNING: Could not detect local IP address. API_URL might be incorrect."
else
    echo "Detected Local IP: $IP_ADDRESS"
    echo "Setting API_URL to http://$IP_ADDRESS:8080 in .env"
    echo "API_URL=http://$IP_ADDRESS:8080" > .env
fi

echo "Starting native APK build..."
echo "Step 1: Prebuilding Android project..."
# Generate native android files
npx expo prebuild --platform android --clean

echo "Step 2: Building APK with Gradle..."
cd android
chmod +x gradlew

# Force use of Java 17 for Gradle compatibility
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk"
echo "Using JAVA_HOME: $JAVA_HOME"

# Build the APK
./gradlew assembleRelease

echo "Build complete!"
echo "Copying APK to project root..."

# Find and copy the APK
APK_PATH=$(find app/build/outputs/apk/release -name "*.apk" | head -n 1)

if [ -f "$APK_PATH" ]; then
    cp "$APK_PATH" ../../origin-cmms.apk
    echo "SUCCESS: APK saved to origin-cmms.apk in the project root."
else
    echo "ERROR: APK file not found. Build might have failed."
fi
