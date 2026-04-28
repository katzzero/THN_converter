#!/bin/bash
# Script to update project_structure.json with current project state
# Run this script when major changes are made to the project

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
JSON_FILE="$PROJECT_ROOT/project_structure.json"

echo "Updating project_structure.json..."

# Get FFmpeg version if available
FFMPEG_VERSION="unknown"
if [ -f "$PROJECT_ROOT/ffmpeg" ]; then
    FFMPEG_VERSION=$(./ffmpeg -version 2>/dev/null | head -n1 | awk '{print $3}' || echo "unknown")
fi

# Get FFmpeg file size
FFMPEG_SIZE=0
if [ -f "$PROJECT_ROOT/ffmpeg" ]; then
    FFMPEG_SIZE=$(stat -f%z "$PROJECT_ROOT/ffmpeg" 2>/dev/null || echo "0")
fi

# Get git state
GIT_BRANCH=$(git -C "$PROJECT_ROOT" branch --show-current 2>/dev/null || echo "unknown")
GIT_COMMIT=$(git -C "$PROJECT_ROOT" log -1 --format="%h" 2>/dev/null || echo "unknown")
GIT_COMMIT_DATE=$(git -C "$PROJECT_ROOT" log -1 --format="%ai" 2>/dev/null | cut -d' ' -f1 || echo "unknown")
GIT_COMMIT_MSG=$(git -C "$PROJECT_ROOT" log -1 --format="%s" 2>/dev/null || echo "unknown")
GIT_DIRTY=false
if [ -n "$(git -C "$PROJECT_ROOT" status --porcelain 2>/dev/null)" ]; then
    GIT_DIRTY=true
fi

# Get Swift file sizes
APP_SIZE=0
CONTENTVIEW_SIZE=0
VIDEOCONVERTER_SIZE=0
ENTITLEMENTS_SIZE=0

if [ -f "$PROJECT_ROOT/thn-converter/THN-Converter/THN_ConverterApp.swift" ]; then
    APP_SIZE=$(stat -f%z "$PROJECT_ROOT/thn-converter/THN-Converter/THN_ConverterApp.swift" 2>/dev/null || echo "0")
fi
if [ -f "$PROJECT_ROOT/thn-converter/THN-Converter/ContentView.swift" ]; then
    CONTENTVIEW_SIZE=$(stat -f%z "$PROJECT_ROOT/thn-converter/THN-Converter/ContentView.swift" 2>/dev/null || echo "0")
fi
if [ -f "$PROJECT_ROOT/thn-converter/THN-Converter/VideoConverter.swift" ]; then
    VIDEOCONVERTER_SIZE=$(stat -f%z "$PROJECT_ROOT/thn-converter/THN-Converter/VideoConverter.swift" 2>/dev/null || echo "0")
fi
if [ -f "$PROJECT_ROOT/thn-converter/THN-Converter/THN-Converter.entitlements" ]; then
    ENTITLEMENTS_SIZE=$(stat -f%z "$PROJECT_ROOT/thn-converter/THN-Converter/THN-Converter.entitlements" 2>/dev/null || echo "0")
fi

# Generate JSON using Python (avoids escape issues) - export variables for Python
export PROJECT_ROOT
export FFMPEG_VERSION
export FFMPEG_SIZE
export GIT_BRANCH
export GIT_COMMIT
export GIT_COMMIT_DATE
export GIT_COMMIT_MSG
export GIT_DIRTY
export APP_SIZE
export CONTENTVIEW_SIZE
export VIDEOCONVERTER_SIZE
export ENTITLEMENTS_SIZE

python3 << 'PYEOF'
import json
from datetime import date
import os

# These values will be substituted by bash before Python runs
# We'll read them from environment variables instead
PROJECT_ROOT = os.environ.get("PROJECT_ROOT", "")
FFMPEG_VERSION = os.environ.get("FFMPEG_VERSION", "unknown")
FFMPEG_SIZE = int(os.environ.get("FFMPEG_SIZE", "0"))
GIT_BRANCH = os.environ.get("GIT_BRANCH", "unknown")
GIT_COMMIT = os.environ.get("GIT_COMMIT", "unknown")
GIT_COMMIT_DATE = os.environ.get("GIT_COMMIT_DATE", "unknown")
GIT_COMMIT_MSG = os.environ.get("GIT_COMMIT_MSG", "unknown")
GIT_DIRTY = os.environ.get("GIT_DIRTY", "false") == "true"
APP_SIZE = int(os.environ.get("APP_SIZE", "0"))
CONTENTVIEW_SIZE = int(os.environ.get("CONTENTVIEW_SIZE", "0"))
VIDEOCONVERTER_SIZE = int(os.environ.get("VIDEOCONVERTER_SIZE", "0"))
ENTITLEMENTS_SIZE = int(os.environ.get("ENTITLEMENTS_SIZE", "0"))

data = {
    "project": "THN Converter",
    "version": "1.0.0",
    "description": "Video converter macOS app with FFmpeg backend, supporting multiple codecs, frame rates, audio options, and timecode overlay.",
    "created": "2026-04-22",
    "last_modified": date.today().isoformat(),
    "platform": ["macOS"],
    "languages": ["Swift", "Python"],
    "frameworks": ["SwiftUI", "UniformTypeIdentifiers", "AppKit", "CustomTkinter"],
    "git_state": {
        "branch": GIT_BRANCH,
        "last_commit": GIT_COMMIT,
        "last_commit_date": GIT_COMMIT_DATE,
        "last_commit_msg": GIT_COMMIT_MSG,
        "dirty": GIT_DIRTY
    },
    "dependencies": {
        "Swift": ["SwiftUI", "UniformTypeIdentifiers", "Foundation", "AppKit"],
        "Python": ["customtkinter", "subprocess", "threading", "re", "pathlib", "datetime"]
    },
    "external_tools": {
        "ffmpeg": {
            "version": FFMPEG_VERSION,
            "size_bytes": FFMPEG_SIZE,
            "checksum_md5": "unknown",
            "source": "https://github.com/BtbN/FFmpeg-Builds/releases/latest",
            "included_in_bundle": True,
            "search_paths": ["project_root/ffmpeg", "/usr/local/bin/ffmpeg", "/opt/homebrew/bin/ffmpeg", "/usr/bin/ffmpeg"],
            "build_phase": "CopyFiles to app bundle",
            "min_version_note": "Build includes FFmpeg for Apple Silicon (arm64)"
        }
    },
    "file_metadata": {
        "source_files": [
            {"path": "THN-Converter/THN_ConverterApp.swift", "size_bytes": APP_SIZE, "purpose": "App entry point"},
            {"path": "THN-Converter/ContentView.swift", "size_bytes": CONTENTVIEW_SIZE, "purpose": "Main UI with tabs"},
            {"path": "THN-Converter/VideoConverter.swift", "size_bytes": VIDEOCONVERTER_SIZE, "purpose": "FFmpeg wrapper and conversion logic"},
            {"path": "THN-Converter-Python/thn_converter.py", "size_bytes": "unknown", "purpose": "Python alternative implementation"}
        ],
        "config_files": [
            {"path": "thn-converter/THN-Converter.xcodeproj/project.pbxproj", "size_bytes": "unknown", "purpose": "Xcode project settings"},
            {"path": "thn-converter/THN-Converter/THN-Converter.entitlements", "size_bytes": ENTITLEMENTS_SIZE, "purpose": "Security permissions"}
        ],
        "removed_files": [
            {"path": "THN-Converter/SettingsView.swift", "reason": "Duplicated code, unused"}
        ]
    },
    "project_structure": {
        "root": [
            "THN-Converter.xcodeproj/",
            "THN-Converter/",
            "THN-Converter-Python/",
            "LICENSE",
            "ffmpeg",
            ".gitignore",
            "project_structure.json",
            "update_project_json.sh",
            "JSON_GENERATION_PROMPT.md",
            "escrita/"
        ],
        "source_directories": ["THN-Converter/", "THN-Converter-Python/"],
        "config_files": ["thn-converter/THN-Converter.xcodeproj/", "THN-Converter/THN-Converter.entitlements"],
        "asset_directories": ["THN-Converter/Assets.xcassets/"]
    },
    "build_and_test": {
        "build_command": "xcodebuild -project thn-converter/THN-Converter.xcodeproj -scheme THN-Converter -configuration Debug build",
        "test_command": "No automated tests configured",
        "clean_command": "rm -rf thn-converter/build/ && xcodebuild clean",
        "run_python_alt": "cd THN-Converter-Python && python3 thn_converter.py"
    },
    "quick_ref": {
        "purpose": "macOS video converter with FFmpeg backend",
        "tech_stack": "SwiftUI + FFmpeg (bundled) / Python + CustomTkinter",
        "entry_point": "THN-Converter/THN_ConverterApp.swift",
        "key_files_ordered": [
            "THN-Converter/THN_ConverterApp.swift",
            "THN-Converter/ContentView.swift",
            "THN-Converter/VideoConverter.swift"
        ]
    },
    "file_relationships": {
        "THN_ConverterApp.swift": ["ContentView.swift"],
        "ContentView.swift": ["VideoConverter.swift", "Foundation", "UniformTypeIdentifiers"],
        "VideoConverter.swift": ["Foundation", "AppKit", "ffmpeg (external)"],
        "thn_converter.py": ["customtkinter", "subprocess", "ffmpeg (external)"]
    },
    "build_configurations": {
        "Xcode": {
            "schemes": ["Debug", "Release"],
            "deployment_target": "macOS 14.6",
            "code_sign": {
                "identity": "-",
                "app_sandbox": False,
                "hardened_runtime": True
            }
        }
    },
    "features": {
        "video_codec": ["libx264", "libx265", "prores_ks", "dnxhd", "vp9", "mpeg4"],
        "audio_codec": ["copy", "aac", "mp3", "opus", "vorbis", "flac", "pcm"],
        "resolution": ["Original", "3840x2160", "1920x1080", "1280x720", "854x480"],
        "framerate": ["Original", "60", "59.94", "30", "29.97", "24", "23.976"],
        "timecode_overlay": True,
        "timecode_position": ["top-left", "top-center", "top-right", "bottom-left", "bottom-center", "bottom-right"]
    },
    "troubleshooting": [
        {
            "error_pattern": "FFmpeg failed with status 234",
            "cause": "Permission denied or remote I/O error on macOS, often related to sandbox or output path",
            "solution": "Check write permissions with FileManager.isWritableFile, ensure output directory exists, verify selected path is writable",
            "files_to_check": ["VideoConverter.swift"],
            "code_location": "VideoConverter.swift line ~161-170"
        },
        {
            "error_pattern": "parsedrawtext invalid format HMS",
            "cause": "Wrong timecode format - using pts: instead of gmtime:%H:%M:%S",
            "solution": "Use gmtime format: text='%{gmtime:%H:%M:%S}' in getTimecodeFilter()",
            "files_to_check": ["VideoConverter.swift"],
            "code_location": "VideoConverter.swift getTimecodeFilter()"
        },
        {
            "error_pattern": "font file not found",
            "cause": "Wrong font path - /System/Library/Fonts/Helvetica.ttc may not exist on all macOS versions",
            "solution": "Use fallback fonts or verify path exists with FileManager",
            "files_to_check": ["VideoConverter.swift"],
            "code_location": "VideoConverter.swift getTimecodeFilter() line ~178"
        },
        {
            "error_pattern": "Progress stuck at 10%",
            "cause": "Fixed divisor of 36000 (10 hours) in parseProgress()",
            "solution": "Parse Duration from FFmpeg output and use actual duration for progress calculation",
            "files_to_check": ["VideoConverter.swift"],
            "code_location": "VideoConverter.swift parseProgress() line ~206"
        }
    ],
    "known_issues": [
        "FFmpeg error 234 (permission/remote I/O) on some macOS versions",
        "Progress calculation uses fixed divisor (36000) - inaccurate for videos >10h",
        "Font path /System/Library/Fonts/Helvetica.ttc may not exist on all macOS versions"
    ],
    "ai_context": {
        "quick_summary": "macOS video converter with FFmpeg bundled, SwiftUI frontend, supports multiple codecs and timecode overlay",
        "read_order": [
            "project_structure.json (this file)",
            "THN-Converter/THN_ConverterApp.swift",
            "THN-Converter/ContentView.swift",
            "THN-Converter/VideoConverter.swift"
        ],
        "skip_files_over": 10000,
        "key_files": {
            "entry_point": "THN-Converter/THN_ConverterApp.swift",
            "video_logic": "THN-Converter/VideoConverter.swift",
            "ui": "THN-Converter/ContentView.swift",
            "python_alt": "THN-Converter-Python/thn_converter.py"
        },
        "common_tasks": {
            "add_codec": {"where": "VideoConverter.swift mapVideoCodec() + ContentView.swift picker", "how": "Add to video_codec array and mapVideoCodec() switch"},
            "fix_timecode": {"where": "VideoConverter.swift getTimecodeFilter()", "how": "Use correct gmtime format and verify font path"},
            "update_ffmpeg": {"where": "project root", "how": "Replace ffmpeg binary and update JSON version/size"},
            "fix_progress": {"where": "VideoConverter.swift parseProgress()", "how": "Parse Duration from FFmpeg output, calculate progress as currentTime/duration"}
        },
        "update_script": "update_project_json.sh"
    }
}

json_path = os.path.join(PROJECT_ROOT, "project_structure.json")
with open(json_path, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("✅ project_structure.json updated successfully!")
PYEOF

echo "   FFmpeg version: $FFMPEG_VERSION"
echo "   FFmpeg size: $FFMPEG_SIZE bytes"
echo "   Git branch: $GIT_BRANCH"
echo "   Last commit: $GIT_COMMIT"
echo "   Last modified: $(date +%Y-%m-%d)"
