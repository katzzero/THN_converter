#!/bin/bash
# download-ffmpeg.sh - Downloads FFmpeg binary for current platform
# This script is called as an Xcode Build Phase

set -e

# Get the project root directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

echo "Checking for FFmpeg..."

# Check if ffmpeg already exists in project root
if [ -f "$PROJECT_ROOT/ffmpeg" ]; then
    echo "✅ FFmpeg already exists at $PROJECT_ROOT/ffmpeg"
    file "$PROJECT_ROOT/ffmpeg"
    exit 0
fi

echo "FFmpeg not found. Downloading..."

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    PLATFORM="macos-arm64"
    echo "Detected Apple Silicon (arm64)"
else
    PLATFORM="macos-64"
    echo "Detected Intel (x86_64)"
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download latest FFmpeg build
echo "Downloading FFmpeg for $PLATFORM..."
if command -v curl &> /dev/null; then
    curl -L -o ffmpeg.tar.xz "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-$PLATFORM.tar.xz"
elif command -v wget &> /dev/null; then
    wget -O ffmpeg.tar.xz "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-$PLATFORM.tar.xz"
else
    echo "❌ Neither curl nor wget found!"
    exit 1
fi

# Extract
echo "Extracting..."
tar -xf ffmpeg.tar.xz

# Find the ffmpeg binary
FFMPEG_PATH=$(find . -name "ffmpeg" -type f | head -1)
if [ -z "$FFMPEG_PATH" ]; then
    echo "❌ FFmpeg binary not found in archive!"
    exit 1
fi

# Copy to project root
cp "$FFMPEG_PATH" "$PROJECT_ROOT/ffmpeg"
chmod +x "$PROJECT_ROOT/ffmpeg"

# Cleanup
cd "$PROJECT_ROOT"
rm -rf "$TEMP_DIR"

echo "✅ FFmpeg downloaded successfully!"
file "$PROJECT_ROOT/ffmpeg"
echo "Size: $(stat -f%z "$PROJECT_ROOT/ffmpeg" 2>/dev/null || echo "unknown") bytes"
