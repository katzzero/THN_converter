# THN Converter for macOS

Native video converter for macOS Apple Silicon with SwiftUI interface.

## Features

- Video conversion with multiple codecs (H.264, H.265, ProRes, DNxHD, VP9)
- Resolution selection (4K, Full HD, HD, SD, Original)
- Framerate control (60, 30, 24, etc)
- Independent audio codecs (AAC, MP3, Opus, FLAC, etc)
- Timecode overlay burned into video
- Drag & drop interface
- Real-time progress bar
- Optimized for Apple Silicon (ARM64)

## Requirements

- macOS 13.0+
- Xcode Command Line Tools
- FFmpeg (downloaded automatically on build)

## How to Build

```bash
# 1. Download FFmpeg and compile the app
./build.sh

# 2. Install the app
cp -r THN-Converter/build/Build/Products/Release/THN-Converter.app /Applications/
```

## How to Use

1. Drag a video file to the designated area
2. Select desired settings:
   - Video codec
   - Resolution
   - Framerate
   - Video bitrate
   - Audio codec
   - Audio bitrate
   - Sample rate
   - Timecode overlay (optional)
3. Click "Convert"
4. The converted file will be saved in **Downloads**

## Project Structure

```
THN-Converter/
├── THN-Converter.xcodeproj/     # Xcode project
├── THN-Converter/
│   ├── THN_ConverterApp.swift   # App entry point
│   ├── ContentView.swift        # Main interface
│   ├── SettingsView.swift       # Settings view
│   ├── VideoConverter.swift     # FFmpeg conversion logic
│   └── Assets.xcassets/         # App assets
├── build.sh                     # Build script
└── download-ffmpeg.sh          # FFmpeg download script
```

## Technologies

- **Swift 5** - Language
- **SwiftUI** - Interface
- **FFmpeg** - Conversion engine
- **Process** - FFmpeg execution

## License

MIT
