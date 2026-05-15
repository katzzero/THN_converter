# THN Converter for Windows

Native Windows video converter built with .NET 8 / WPF and FFmpeg.

## Prerequisites

- Windows 10/11 (x64)
- .NET 8 SDK
- FFmpeg (auto-detected from PATH or placed in `ffmpeg/ffmpeg.exe`)

## Build

```bash
dotnet build THN-Converter-Win.csproj -c Release
```

Publish as single-file executable:

```bash
dotnet publish THN-Converter-Win.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true
```

## Usage

1. Open the app
2. Drag a video file to the designated area
3. Configure conversion settings
4. Click "Convert"

## Features

- Video codecs: H.264, H.265, ProRes, DNxHD, VP9, MPEG-4
- Audio codecs: AAC, MP3, Opus, Vorbis, FLAC, PCM
- Resolution, framerate, and CRF control
- Timecode overlay with configurable position
- Real-time progress tracking
- Technical metadata extraction (Info tab)
- Dark theme UI
- Drag-and-drop file input

## License

MIT
