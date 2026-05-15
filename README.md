# THN Converter for Python

Cross-platform Python application built with CustomTkinter. FFmpeg backend for video conversion.

## Prerequisites

- Python 3.8+
- pip3 (Python package manager)
- FFmpeg (downloaded automatically on first run)

## Build & Run

```bash
# Install dependencies and download FFmpeg
./install.sh

# Run the app
python3 thn_converter.py

# Create app bundle (macOS)
./create-app.sh
```

## Usage

1. Open the app (via terminal or icon)
2. Drag a video or click "Select File"
3. Choose save location (or accept default)
4. Configure options:
   - Video codec
   - Quality (CRF)
   - Resolution (4K, Full HD, HD, SD, Original)
   - Framerate (60, 30, 24, etc)
   - Audio codec
   - Audio bitrate
   - Sample rate
   - Timecode overlay (optional)
5. Click "Convert"
6. Wait - file saved to chosen location

## Features

- Modern and responsive interface (dark/light mode)
- Drag & drop file support
- Multiple video codecs (H.264, H.265, ProRes, DNxHD, VP9)
- Resolution, framerate, and quality (CRF) control
- Independent audio codecs
- Timecode overlay burned into video
- Real-time progress bar
- Detailed conversion log
- Custom save location selection
- Audio settings only when needed

## Project Structure

```
THN-Converter-Python/
├── thn_converter.py      # Main app
├── requirements.txt      # Python dependencies
├── install.sh           # Installation script
├── create-app.sh        # App bundle creation
└── ffmpeg              # FFmpeg binary (downloaded automatically)
```

## Technologies

- **CustomTkinter** - Modern interface
- **FFmpeg** - Conversion engine
- **Python 3** - Language

## License

MIT
