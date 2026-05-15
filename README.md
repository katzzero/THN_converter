# THN Converter for Python

Portable video converter in Python with modern graphical interface.

## Features

- Modern and responsive interface (dark/light mode)
- Drag & drop file support
- Multiple video codecs (H.264, H.265, ProRes, DNxHD, VP9)
- Resolution, framerate, and quality (CRF) control
- Independent audio codecs
- Timecode overlay burned into video
- Real-time progress bar
- Detailed conversion log
- Optimized for Apple Silicon
- Custom save location selection
- Audio settings only when needed
- Optimized grid layout interface

## Quick Installation

```bash
# 1. Install dependencies and download FFmpeg
./install.sh

# 2. Run the app
python3 thn_converter.py
```

## Create Installable App

```bash
# Create app bundle
./create-app.sh

# Install in Applications
cp -r THN-Converter.app /Applications/
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
   - Audio bitrate (appears only if not "copy")
   - Sample rate
   - Timecode overlay (optional)
5. Click "Convert"
6. Wait - file saved to chosen location

## Structure

```
THN-Converter-Python/
├── thn_converter.py      # Main app
├── requirements.txt      # Python dependencies
├── install.sh           # Installation script
├── create-app.sh        # App bundle creation
└── ffmpeg              # FFmpeg binary (downloaded automatically)
```

## Requirements

- macOS 13.0+
- Python 3.8+
- pip3 (Python package manager)

## Technologies

- **CustomTkinter** - Modern interface
- **FFmpeg** - Conversion engine
- **Python 3** - Language

## Tips

- First run downloads FFmpeg automatically
- Converted files can be saved anywhere
- Use "Original" to keep source resolution/framerate
- Timecode is based on video PTS (Presentation Timestamp)

## Common Issues

**Error: "customtkinter not found"**
```bash
pip3 install customtkinter
```

**Error: "ffmpeg not found"**
```bash
./install.sh
```

**App does not open**
```bash
python3 thn_converter.py
```
