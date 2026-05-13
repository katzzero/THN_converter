# THN Converter for Windows

Native Windows WPF application built with .NET 8. FFmpeg backend for video conversion.

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

# Or open THN-Converter-Win.sln in Visual Studio 2022
```

## Publish as Single-File Executable

```bash
dotnet publish THN-Converter-Win.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true
```

Output: `bin/Release/net8.0-windows/win-x64/publish/THN-Converter-Win.exe`

## FFmpeg Setup

Option 1 - **Automatic**: Ensure `ffmpeg.exe` is in your system PATH
Option 2 - **Bundled**: Place `ffmpeg.exe` in the `ffmpeg/` folder (auto-detected)
Option 3 - **Manual**: Install to `%LOCALAPPDATA%\ffmpeg\ffmpeg.exe` or `C:\Program Files\ffmpeg\bin\ffmpeg.exe`

Download from: [BtbN/FFmpeg-Builds](https://github.com/BtbN/FFmpeg-Builds/releases)

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
win/THN-Converter-Win/
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

## Key Differences from macOS Swift Version

| Feature | Swift (macOS) | C# (Windows) |
|---------|---------------|--------------|
| UI Framework | SwiftUI | WPF + XAML |
| Pattern | @State / ObservableObject | MVVM (INotifyPropertyChanged) |
| Async | async/await + Continuation | async Task + IProgress<T> |
| Regex | NSRegularExpression | [GeneratedRegex] (C# 11) |
| Font paths | /System/Library/Fonts/ | C:\Windows\Fonts\ |
| FFmpeg paths | /usr/local/bin/ffmpeg | .\ffmpeg\ffmpeg.exe, %PATH% |

## macOS ↔ Windows Sync

When adding features to one platform, update all implementations:
- Swift (`thn-converter/THN-Converter/`)
- Python (`THN-Converter-Python/`)
- C# (`win/THN-Converter-Win/`)

Also update the AI guides in `/AI/` to reflect any changes.
