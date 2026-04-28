#!/bin/bash
# Script to update project_structure.json with current project state
# Run this script when major changes are made to the project

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
JSON_FILE="$PROJECT_ROOT/project_structure.json"
TEMP_FILE=$(mktemp)

echo "Updating project_structure.json..."

# Get FFmpeg version if available
FFMPEG_VERSION="latest"
if [ -f "$PROJECT_ROOT/ffmpeg" ]; then
    FFMPEG_VERSION=$("$PROJECT_ROOT/ffmpeg" -version 2>/dev/null | head -n1 | awk '{print $3}' || echo "unknown")
fi

# Get FFmpeg file size
FFMPEG_SIZE="unknown"
if [ -f "$PROJECT_ROOT/ffmpeg" ]; then
    FFMPEG_SIZE=$(stat -f%z "$PROJECT_ROOT/ffmpeg" 2>/dev/null || echo "unknown")
fi

# Get Swift file sizes
SWIFT_FILES=()
while IFS= read -r line; do
    if [[ $line == *".swift"* ]]; then
        file=$(echo "$line" | sed 's/.*"\(.*\)".*/\1/')
        if [ -f "$PROJECT_ROOT/$file" ]; then
            size=$(stat -f%z "$PROJECT_ROOT/$file" 2>/dev/null || echo "0")
            SWIFT_FILES+=("\"$file\": {\"size\": $size}")
        fi
    fi
done < "$JSON_FILE"

# Extract build settings from Xcode project (simplified)
BUILD_TARGET="14.6"
if [ -f "$PROJECT_ROOT/thn-converter/THN-Converter.xcodeproj/project.pbxproj" ]; then
    BUILD_TARGET=$(grep -A1 "MACOSX_DEPLOYMENT_TARGET" "$PROJECT_ROOT/thn-converter/THN-Converter.xcodeproj/project.pbxproj" | grep -v MACOSX | head -1 | sed 's/[^0-9.]//g' || echo "14.6")
fi

# Update JSON (basic update - would need a proper JSON parser for complex updates)
cat > "$TEMP_FILE" << EOF
{
  "project": "THN Converter",
  "version": "1.0.0",
  "description": "Video converter macOS app with FFmpeg backend, supporting multiple codecs, resolutions, framerates, audio options, and timecode overlay.",
  "platform": "macOS",
  "language": ["Swift", "Python"],
  "dependencies": {
    "Swift": ["SwiftUI", "UniformTypeIdentifiers", "Foundation", "AppKit"],
    "Python": ["customtkinter", "subprocess", "threading", "re", "pathlib", "datetime"]
  },
  "external_tools": {
    "ffmpeg": {
      "version": "$FFMPEG_VERSION",
      "size_bytes": $FFMPEG_SIZE,
      "source": "https://github.com/BtbN/FFmpeg-Builds/releases/latest",
      "path": ["project_root/ffmpeg", "/usr/local/bin/ffmpeg", "/opt/homebrew/bin/ffmpeg", "/usr/bin/ffmpeg"],
      "included_in_bundle": true,
      "build_phase": "CopyFiles to app bundle"
    }
  },
  "project_structure": {
    "root": [
      "THN-Converter.xcodeproj/",
      "THN-Converter/",
      "THN-Converter-Python/",
      "LICENSE",
      "ffmpeg",
      ".gitignore",
      "update_project_json.sh",
      "JSON_GENERATION_PROMPT.md"
    ],
    "source_files": {
      "Swift": [
        "THN-Converter/THN_ConverterApp.swift",
        "THN-Converter/ContentView.swift",
        "THN-Converter/VideoConverter.swift"
      ],
      "removed": [
        "THN-Converter/SettingsView.swift"
      ],
      "Python": [
        "THN-Converter-Python/thn_converter.py"
      ]
    },
    "resources": {
      "images": [
        "THN-Converter/Assets.xcassets/AppIcon.appiconset/xcode_icon_rounded_1024.png"
      ]
    }
  },
  "build_configurations": {
    "Xcode": {
      "schemes": ["Debug", "Release"],
      "deployment_target": "macOS $BUILD_TARGET",
      "code_sign": {
        "identity": "-",
        "app_sandbox": false,
        "hardened_runtime": true
      }
    }
  },
  "features": {
    "video_codec": ["libx264", "libx265", "prores_ks", "dnxhd", "vp9", "mpeg4"],
    "audio_codec": ["copy", "aac", "mp3", "opus", "vorbis", "flac", "pcm"],
    "resolution": ["Original", "3840x2160", "1920x1080", "1280x720", "854x480"],
    "framerate": ["Original", "60", "59.94", "30", "29.97", "24", "23.976"],
    "timecode_overlay": true,
    "timecode_position": ["top-left", "top-center", "top-right", "bottom-left", "bottom-center", "bottom-right"]
  },
  "known_issues": [
    "FFmpeg error 234 (permission/remote I/O) on some macOS versions",
    "Progress calculation uses fixed divisor (36000) - inaccurate for videos >10h",
    "Font path /System/Library/Fonts/Helvetica.ttc may not exist on all macOS versions"
  ],
  "ai_context": {
    "quick_summary": "macOS video converter with FFmpeg, SwiftUI frontend",
    "key_files": {
      "entry_point": "THN-Converter/THN_ConverterApp.swift",
      "video_logic": "THN-Converter/VideoConverter.swift",
      "ui": "THN-Converter/ContentView.swift",
      "python_alt": "THN-Converter-Python/thn_converter.py"
    },
    "common_tasks": {
      "add_codec": "Edit VideoConverter.swift mapVideoCodec() + ContentView.swift picker",
      "fix_timecode": "Edit VideoConverter.swift getTimecodeFilter()",
      "update_ffmpeg": "Replace ffmpeg binary in root and update JSON version"
    },
    "update_script": "update_project_json.sh"
  },
  "last_modified": "$(date +%Y-%m-%d)"
}
EOF

# Replace the old JSON file
mv "$TEMP_FILE" "$JSON_FILE"

echo "✅ project_structure.json updated successfully!"
echo "   FFmpeg version: $FFMPEG_VERSION"
echo "   FFmpeg size: $FFMPEG_SIZE bytes"
echo "   Last modified: $(date +%Y-%m-%d)"
