#!/bin/bash

echo "🎬 Build THN Converter para Apple Silicon"
echo "=========================================="

cd "$(dirname "$0")"

# Baixar FFmpeg se necessário
if [ ! -f "./ffmpeg" ]; then
    echo ""
    echo "📥 Baixando FFmpeg para Apple Silicon..."
    curl -L "https://evermeet.cx/ffmpeg/getrelease/ffmpeg/zip" -o ffmpeg.zip
    unzip -o ffmpeg.zip
    rm -f ffmpeg.zip
    chmod +x ffmpeg
    echo "✅ FFmpeg baixado!"
fi

# Baixar FFprobe se necessário
if [ ! -f "./ffprobe" ]; then
    echo ""
    echo "📥 Baixando FFprobe..."
    curl -L "https://evermeet.cx/ffmpeg/getrelease/ffprobe/zip" -o ffprobe.zip
    unzip -o ffprobe.zip
    rm -f ffprobe.zip
    chmod +x ffprobe
    echo "✅ FFprobe baixado!"
fi

echo ""
echo "🔨 Compilando o app..."
cd THN-Converter

xcodebuild -project THN-Converter.xcodeproj \
    -scheme THN-Converter \
    -configuration Release \
    -derivedDataPath build \
    clean build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build concluído com sucesso!"
    echo "📦 App criado em: THN-Converter/build/Build/Products/Release/THN-Converter.app"
    echo ""
    echo "Para instalar:"
    echo "  cp -r THN-Converter/build/Build/Products/Release/THN-Converter.app /Applications/"
else
    echo ""
    echo "❌ Erro no build!"
    exit 1
fi
