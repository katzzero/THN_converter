# THN Converter 🎬

Conversor de vídeo nativo para macOS Apple Silicon com interface SwiftUI.

## Features

- ✅ Conversão de vídeo com múltiplos codecs (H.264, H.265, ProRes, DNxHD, VP9)
- ✅ Seleção de resolução (4K, Full HD, HD, SD, Original)
- ✅ Controle de framerate (60, 30, 24, etc)
- ✅ Codecs de áudio independentes (AAC, MP3, Opus, FLAC, etc)
- ✅ Overlay de timecode queimado no vídeo
- ✅ Interface drag & drop simples
- ✅ Barra de progresso em tempo real
- ✅ Otimizado para Apple Silicon (ARM64)

## Requisitos

- macOS 13.0+
- Xcode Command Line Tools
- FFmpeg (baixado automaticamente no build)

## Como Buildar

```bash
# 1. Baixe o FFmpeg e compile o app
./build.sh

# 2. Instale o app
cp -r THN-Converter/build/Build/Products/Release/THN-Converter.app /Applications/
```

## Como Usar

1. Arraste um arquivo de vídeo para a área indicada
2. Selecione as configurações desejadas:
   - Codec de vídeo
   - Resolução
   - Framerate
   - Bitrate de vídeo
   - Codec de áudio
   - Bitrate de áudio
   - Sample rate
   - Overlay de timecode (opcional)
3. Clique em "Converter"
4. O arquivo convertido será salvo na pasta **Downloads**

## Estrutura do Projeto

```
THN-Converter/
├── THN-Converter.xcodeproj/     # Projeto Xcode
├── THN-Converter/
│   ├── THN_ConverterApp.swift   # App entry point
│   ├── ContentView.swift        # Interface principal
│   ├── SettingsView.swift       # View de configurações
│   ├── VideoConverter.swift     # Lógica de conversão FFmpeg
│   └── Assets.xcassets/         # Assets do app
├── build.sh                     # Script de build
└── download-ffmpeg.sh          # Script para baixar FFmpeg
```

## Tecnologias

- **Swift 5** - Linguagem
- **SwiftUI** - Interface
- **FFmpeg** - Engine de conversão
- **Process** - Execução do FFmpeg

## Licença

MIT
