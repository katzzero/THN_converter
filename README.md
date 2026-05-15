# THN Converter

<p align="center">
  <strong>Windows Video Converter with FFmpeg Backend</strong><br>
  <em>Conversor de Vídeo para Windows com FFmpeg</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Windows-WPF-purple?logo=windows" alt="Windows WPF">
  <img src="https://img.shields.io/badge/.NET-8-blue?logo=dotnet" alt=".NET 8">
  <img src="https://img.shields.io/badge/FFmpeg-powered-orange?logo=ffmpeg" alt="FFmpeg">
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

**THN Converter** is a native Windows video converter built with **C# WPF (.NET 8)** and an FFmpeg backend.

This is the **Windows branch**. See also:
- [`macos`](https://github.com/katzzero/THN_converter/tree/macos) — Swift native macOS app
- [`python`](https://github.com/katzzero/THN_converter/tree/python) — Python implementation

| Language | Framework | Location | Branch |
|----------|-----------|----------|--------|
| **Swift** | SwiftUI | `macos/` | `main` + `win` |
| **Python** | CustomTkinter | `python/` | `main` + `win` |
| **C#** | WPF (.NET 8) | `windows/` | `win` |

The Python implementation lives as a folder within both branches — it is **not** a separate branch. All three are kept feature-equal via the sync rules in `AI/MAINTENANCE_GUIDE.md`.

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

### macOS (Swift)

#### Prerequisites
- macOS 14.6 or later
- Xcode 15.0+
- Swift 5.9+

#### Building
```bash
git clone https://github.com/katzzero/THN_converter.git
cd macos
./download-ffmpeg.sh
open THN-Converter.xcodeproj
# Select "THN-Converter" scheme → Cmd+R
```

#### Command Line
```bash
cd macos
xcodebuild -project THN-Converter.xcodeproj -scheme THN-Converter -configuration Debug build
```

### Windows (C# WPF)

#### Prerequisites
- Windows 10/11 (x64)
- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [FFmpeg](https://github.com/BtbN/FFmpeg-Builds/releases) (place `ffmpeg.exe` in `windows/ffmpeg/`)

#### Building
```bash
cd windows
dotnet build -c Release
dotnet run
```

#### Publish as Single-File
```bash
dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true
```

### Python (Cross-platform)

#### Prerequisites
- Python 3.9+
- [FFmpeg](https://ffmpeg.org/download.html) in system PATH

#### Setup
```bash
cd python
pip install customtkinter
python3 thn_converter.py
```

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
├── macos/                      # Swift (macOS native app)
│   ├── THN-Converter/
│   │   ├── THN_ConverterApp.swift   # App entry point
│   │   ├── ContentView.swift        # Main UI
│   │   ├── VideoConverter.swift     # Conversion + metadata logic
│   │   └── Assets.xcassets/         # App resources
│   └── THN-Converter.xcodeproj      # Xcode project
├── python/                     # Python (cross-platform)
│   └── thn_converter.py             # Full implementation
├── windows/                    # C# WPF (Windows native)
│   ├── Models/                 # Data classes
│   ├── Services/               # FFmpeg + metadata services
│   ├── ViewModels/             # MVVM ViewModel
│   └── MainWindow.xaml         # 4-tab UI
├── AI/                         # AI project guides
│   ├── MAINTENANCE_GUIDE.md    # 3-branch sync rules
│   ├── thn_converter_manifest.json
│   ├── project_structure_guide.json
│   └── metadata_extraction_guide.json
├── ffmpeg                      # FFmpeg binary (macOS)
└── download-ffmpeg.sh          # Auto-download script
```

### Architecture / Arquitetura

**Swift (macOS)**: SwiftUI + AppKit + Process API
**C# (Windows)**: WPF + MVVM + System.Diagnostics.Process
**Python**: CustomTkinter + subprocess + threading

**FFmpeg Integration** (all implementations):
- macOS: Bundled + `/usr/local/bin` → `/opt/homebrew/bin` → `/usr/bin`
- Windows: Bundled `windows/ffmpeg/` → `%LOCALAPPDATA%` → Program Files → PATH
- Python: Same as macOS paths + cross-platform

### Sync Across Implementations

All three implementations must remain **feature-equal**. When adding features:

```
1. Swift (macos/)  →  2. Python (python/)  →  3. C# (windows/)  →  4. Update AI/ guides
```

See `AI/MAINTENANCE_GUIDE.md` for the complete file mapping and sync checklists.

### Building Commands / Comandos de Build

```bash
# Swift (macOS)
cd macos
xcodebuild -project THN-Converter.xcodeproj -scheme THN-Converter -configuration Debug build

# C# (Windows)
cd windows
dotnet build -c Release
dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true

# Python (any platform)
cd python
pip install customtkinter
python3 thn_converter.py
```

---

## ⚠️ Known Issues / Problemas Conhecidos

### Font Path
- **macOS**: Falls back through Helvetica → HelveticaNeue → SFPro → Arial
- **Windows**: Falls back through Arial → Segoe UI → Tahoma → Verdana → Trebuchet MS
- **Impact**: Font found on all major versions of both OSes
- **Status**: RESOLVED (fallback chains implemented on both platforms)

### Build Target Inconsistency
- **macOS**: Project level 13.0 vs Native target 14.6
- **Status**: Should be aligned in future update

---

## 📋 Version History / Histórico de Versões

### v1.1.0 (2026-05-15)
- ✅ Windows C# WPF native app (win branch)
- ✅ Python metadata extraction + Info tab
- ✅ All 3 implementations feature-equal
- ✅ AI maintenance guide for sync rules
- ✅ Project structure reorganized (macos/ python/ windows/)

### v1.0.0 (2026-04-28)
- ✅ Core conversion functionality
- ✅ Multiple codec support
- ✅ Timecode overlay
- ✅ Real-time progress
- ✅ Cancel support
- ✅ Multi-track metadata extraction
- ✅ HDR/SDR color space detection
- ⚠️ Font fallback (Phase-2 work in progress)

---

## 🤝 Contributing / Contribuindo

### Guidelines / Diretrizes

1. **Code Style**:
   - Swift: camelCase for functions
   - Python: snake_case for functions
   - C#: PascalCase with MVVM pattern

2. **Feature Parity**:
   - Any feature added to one implementation **must** be replicated in the other two
   - See `AI/MAINTENANCE_GUIDE.md` for file mapping

3. **Testing Checklist / Checklist de Testes**:
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

---

## 🙏 Credits / Créditos

- **FFmpeg**: https://ffmpeg.org/
- **FFmpeg Builds**: https://github.com/BtbN/FFmpeg-Builds
- **CustomTkinter**: https://github.com/TomSchimansky/CustomTkinter

---

## 📞 Support / Suporte

For issues, questions, or suggestions, please open an issue on GitHub.

---

<div align="center">

**Made with ❤️ — available on macOS, Windows, and cross-platform Python**

---

[English Version Above] | [Versão em Português Acima]

</div>
