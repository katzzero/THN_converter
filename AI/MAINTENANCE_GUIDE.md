# AI Sync Guide: 3-Branch Feature Parity

This project has **3 independent implementations** across **3 branches** that must remain **feature-equal**. Whenever you add, modify, or fix a feature in one implementation, you **must replicate the change** in the other two.

---

## Branch Architecture

| Branch | Implementation | Language | UI Framework | Platform |
|--------|--------------|----------|-------------|----------|
| `main` | macOS native | Swift | SwiftUI | macOS |
| `main` | Cross-platform | Python | CustomTkinter | macOS / Linux |
| `win` | Windows native | C# | WPF (.NET 8) | Windows |

All three branches share a single `/AI` directory with documentation guides. Updates to AI guides happen on the branch where the change is made.

---

## File Mapping Across Implementations

When a file changes in one implementation, the corresponding files in the other implementations need parallel updates.

### Conversion Logic

| Swift (main) | Python (main) | C# (win) |
|---|---|---|
| `VideoConverter.swift` — `convert()` | `thn_converter.py` — `VideoConverter.convert()` | `Services/FfmpegService.cs` — `Convert()` |
| `VideoConverter.swift` — `parseProgress()` | `thn_converter.py` — inline in `convert()` | `Services/FfmpegService.cs` — `ParseProgress()` |
| `VideoConverter.swift` — `getTimecodeFilter()` | `thn_converter.py` — `get_timecode_filter()` | `Services/FfmpegService.cs` — `GetTimecodeFilter()` |
| `VideoConverter.swift` — `findFFmpeg()` | `thn_converter.py` — `find_ffmpeg()` | `Services/FfmpegService.cs` — `FindFfmpeg()` |
| `VideoConverter.swift` — `findAvailableFont()` | `thn_converter.py` — `_find_available_font()` | `Services/FfmpegService.cs` — `FindAvailableFont()` |
| `VideoConverter.swift` — `cancel()` | `thn_converter.py` — `cancel()` | `Services/FfmpegService.cs` — `Cancel()` |

### Metadata Extraction Logic

| Swift (main) | Python (main) | C# (win) |
|---|---|---|
| `VideoConverter.swift` — `extractMetadata()` | **NOT IMPLEMENTED** | `Services/MetadataService.cs` — `ExtractMetadataAsync()` |
| `VideoConverter.swift` — `parseFFmpegMetadata()` | **NOT IMPLEMENTED** | `Services/MetadataService.cs` — `ParseFfmpegOutput()` |
| `VideoConverter.swift` — `parseVideoStream()` | **NOT IMPLEMENTED** | `Services/MetadataService.cs` — `ParseVideoStream()` |
| `VideoConverter.swift` — `parseAudioStream()` | **NOT IMPLEMENTED** | `Services/MetadataService.cs` — `ParseAudioStream()` |
| `VideoConverter.swift` — `parseSubtitleStream()` | **NOT IMPLEMENTED** | `Services/MetadataService.cs` — `ParseSubtitleStream()` |
| `VideoConverter.swift` — `parseDataStream()` | **NOT IMPLEMENTED** | `Services/MetadataService.cs` — `ParseDataStream()` |
| `VideoConverter.swift` — `extractColorSpaceInfo()` | **NOT IMPLEMENTED** | `Services/MetadataService.cs` — `ExtractColorSpace()` |
| `VideoConverter.swift` — `hdrFormat()` | **NOT IMPLEMENTED** | `Services/MetadataService.cs` — inline in `ExtractColorSpace()` |
| `VideoConverter.swift` — `parseDuration()` | **NOT IMPLEMENTED** | `Services/MetadataService.cs` — inline in `ParseFfmpegOutput()` |

### Data Models

| Swift (main) | Python (main) | C# (win) |
|---|---|---|
| `VideoConverter.swift` — `ConversionSettings` | `thn_converter.py` — `ConversionSettings` class | `Models/ConversionSettings.cs` |
| `VideoConverter.swift` — `VideoMetadata` | **NOT IMPLEMENTED** | `Models/VideoMetadata.cs` |
| `VideoConverter.swift` — `VideoStreamInfo` | **NOT IMPLEMENTED** | `Models/StreamInfo.cs` |
| `VideoConverter.swift` — `AudioStreamInfo` | **NOT IMPLEMENTED** | `Models/StreamInfo.cs` |
| `VideoConverter.swift` — `SubtitleStreamInfo` | **NOT IMPLEMENTED** | `Models/StreamInfo.cs` |
| `VideoConverter.swift` — `DataStreamInfo` | **NOT IMPLEMENTED** | `Models/StreamInfo.cs` |
| `VideoConverter.swift` — `ColorSpaceInfo` | **NOT IMPLEMENTED** | `Models/ColorSpaceInfo.cs` |

### UI / View Layer

| Swift (main) | Python (main) | C# (win) |
|---|---|---|
| `ContentView.swift` — body (4 tabs) | `thn_converter.py` — `ConverterApp` (3 tabs, no Info tab) | `MainWindow.xaml` (4 tabs) |
| `ContentView.swift` — `handleDrop()` | `thn_converter.py` — `select_file()` | `MainWindow.xaml.cs` — `Window_Drop()` |
| `ContentView.swift` — `selectInputFile()` | `thn_converter.py` — `select_file()` (same) | `MainWindow.xaml.cs` — `DropZone_MouseDown()` |
| `ContentView.swift` — `selectOutputFile()` | `thn_converter.py` — `select_output_file()` | `MainWindow.xaml.cs` — calls `SelectOutputCommand` |
| `ContentView.swift` — `convertVideo()` | `thn_converter.py` — `start_conversion()` | `ViewModels/MainViewModel.cs` — `ConvertAsync()` |
| `ContentView.swift` — `cancelConversion()` | `thn_converter.py` — called via button in `start_conversion()` | `ViewModels/MainViewModel.cs` — `CancelConversion()` |
| `ContentView.swift` — `fetchMetadata()` | **NOT IMPLEMENTED** | `ViewModels/MainViewModel.cs` — `FetchMetadataAsync()` |
| `ContentView.swift` — `formatDuration()` | **NOT IMPLEMENTED** | `ViewModels/MainViewModel.cs` — implicit via `TimeSpan.ToString()` |
| `ContentView.swift` — `mapVideoCodec()` | `thn_converter.py` — `map_video_codec()` | `ViewModels/MainViewModel.cs` — `MapVideoCodec()` |

---

## Sync Checklist by Change Type

### 1. Adding a New Codec

Files to modify across all 3 implementations:

```
1. Swift:  ContentView.swift        → Add picker option in options tab
2. Swift:  ContentView.swift        → Add mapping in mapVideoCodec()
3. Python: thn_converter.py          → Add to option menu values
4. Python: thn_converter.py          → Add to map_video_codec() dict
5. C#:     MainWindow.xaml           → Add ComboBoxItem
6. C#:     ViewModels/MainViewModel.cs → Add to MapVideoCodec()
```

### 2. Adding a New Setting (e.g., new filter, toggle)

```
1. Swift:  ContentView.swift        → Add @State + picker/control
2. Swift:  VideoConverter.swift     → Add argument building logic in convert()
3. Python: thn_converter.py          → Add option + build argument
4. C#:     MainWindow.xaml           → Add UI control
5. C#:     ViewModels/MainViewModel.cs → Add property (INotifyPropertyChanged)
6. C#:     Services/FfmpegService.cs → Add argument building in BuildArguments()
```

### 3. Fixing a Bug in FFmpeg Argument Building

```
1. Swift:  VideoConverter.swift     → fix convert() argument order
2. Python: thn_converter.py          → fix convert() argument order  
3. C#:     Services/FfmpegService.cs → fix BuildArguments()
```

### 4. Fixing a Bug in Progress Parsing

```
1. Swift:  VideoConverter.swift     → fix parseProgress()
2. Python: thn_converter.py          → fix inline parsing in convert()
3. C#:     Services/FfmpegService.cs → fix ParseProgress()
```

### 5. Adding a Metadata Field

```
1. Swift:  VideoConverter.swift     → Add struct field + parsing logic
2. C#:     Models/*.cs               → Add field
3. C#:     Services/MetadataService.cs → Add regex + parsing
4. All:    AI/*.json                 → Update documentation
5. Note:   Python has NOT implemented metadata extraction
```

### 6. Changing UI Text / Labels

```
1. Swift:  ContentView.swift        → Update Text() strings
2. Python: thn_converter.py          → Update ctk.CTkLabel() strings
3. C#:     MainWindow.xaml           → Update TextBlock/Content strings
```

---

## Required Parallel Change Pattern

When a change is requested, use this order:

```
Step 1:  Swift implementation  (main branch)
Step 2:  Python implementation (main branch)
Step 3:  C# implementation     (win branch)
Step 4:  Update AI/*.json guides  (on applicable branch)
Step 5:  Verify syntax/compile for all 3
```

If the change is **only relevant to one platform** (e.g., a macOS-specific UI behavior), still check the other implementations for equivalent behavior and add a comment or `NOT_IMPLEMENTED` note.

---

## Python Metadata Extraction Gap

The Python implementation is **missing the entire metadata extraction feature** that exists in Swift and C#. Key missing functions:

- `extractMetadata()` / metadata extraction from FFmpeg
- `parseFFmpegMetadata()` and all 6 stream parsers
- `VideoMetadata`, `VideoStreamInfo`, `AudioStreamInfo`, etc. data classes
- Info tab in the UI

If someone adds metadata extraction to Python, they should follow the exact same regex patterns and logic from:
- Swift: `VideoConverter.swift` `parseFFmpegMetadata()` and sub-parsers
- C#: `Services/MetadataService.cs` (has `[GeneratedRegex]` versions of all patterns)

---

## AI Guide Update Protocol

When any feature changes, the `/AI/*.json` guides must be updated:

| Guide | When to Update |
|---|---|
| `thn_converter_manifest.json` | Any structural change (new files, new dependencies, new features) |
| `project_structure_guide.json` | File additions/removals, architecture changes, new dependencies |
| `metadata_extraction_guide.json` | Changes to metadata parsing logic, new fields, new edge cases |

**Update rules:**
- `last_modified` → set to today's date
- `git_state.branch` → match current branch
- `git_state.last_commit_msg` → describe the change
- For new features: add a `csharp_port` or `python_port` section if applicable
- For file references: verify all filenames are correct (`.json` suffix, proper casing)

---

## Build & Verify Commands

### Swift (main branch)
```bash
cd thn-converter/THN-Converter
xcrun swiftc -frontend -typecheck *.swift -target arm64-apple-macosx14.0 -sdk $(xcrun --show-sdk-path --sdk macosx)
```

### Python (main branch)
```bash
cd THN-Converter-Python
python3 -m py_compile thn_converter.py
```

### C# (win branch)
```bash
cd win/THN-Converter-Win
dotnet build -c Release
# or for single-file publish:
dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true
```

### JSON Validation
```bash
cd AI
for f in *.json; do python3 -m json.tool "$f" > /dev/null && echo "OK: $f" || echo "FAIL: $f"; done
```

---

## Quick Reference: Same Concept, Different Syntax

| Concept | Swift | Python | C# |
|---------|-------|--------|-----|
| Async operation | `async func` / `await` | `threading.Thread` | `async Task` / `await` |
| Progress callback | `@escaping (Double) -> Void` | Function parameter | `IProgress<double>` |
| Observable property | `@Published` / `@State` | `tk.StringVar` | `INotifyPropertyChanged` |
| Regex | `NSRegularExpression` / `.range(of:options:)` | `re.search()` / `re.match()` | `[GeneratedRegex]` / `Regex.Match()` |
| Process execution | `Process()` | `subprocess.Popen` | `System.Diagnostics.Process` |
| File dialog | `NSOpenPanel` / `NSSavePanel` | `filedialog.askopenfilename` | `Microsoft.Win32.OpenFileDialog` |
| Option/picker | `Picker` with `.tag()` | `CTkOptionMenu` | `ComboBox` |
| Progress bar | `ProgressView` | `CTkProgressBar` | `ProgressBar` (WPF) |
| Font fallback | Array of `/System/Library/Fonts/*` paths | Same macOS paths | Array of `C:\Windows\Fonts\*` paths |

---

*This guide is maintained in `/AI/MAINTENANCE_GUIDE.md`. Update it whenever the project structure changes significantly.*
