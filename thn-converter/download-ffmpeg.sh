#!/bin/bash

# Script para baixar FFmpeg para Apple Silicon
echo "Baixando FFmpeg para Apple Silicon..."

FFMPEG_URL="https://evermeet.cx/ffmpeg/getrelease/ffmpeg/zip"
FFMPEG_PATH="./ffmpeg"

if [ ! -f "$FFMPEG_PATH" ]; then
    curl -L "$FFMPEG_URL" -o ffmpeg.zip
    unzip -o ffmpeg.zip
    rm ffmpeg.zip
    chmod +x ffmpeg
    echo "✅ FFmpeg baixado com sucesso!"
else
    echo "✅ FFmpeg já existe"
fi

echo "Baixando FFprobe..."
FFPROBE_URL="https://evermeet.cx/ffmpeg/getrelease/ffprobe/zip"

if [ ! -f "./ffprobe" ]; then
    curl -L "$FFPROBE_URL" -o ffprobe.zip
    unzip -o ffprobe.zip
    rm ffprobe.zip
    chmod +x ffprobe
    echo "✅ FFprobe baixado com sucesso!"
else
    echo "✅ FFprobe já existe"
fi
