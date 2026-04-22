#!/bin/bash

echo "🎬 Criando App Bundle..."

cd "$(dirname "$0")"

APP_NAME="THN-Converter.app"
APP_DIR="$APP_NAME/Contents"

rm -rf "$APP_NAME"
mkdir -p "$APP_DIR/MacOS"
mkdir -p "$APP_DIR/Resources"

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

cat > "$APP_DIR/MacOS/THN-Converter" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../../THN-Converter-Python"
python3 thn_converter.py
EOF

chmod +x "$APP_DIR/MacOS/THN-Converter"

cp ffmpeg "$APP_DIR/MacOS/" 2>/dev/null || true
cp ffprobe "$APP_DIR/MacOS/" 2>/dev/null || true

echo ""
echo "✅ App criado: $APP_NAME"
echo ""
echo "Para instalar no Applications:"
echo "  cp -r $APP_NAME /Applications/"
echo ""
echo "Ou rode diretamente:"
echo "  ./$APP_NAME/Contents/MacOS/THN-Converter"
