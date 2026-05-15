# THN Converter for Windows

Native Windows application built with .NET 8 and WPF. FFmpeg backend for video conversion.

## Prerequisites

- Windows 10/11 (x64)
- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- FFmpeg - either auto-detected from PATH or placed in `ffmpeg/ffmpeg.exe`

## Build & Run

```bash
# Build
dotnet build THN-Converter-Win.csproj -c Release

# Run
dotnet run --project THN-Converter-Win.csproj

# Publish as single-file executable
dotnet publish THN-Converter-Win.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true
```

Output: `bin/Release/net8.0-windows/win-x64/publish/THN-Converter-Win.exe`

## FFmpeg Setup

Option 1 - **Automatic**: Ensure `ffmpeg.exe` is in your system PATH
Option 2 - **Bundled**: Place `ffmpeg.exe` in the `ffmpeg/` folder (auto-detected)
Option 3 - **Manual**: Install to `%LOCALAPPDATA%\ffmpeg\ffmpeg.exe` or `C:\Program Files\ffmpeg\bin\ffmpeg.exe`

Download from: [BtbN/FFmpeg-Builds](https://github.com/BtbN/FFmpeg-Builds/releases)

## Usage

1. Open the app
2. Drag a video file to the designated area
3. Configure options:
   - Video codec
   - Quality (CRF)
   - Resolution (4K, Full HD, HD, SD, Original)
   - Framerate (60, 30, 24, etc)
   - Audio codec
   - Audio bitrate
   - Sample rate
   - Timecode overlay (optional)
4. Click "Convert"
5. File saved to chosen location

## Features

- 4-tab interface matching the macOS Swift version
- Video codecs: H.264, H.265/HEVC, ProRes, DNxHD, VP9, MPEG-4
- Audio codecs: copy, AAC, MP3, Opus, Vorbis, FLAC, PCM
- Resolution scaling, framerate adjustment, CRF quality
- Timecode overlay with configurable position
- FFmpeg progress tracking
- Technical metadata extraction and display (Info tab)
- Dark theme UI
- Drag-and-drop file input

## Project Structure

```
THN-Converter-Win/
├── THN-Converter-Win.csproj   # .NET 8 WPF project
├── App.xaml / App.xaml.cs      # App entry point
├── MainWindow.xaml              # 4-tab UI
├── MainWindow.xaml.cs           # Code-behind (drag-drop, dialogs)
├── Models/                      # Data models
│   ├── ConversionSettings.cs
│   ├── VideoMetadata.cs
│   ├── StreamInfo.cs
│   └── ColorSpaceInfo.cs
├── ViewModels/
│   └── MainViewModel.cs         # MVVM logic + commands
├── Services/
│   ├── FfmpegService.cs          # Conversion engine
│   └── MetadataService.cs        # Metadata extraction
├── Converters/                   # XAML value converters
├── Commands/                     # ICommand helper
├── Styles/                       # WPF themes
└── ffmpeg/                       # Put ffmpeg.exe here
```

## Technologies

- **C# 12** - Language
- **WPF + XAML** - Interface
- **FFmpeg** - Conversion engine
- **.NET 8** - Runtime

## License

MIT
