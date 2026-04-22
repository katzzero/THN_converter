#!/bin/bash

echo "🎬 THN Converter - Versão Portátil"
echo "==================================="

cd "$(dirname "$0")"

# Criar estrutura do app bundle
APP_NAME="THN-Converter.app"
APP_DIR="$APP_NAME/Contents"

echo "📦 Criando app bundle..."
mkdir -p "$APP_DIR/MacOS"
mkdir -p "$APP_DIR/Resources"

# Criar Info.plist
cat > "$APP_DIR/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>THN-Converter</string>
    <key>CFBundleIdentifier</key>
    <string>com.thn.converter</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleExecutable</key>
    <string>THN-Converter</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.utilities</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

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

# Copiar FFmpeg para o app bundle
cp ffmpeg "$APP_DIR/MacOS/"
cp ffprobe "$APP_DIR/MacOS/" 2>/dev/null || true

echo ""
echo "✅ App portátil criado: $APP_NAME"
echo ""
echo "⚠️  NOTA: Esta versão requer Swift/SwiftUI runtime."
echo "Para uma versão completa, instale o Xcode e rode: ./build.sh"
echo ""
echo "📍 O app está em: $(pwd)/$APP_NAME"
