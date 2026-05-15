#!/bin/bash

echo "🎬 THN Converter - Instalador Python"
echo "===================================="
echo ""

cd "$(dirname "$0")"

echo "📦 Instalando dependências..."
pip3 install -r requirements.txt

echo ""
echo "📥 Baixando FFmpeg para Apple Silicon..."
if [ ! -f "./ffmpeg" ]; then
    curl -L "https://evermeet.cx/ffmpeg/getrelease/ffmpeg/zip" -o ffmpeg.zip
    unzip -o ffmpeg.zip
    rm -f ffmpeg.zip
    chmod +x ffmpeg
    echo "✅ FFmpeg baixado!"
else
    echo "✅ FFmpeg já existe"
fi

echo ""
echo "✅ Instalação concluída!"
echo ""
echo "Para rodar o app:"
echo "  python3 thn_converter.py"
echo ""
echo "Ou crie um atalho no Launchpad com:"
echo "  ./create-app.sh"
