# THN Converter

<p align="center">
  <strong>macOS Video Converter with FFmpeg Backend</strong><br>
  <em>Conversor de Vídeo para macOS com FFmpeg</em>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#usage">Usage</a> •
  <a href="#supported-codecs">Codecs</a> •
  <a href="#development">Development</a> •
  <a href="#license">License</a>
</p>

---

## 🎯 Overview / Visão Geral

**THN Converter** is a powerful macOS application for video conversion, built with SwiftUI and backed by FFmpeg. It supports multiple video/audio codecs, customizable resolutions, frame rates, timecode overlay, and detailed file metadata extraction.

**THN Converter** é um aplicativo macOS poderoso para conversão de vídeo, construído com SwiftUI e baseado em FFmpeg. Suporta múltiplos codecs de vídeo/áudio, resoluções personalizáveis, taxas de quadro, sobreposição de timecode e extração detalhada de metadados de arquivos.

---

## ✨ Features / Funcionalidades

### Core Features / Funcionalidades Principais

- **🎬 Multiple Codecs**: H.264, H.265/HEVC, ProRes, DNxHD, VP9, MPEG-4
- **🎵 Audio Control**: AAC, MP3, Opus, Vorbis, FLAC, PCM, or stream copy
- **📐 Resolution Options**: Original, 3840×2160 (4K), 1920×1080 (Full HD), 1280×720 (HD), 854×480 (SD)
- **⏱️ Frame Rate Control**: Original, 60, 59.94, 30, 29.97, 24, 23.976 fps
- **🕐 Timecode Overlay**: Customizable position (8 positions), automatic formatting
- **📊 Real-time Progress**: Dynamic progress tracking based on video duration
- **🛑 Cancel Support**: Safely cancel conversions at any time
- **📋 Detailed Metadata**: Extract and display technical file information

### Metadata Extraction / Extração de Metadados

- **📄 File Information**: Duration, total bitrate, container format
- **🎬 Video Streams**: Codec, profile, resolution, pixel format, framerate, bitrate
- **🔊 Audio Streams**: Codec, sample rate, channels, bitrate, language tags
- **📝 Subtitle Streams**: Codec and language detection
- **📊 Data Streams**: Timecode tracks, metadata streams
- **🎨 Color Space**: HDR/SDR detection, color primaries, transfer functions
- **⏱️ Timecode**: Embedded timecode extraction

### User Interface / Interface do Usuário

- **🖱️ Drag & Drop**: Simple file selection via drop zone or file picker
- **📑 Multi-Tab Interface**:
  - **Principal**: Drop zone, conversion settings, progress control
  - **Opções**: Video/audio codec configuration
  - **Log**: Real-time FFmpeg output
  - **Info**: Technical metadata display

---

## 📦 Installation / Instalação

### Prerequisites / Pré-requisitos

- macOS 14.6 or later
- Xcode 15.0+ (for building)
- Swift 5.9+
- FFmpeg automatically downloaded during build

### Building / Construindo

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/thn-converter.git
   cd thn-converter
   ```

2. **Download FFmpeg**
   ```bash
   ./download-ffmpeg.sh
   ```
   This automatically detects your architecture (Apple Silicon/Intel) and downloads the appropriate FFmpeg binary to the project root.

3. **Open in Xcode**
   ```bash
   open thn-converter/THN-Converter.xcodeproj
   ```

4. **Build and Run**
   - Select "THN-Converter" scheme
   - Choose destination Mac
   - Press Cmd+R to build and run

### Command Line Build / Build via Linha de Comando

```bash
cd thn-converter
xcodebuild -project THN-Converter.xcodeproj -scheme THN-Converter -configuration Debug build
```

The app will be available in `~/Library/Developer/Xcode/DerivedData/Build/Products/Debug/THN-Converter.app`

---

## 🎮 Usage / Uso

### Basic Conversion / Conversão Básica

1. **Select File**:
   - Drag and drop a video file onto the app window
   - OR click the drop zone to open file picker

2. **Configure Settings**:
   - Choose video codec and quality (CRF 0-50)
   - Select resolution (or keep original)
   - Set frame rate (or keep original)
   - Choose audio codec (or copy without reencoding)
   - Configure audio bitrate and sample rate

3. **Set Output**:
   - Click "Selecionar Destino" to choose output location
   - OR use default Downloads folder

4. **Optional - Add Timecode**:
   - Enable "Mostrar Timecode" toggle
   - Select position (top-left to bottom-right)

5. **Start Conversion**:
   - Click "Converter" button
   - Monitor progress in real-time
   - View detailed FFmpeg output in Log tab

6. **Monitor Progress**:
   - Progress bar shows real-time conversion progress
   - Log tab displays FFmpeg output
   - Cancel anytime with "Cancelar" button

### Metadata View / Visualização de Metadados

1. Load any video file
2. Switch to **Info** tab (automatically fetches metadata)
3. View detailed technical information:
   - File metadata (duration, bitrate, container)
   - All video streams with codec, profile, resolution
   - All audio streams with codec, sample rate, channels
   - Subtitle and data streams
   - Color space information (HDR/SDR detection)
   - Embedded timecode

---

## 🎨 Supported Codecs / Codecs Suportados

### Video Codecs / Codecs de Vídeo

| Codec | Profile | Use Case |
|-------|---------|----------|
| H.264 (libx264) | Baseline/Main/High | Universal compatibility |
| H.265/HEVC (libx265) | Main/Main 10 | Better compression, HDR support |
| ProRes (prores_ks) | 422 HQ | Professional editing |
| DNxHD (dnxhd) | 175/220 | Avid workflows |
| VP9 (libvpx-vp9) | Profile 0/2 | Web streaming, open source |
| MPEG-4 (mpeg4) | - | Legacy compatibility |

### Audio Codecs / Codecs de Áudio

| Codec | Bitrates | Use Case |
|-------|----------|----------|
| AAC | 96k-320k | Universal, good quality |
| MP3 | 96k-320k | Legacy compatibility |
| Opus | - | Web, streaming |
| Vorbis | - | Open source |
| FLAC | - | Lossless audio |
| PCM | - | Uncompressed audio |
| **copy** | N/A | No reencoding (fastest) |

---

## 🛠️ Development / Desenvolvimento

### Project Structure / Estrutura do Projeto

```
THN Converter/
├── thn-converter/              # Swift (macOS app)
│   ├── THN-Converter/
│   │   ├── THN_ConverterApp.swift   # App entry point
│   │   ├── ContentView.swift        # Main UI
│   │   ├── VideoConverter.swift     # Conversion logic
│   │   └── Assets.xcassets/         # App resources
│   └── THN-Converter.xcodeproj      # Xcode project
├── THN-Converter-Python/       # Python (alternative implementation)
│   └── thn_converter.py
├── ffmpeg                       # FFmpeg binary (63MB)
├── download-ffmpeg.sh          # Auto-download script
├── update_project_json.sh      # Update project_structure.json
└── project_structure.json      # Project documentation
```

### Architecture / Arquitetura

**Swift Implementation**:
- SwiftUI for declarative UI
- AppKit for file dialogs
- UniformTypeIdentifiers for file type detection
- Process API for FFmpeg integration

**Python Implementation**:
- CustomTkinter for cross-platform UI
- subprocess for FFmpeg integration
- threading for async operations

**FFmpeg Integration**:
- FFmpeg bundled with app (not sandboxed)
- Auto-download script for first-time setup
- Search paths: bundle → /usr/local/bin → /opt/homebrew/bin → /usr/bin

### Adding New Features / Adicionando Novos Recursos

#### Add New Video Codec:
1. Update `VideoConverter.mapVideoCodec()` switch
2. Add to `ContentView.swift` picker options
3. Update `project_structure.json` features array
4. Sync with Python implementation

#### Add New Metadata Field:
1. Update `VideoMetadata` struct
2. Add parsing method in `parseFFmpegMetadata()`
3. Update UI in Info Tab
4. Document in README

### Building Commands / Comandos de Build

```bash
# Debug build
xcodebuild -project THN-Converter.xcodeproj -scheme THN-Converter -configuration Debug build

# Release build
xcodebuild -project THN-Converter.xcodeproj -scheme THN-Converter -configuration Release build

# Run tests (none configured)
# No automated tests yet

# Clean build artifacts
xcodebuild clean
rm -rf thn-converter/build/
```

### Project Management / Gerenciamento do Projeto

- **JSON Documentation**: `project_structure.json` contains complete project reference
- **Update Script**: `./update_project_json.sh` auto-syncs project state
- **Version Tracking**: Git commits reference features/fixes in messages

---

## ⚠️ Known Issues / Problemas Conhecidos

### Font Path / Caminho da Fonte
- **Issue**: Helvetica.ttc may not exist on all macOS versions
- **Impact**: Timecode overlay may fail on macOS < 14.6
- **Workaround**: Add font fallback in `getTimecodeFilter()`
- **Status**: KNOWN_ISSUE

### Build Target Inconsistency / Inconsistência de Build
- **Project Level**: macOS 13.0
- **Native Target**: macOS 14.6
- **Status**: Should be aligned in future update

---

## 📋 Version History / Histórico de Versões

### v1.0.0 (2026-04-28)
- ✅ Core conversion functionality
- ✅ Multiple codec support
- ✅ Timecode overlay
- ✅ Real-time progress
- ✅ Cancel support
- ✅ Multi-track metadata extraction
- ✅ HDR/SDR color space detection
- ⚠️ Font fallback (Phase-2 work in progress)

### Previous Versions
- Phase-1: Fixed progression calculation, timecode format, FFmpeg integration
- Phase-2: Adding font fallback, input validation, metadata extraction (COMPLETE)

---

## 🤝 Contributing / Contribuindo

Contributions are welcome! Please follow these guidelines:

### Guidelines / Diretrizes

1. **Code Style**:
   - Swift: camelCase for functions
   - Python: snake_case for functions
   - Follow existing conventions

2. **Metadata Extraction**:
   - Test with varied file types
   - Verify parsing accuracy
   - Update `project_structure.json`

3. **FFmpeg Changes**:
   - Always keep auto-download functional
   - Test all codecs after changes
   - Document any breaking changes

4. **Testing**:
   - Test with real files (not just generated)
   - Verify all codec combinations
   - Check error handling paths

### Testing Checklist / Checklist de Testes

- [ ] Standard MP4 (H.264 + AAC)
- [ ] HDR HEVC MKV (Main 10 + BT.2020 + smpte2084)
- [ ] Multi-track ProRes
- [ ] Audio-only files
- [ ] Corrupted files (error handling)
- [ ] Files with subtitles
- [ ] Files with embedded timecodes
- [ ] Files with DCI-P3 color space

---

## 📄 License / Licença

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.

Este projeto está licenciado sob os termos especificados no arquivo [LICENSE](LICENSE).

---

## 🙏 Credits / Créditos

- **FFmpeg**: https://ffmpeg.org/
- **FFmpeg Builds**: https://github.com/BtbN/FFmpeg-Builds
- **CustomTkinter**: https://github.com/TomSchimansky/CustomTkinter

---

## 📞 Support / Suporte

For issues, questions, or suggestions, please open an issue on GitHub.

Para problemas, perguntas ou sugestões, abra um issue no GitHub.

---

<div align="center">

**Made with ❤️ for macOS**

---

[English Version Above] | [Versão em Português Acima]

</div>
