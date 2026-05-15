import Foundation
import AppKit

extension Array {
    public func safeIndex(_ index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct ConversionSettings {
    let videoCodec: String
    let quality: String
    let resolution: String
    let framerate: String
    let audioCodec: String
    let audioBitrate: String
    let audioSampleRate: String
    let addTimecode: Bool
    let timecodePosition: String
    let outputPath: String
}

struct VideoMetadata {
    var filename: String
    var duration: TimeInterval = 0
    var bitrate: Int?
    var container: String?
    var videoStreams: [VideoStreamInfo] = []
    var audioStreams: [AudioStreamInfo] = []
    var subtitleStreams: [SubtitleStreamInfo] = []
    var dataStreams: [DataStreamInfo] = []
    var timecode: String?
    var colorSpaceInfo: ColorSpaceInfo?
    var extras: [String: String] = [:]
    var error: String?
}

struct VideoStreamInfo {
    var index: Int
    var codec: String
    var profile: String
    var resolution: String
    var pixelFormat: String
    var frameRate: String
    var bitrate: Int?
    var sar: String
    var dar: String
    var colorRange: String?
    var colorSpace: String?
    var colorPrimaries: String?
    var colorTransfer: String?
    var isHDR: Bool = false
}

struct AudioStreamInfo {
    var index: Int
    var codec: String
    var sampleRate: Int
    var channels: String
    var bitrate: Int?
    var language: String?
}

struct SubtitleStreamInfo {
    var index: Int
    var codec: String
    var language: String?
}

struct DataStreamInfo {
    var index: Int
    var type: String
    var codec: String?
}

struct ColorSpaceInfo {
    var range: String
    var space: String
    var primaries: String
    var transfer: String
    var isHDR: Bool
    var hdrFormat: String?
}

class VideoConverter: ObservableObject {
    private var process: Process?
    private var duration: TimeInterval = 0
    
    func convert(
        inputURL: URL,
        settings: ConversionSettings,
        onProgress: @escaping (Double) -> Void,
        onOutput: @escaping (String) -> Void
    ) async throws {
        // Determine output path
        let outputURL: URL
        if !settings.outputPath.isEmpty {
            outputURL = URL(fileURLWithPath: settings.outputPath)
        } else {
            let fileManager = FileManager.default
            let outputDir = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
            let outputFilename = inputURL.deletingPathExtension().lastPathComponent + "_converted.mp4"
            outputURL = outputDir.appendingPathComponent(outputFilename)
        }
        
        // Ensure parent directory exists
        let fileManager = FileManager.default
        let parentDir = outputURL.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: parentDir.path) {
            do {
                try fileManager.createDirectory(at: parentDir, withIntermediateDirectories: true)
                onOutput("Diretório criado: \(parentDir.path)\n")
            } catch {
                throw NSError(domain: "VideoConverter", code: 2, userInfo: [NSLocalizedDescriptionKey: "Erro ao criar diretório de saída: \(error.localizedDescription)"])
            }
        }
        
        // Check write permission
        if !fileManager.isWritableFile(atPath: parentDir.path) {
            throw NSError(domain: "VideoConverter", code: 4, userInfo: [NSLocalizedDescriptionKey: "Sem permissão de escrita em: \(parentDir.path)"])
        }
        
        // Remove existing file if it exists
        if fileManager.fileExists(atPath: outputURL.path) {
            do {
                try fileManager.removeItem(at: outputURL)
                onOutput("Arquivo antigo sobrescrito: \(outputURL.lastPathComponent)\n")
            } catch {
                throw NSError(domain: "VideoConverter", code: 3, userInfo: [NSLocalizedDescriptionKey: "Erro ao sobrescrever arquivo existente: \(error.localizedDescription)"])
            }
        }
        
        var args: [String] = []
        
        // Overwrite output without asking
        args.append("-y")
        
        // Input file
        args.append("-i")
        args.append(inputURL.path)
        
        // Video codec settings
        args.append("-c:v")
        args.append(settings.videoCodec)
        
        if settings.videoCodec == "libx264" || settings.videoCodec == "libx265" {
            args.append("-preset")
            args.append("medium")
            args.append("-crf")
            args.append(settings.quality)
        } else if settings.videoCodec == "prores_ks" {
            args.append("-profile")
            args.append("3")  // ProRes 422 HQ
        }
        
        // Build video filters (resolution + timecode)
        var vfFilters: [String] = []
        
        if settings.resolution != "Original" {
            let resolution = settings.resolution.components(separatedBy: " ")[0]
            vfFilters.append("scale=\(resolution)")
        }
        
        if settings.addTimecode {
            vfFilters.append(getTimecodeFilter(position: settings.timecodePosition))
        }
        
        if !vfFilters.isEmpty {
            args.append("-vf")
            args.append(vfFilters.joined(separator: ","))
        }
        
        // Framerate
        if settings.framerate != "Original" {
            args.append("-r")
            args.append(settings.framerate)
        }
        
        // Audio codec settings
        args.append("-c:a")
        args.append(settings.audioCodec)
        
        if settings.audioCodec != "copy" {
            args.append("-b:a")
            args.append(settings.audioBitrate)
            args.append("-ar")
            args.append(settings.audioSampleRate)
        }
        
        // Output file
        args.append(outputURL.path)
        
        onOutput("Iniciando conversão...\n")
        onOutput("Entrada: \(inputURL.path)\n")
        onOutput("Saída: \(outputURL.path)\n")
        onOutput("Caminho absoluta: \(outputURL.absoluteString)\n")
        onOutput("Codec: \(settings.videoCodec) | Qualidade: \(settings.quality)\n")
        onOutput("Áudio: \(settings.audioCodec)\n\n")
        
        onOutput("Comando FFmpeg: \(args.joined(separator: " "))\n")
        
        process = Process()
        process?.executableURL = URL(fileURLWithPath: findFFmpeg())
        process?.arguments = args
        
        let errPipe = Pipe()
        process?.standardError = errPipe
        
        errPipe.fileHandleForReading.readabilityHandler = { fileHandle in
            let data = fileHandle.availableData
            if data.isEmpty { return }
            if let line = String(data: data, encoding: .utf8) {
                onOutput("[ERROR] " + line)
            }
        }
        
        let outPipe = Pipe()
        process?.standardOutput = outPipe
        
        try process?.run()
        
        duration = 0  // Reset duration
        
        outPipe.fileHandleForReading.readabilityHandler = { fileHandle in
            let data = fileHandle.availableData
            if data.isEmpty { return }
            if let line = String(data: data, encoding: .utf8) {
                onOutput(line)
                self.parseProgress(line, onProgress: onProgress)
            }
        }
        
        process?.waitUntilExit()
        
        let exitCode = process?.terminationStatus ?? -1
        if exitCode == 0 {
            onProgress(1.0)
            onOutput("\n✅ Conversão concluída! Arquivo salvo em: \(outputURL.path)\n")
        } else {
            let errorMsg = "FFmpeg falhou com código \(exitCode). Verifique se o caminho de saída é válido e tem permissões de escrita."
            onOutput("\n❌ Erro: \(errorMsg)\n")
            throw NSError(domain: "VideoConverter", code: Int(exitCode), userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
    
    private func parseProgress(_ line: String, onProgress: @escaping (Double) -> Void) {
        // Parse Duration from FFmpeg output (like Python does)
        if duration == 0 && line.contains("Duration:") {
            let parts = line.components(separatedBy: "Duration: ")[1].components(separatedBy: ",")[0]
            let timeParts = parts.components(separatedBy: ":")
            if timeParts.count >= 3 {
                if let h = Double(timeParts[0]), let m = Double(timeParts[1]) {
                    let s = Double(timeParts[2]) ?? 0
                    duration = h * 3600 + m * 60 + s
                }
            }
        }
        
        // Parse current time and calculate progress
        if line.contains("time=") {
            let components = line.components(separatedBy: "time=")
            if components.count > 1 {
                let timeComponent = components[1].components(separatedBy: " ")[0]
                let timeParts = timeComponent.components(separatedBy: ":")
                if timeParts.count == 3 {
                    if let h = Double(timeParts[0]), let m = Double(timeParts[1]), let s = Double(timeParts[2]) {
                        let currentTime = h * 3600 + m * 60 + s
                        if duration > 0 {
                            onProgress(min(currentTime / duration, 1.0))
                        }
                     }
                 }
             }
         }
}
      
      func extractMetadata(from inputURL: URL) async throws -> VideoMetadata {
          return try await withCheckedThrowingContinuation { continuation in
              let process = Process()
              let pipe = Pipe()
              
              process.executableURL = URL(fileURLWithPath: findFFmpeg())
              process.arguments = ["-i", inputURL.path]
              process.standardOutput = pipe
              process.standardError = pipe
              
              var output = ""
              
              let pipeData = pipe.fileHandleForReading
              pipeData.readabilityHandler = { pipeData in
                  let data = pipeData.availableData
                  if let line = String(data: data, encoding: .utf8) {
                      output += line
                  }
              }
              
              process.terminationHandler = { process in
                  pipe.fileHandleForReading.readabilityHandler = nil
                  
                  let metadata = self.parseFFmpegMetadata(output, filename: inputURL.lastPathComponent)
                  continuation.resume(returning: metadata)
              }
              
              try? process.run()
          }
      }
      
      func parseFFmpegMetadata(_ output: String, filename: String) -> VideoMetadata {
        var metadata = VideoMetadata(filename: filename)
        let lines = output.components(separatedBy: .newlines)
        
        for line in lines {
            if line.contains("Duration:") {
                if let durationStr = line.components(separatedBy: "Duration: ").safeIndex(1)?.components(separatedBy: ",")[0] {
                    metadata.duration = parseDuration(durationStr)
                }
                if let bitrateStr = line.components(separatedBy: "bitrate: ").safeIndex(1)?.components(separatedBy: " ")[0] {
                    metadata.bitrate = Int(bitrateStr)
                }
            }
            
            if line.contains("Input #0,") {
                let containerParts = line.components(separatedBy: "Input #0, ")
                if containerParts.count > 1 {
                    metadata.container = containerParts[1].components(separatedBy: ",")[0].trimmingCharacters(in: .whitespaces)
                }
            }
            
            if line.contains("Stream #0:") {
                if line.contains("Video:") {
                    if let streamInfo = parseVideoStream(line) {
                        metadata.videoStreams.append(streamInfo)
                    }
                } else if line.contains("Audio:") {
                    if let streamInfo = parseAudioStream(line) {
                        metadata.audioStreams.append(streamInfo)
                    }
                } else if line.contains("Subtitle:") {
                    if let streamInfo = parseSubtitleStream(line) {
                        metadata.subtitleStreams.append(streamInfo)
                    }
                } else if line.contains("Data:") {
                    if let streamInfo = parseDataStream(line) {
                        metadata.dataStreams.append(streamInfo)
                    }
                }
            }
            
            _ = line.contains("timecode") && line.contains(":")
        }
        
        if !metadata.videoStreams.isEmpty {
            if let firstVideo = metadata.videoStreams.first {
                if let streamLine = lines.first(where: { $0.contains("Stream #0:") && $0.contains("Video:") && ($0.contains(firstVideo.codec)) }) {
                    if let timecodeMatch = streamLine.range(of: "timecode\\s*:\\s*([\\d:;]+)", options: .regularExpression) {
                        metadata.timecode = String(streamLine[timecodeMatch]).trimmingCharacters(in: .whitespaces)
                    }
                }
            }
        }
        
        metadata.colorSpaceInfo = extractColorSpaceInfo(lines)
        
        return metadata
    }
    
    // Helper function to determine HDR format
    func hdrFormat(from transfer: String?, primaries: String?) -> String? {
        guard let transfer = transfer, let primaries = primaries else { return nil }
        
        if transfer == "smpte2084" {
            return "HDR10"
        } else if transfer == "hlg" {
            return "Hybrid Log-Gamma"
        } else if primaries == "smpte431" || primaries == "smpte432" {
            return "HDR (Unknown Format)"
        }
        
        return nil
     }
     
     func cancel() {
         process?.terminate()
     }
 
     func parseDuration(_ durationStr: String) -> TimeInterval {
        let parts = durationStr.components(separatedBy: ":")
        guard parts.count >= 3 else { return 0 }
        
        let h = Double(parts[0]) ?? 0
        let m = Double(parts[1]) ?? 0
        let s = Double(parts[2]) ?? 0
        
        return h * 3600 + m * 60 + s
    }
    
    func parseVideoStream(_ line: String) -> VideoStreamInfo? {
        var info = VideoStreamInfo(index: 0, codec: "", profile: "", resolution: "", pixelFormat: "", frameRate: "", bitrate: nil, sar: "N/A", dar: "N/A")
        
        let indexPattern = "Stream #0:(\\d+)"
        if let range = line.range(of: indexPattern, options: .regularExpression) {
            let extracted = String(line[range])
            if let numStr = Int(extracted.components(separatedBy: ":").last!) {
                info.index = numStr
            }
        }
        
        let codecPattern = "Video: ([a-z0-9]+)"
        if let range = line.range(of: codecPattern, options: .regularExpression) {
            let extracted = String(line[range])
            info.codec = extracted.components(separatedBy: "Video: ").last ?? ""
        }
        
        if let openParen = line.range(of: "\\("), let closeParen = line.range(of: "\\)") {
            let profileStart = line.index(openParen.upperBound, offsetBy: 0)
            let profileEnd = line.index(closeParen.lowerBound, offsetBy: 0)
            info.profile = String(line[profileStart..<profileEnd]).trimmingCharacters(in: .whitespaces)
        }
        
        let resPattern = "(\\d+)x(\\d+)"
        if let range = line.range(of: resPattern, options: .regularExpression) {
            let extracted = String(line[range])
            info.resolution = extracted
        }
        
        let pixelPattern = "([a-z0-9]+)(?:\\([^)]+\\))?"
        if let range = line.range(of: pixelPattern, options: .regularExpression) {
            let extracted = String(line[range]).trimmingCharacters(in: .whitespaces)
            if !extracted.isEmpty && extracted != "," {
                info.pixelFormat = extracted
            }
        }
        
        if line.contains(" fps") {
            let parts = line.components(separatedBy: " fps")
            if let rateStr = parts.first?.components(separatedBy: " ").last {
                info.frameRate = rateStr.trimmingCharacters(in: .whitespaces) + " fps"
            }
        }
        
        let bitratePattern = "(\\d+) kb/s"
        if let range = line.range(of: bitratePattern, options: .regularExpression) {
            let extracted = String(line[range]).components(separatedBy: " ")[0]
            info.bitrate = Int(extracted)
        }
        
        let sarPattern = "SAR (\\d+):(\\d+)"
        if let range = line.range(of: sarPattern, options: .regularExpression) {
            let extracted = String(line[range]).components(separatedBy: "SAR ").last!
            info.sar = extracted
        } else {
            info.sar = "N/A"
        }
        
        let darPattern = "DAR (\\d+):(\\d+)"
        if let range = line.range(of: darPattern, options: .regularExpression) {
            let extracted = String(line[range]).components(separatedBy: "DAR ").last!
            info.dar = extracted
        } else {
            info.dar = "N/A"
        }
        
        let colorPattern = "(tv|pc), (\\w{2,6})"
        if let range = line.range(of: colorPattern, options: .regularExpression) {
            let extracted = String(line[range])
            let parts = extracted.components(separatedBy: ", ")
            if parts.count >= 2 {
                info.colorRange = parts[0]
                info.colorSpace = parts[1]
            }
        }
        
        let primariesPattern = "(bt709|bt2020|smpte431|smpte432|bt601)"
        if let range = line.range(of: primariesPattern, options: .regularExpression) {
            info.colorPrimaries = String(line[range])
        }
        
        let transferPattern = "(bt709|smpte2084|hlg)"
        if let range = line.range(of: transferPattern, options: .regularExpression) {
            info.colorTransfer = String(line[range])
        }
        
        // Check for HDR using helper function
        if let hdrFormat = hdrFormat(from: info.colorTransfer, primaries: info.colorPrimaries) {
            info.isHDR = true
        }
        
        return info
    }
    
    func parseAudioStream(_ line: String) -> AudioStreamInfo? {
        var info = AudioStreamInfo(index: 0, codec: "", sampleRate: 0, channels: "", bitrate: nil)
        
        let indexPattern = "Stream #0:(\\d+)"
        if let range = line.range(of: indexPattern, options: .regularExpression) {
            let extracted = String(line[range])
            if let numStr = Int(extracted.components(separatedBy: ":").last!) {
                info.index = numStr
            }
        }
        
        let codecPattern = "Audio: ([a-z0-9]+)"
        if let range = line.range(of: codecPattern, options: .regularExpression) {
            let extracted = String(line[range])
            info.codec = extracted.components(separatedBy: "Audio: ").last ?? ""
        }
        
        let sampleRatePattern = "(\\d+) Hz"
        if let range = line.range(of: sampleRatePattern, options: .regularExpression) {
            let extracted = String(line[range]).components(separatedBy: " Hz")[0]
            info.sampleRate = Int(extracted) ?? 0
        }
        
        let channelsPattern = "mono|stereo|5\\.1|5\\.1\\(|6 channels|8 channels"
        if let range = line.range(of: channelsPattern, options: .regularExpression) {
            info.channels = String(line[range])
        } else {
            info.channels = "mono"
        }
        
        let bitratePattern = "(\\d+) kb/s"
        if let range = line.range(of: bitratePattern, options: .regularExpression) {
            let extracted = String(line[range]).components(separatedBy: " ")[0]
            info.bitrate = Int(extracted)
        }
        
        if line.contains("und)") {
            info.language = "und"
        } else if let langMatch = line.range(of: "\\(([a-z]{3})\\)", options: .regularExpression) {
            let langString = String(line[langMatch])
            let trimmed = String(langString[langString.index(langString.startIndex, offsetBy: 1)..<langString.index(langString.endIndex, offsetBy: -1)])
            info.language = trimmed
        }
        
        return info
    }
    
    func parseSubtitleStream(_ line: String) -> SubtitleStreamInfo? {
        var info = SubtitleStreamInfo(index: 0, codec: "", language: nil)
        
        let indexPattern = "Stream #0:(\\d+)"
        if let range = line.range(of: indexPattern, options: .regularExpression) {
            let extracted = String(line[range])
            if let numStr = Int(extracted.components(separatedBy: ":").last!) {
                info.index = numStr
            }
        }
        
        let codecPattern = "Subtitle: ([a-z0-9_]+)"
        if let range = line.range(of: codecPattern, options: .regularExpression) {
            let extracted = String(line[range])
            info.codec = extracted.components(separatedBy: "Subtitle: ").last ?? ""
        }
        
        if line.contains("und)") {
            info.language = "und"
        }
        
        return info
    }
    
    func parseDataStream(_ line: String) -> DataStreamInfo? {
        var info = DataStreamInfo(index: 0, type: "", codec: nil)
        
        let indexPattern = "Stream #0:(\\d+)"
        if let range = line.range(of: indexPattern, options: .regularExpression) {
            let extracted = String(line[range])
            if let numStr = Int(extracted.components(separatedBy: ":").last!) {
                info.index = numStr
            }
        }
        
        let typePattern = "Data: ([a-z0-9_]+)"
        if let range = line.range(of: typePattern, options: .regularExpression) {
            let extracted = String(line[range])
            info.type = extracted.components(separatedBy: "Data: ").last ?? ""
            info.codec = (extracted.components(separatedBy: "Data: ").last ?? "") != "none" ? String(extracted.components(separatedBy: "Data: ").last!) : nil
        }
        
        if line.contains("tmcd") {
            info.type = "tmcd"
        } else if line.contains("timecode") {
            info.type = "timecode"
        }
        
        return info
    }
    
    func extractColorSpaceInfo(_ lines: [String]) -> ColorSpaceInfo? {
        for line in lines {
            if line.contains("tv,") || line.contains("pc,") {
                var colorInfo = ColorSpaceInfo(range: "", space: "", primaries: "", transfer: "", isHDR: false, hdrFormat: nil)
                
                let rangeMatch = "(tv|pc),"
                if let range = line.range(of: rangeMatch, options: .regularExpression) {
                    colorInfo.range = String(line[range]).trimmingCharacters(in: CharacterSet(charactersIn: ","))
                }
                
                let spaceMatch = ", ([a-z]{2,6})/"
                if let range = line.range(of: spaceMatch, options: .regularExpression) {
                    let extracted = String(line[range]).trimmingCharacters(in: CharacterSet(charactersIn: ",/"))
                    if !extracted.isEmpty {
                        colorInfo.space = extracted
                    }
                }
                
                let primariesMatch = "(bt709|bt2020|smpte431|smpte432|bt601)"
                if let range = line.range(of: primariesMatch, options: .regularExpression) {
                    colorInfo.primaries = String(line[range])
                }
                
                let transferMatch = "(bt709|smpte2084|hlg)"
                if let range = line.range(of: transferMatch, options: .regularExpression) {
                    colorInfo.transfer = String(line[range])
                }
                
            // Check for HDR using helper function
            if let hdrFormat = hdrFormat(from: colorInfo.transfer, primaries: colorInfo.primaries) {
                colorInfo.isHDR = true
                colorInfo.hdrFormat = hdrFormat
            }
                
                if !colorInfo.range.isEmpty {
                    return colorInfo
                }
            }
        }
        return nil
    }
    
    func getTimecodeFilter(position: String) -> String {
        let fontColor = "white"
        let fontSize = "24"
        let boxColor = "black@0.7"
        
        let fontPath = findAvailableFont()
        
        switch position {
        case "top-left":
            return "drawtext=text='\\%{gmtime\\:%H:%M:%S}':fontfile=\(fontPath):fontsize=\(fontSize):fontcolor=\(fontColor):box=1:boxcolor=\(boxColor):x=10:y=10"
        case "top-center":
            return "drawtext=text='\\%{gmtime\\:%H:%M:%S}':fontfile=\(fontPath):fontsize=\(fontSize):fontcolor=\(fontColor):box=1:boxcolor=\(boxColor):x=(w-tw)/2:y=10"
        case "top-right":
            return "drawtext=text='\\%{gmtime\\:%H:%M:%S}':fontfile=\(fontPath):fontsize=\(fontSize):fontcolor=\(fontColor):box=1:boxcolor=\(boxColor):x=w-tw-10:y=10"
        case "bottom-left":
            return "drawtext=text='\\%{gmtime\\:%H:%M:%S}':fontfile=\(fontPath):fontsize=\(fontSize):fontcolor=\(fontColor):box=1:boxcolor=\(boxColor):x=10:y=h-th-10"
        case "bottom-center":
            return "drawtext=text='\\%{gmtime\\:%H:%M:%S}':fontfile=\(fontPath):fontsize=\(fontSize):fontcolor=\(fontColor):box=1:boxcolor=\(boxColor):x=(w-tw)/2:y=h-th-10"
        case "bottom-right":
            return "drawtext=text='\\%{gmtime\\:%H:%M:%S}':fontfile=\(fontPath):fontsize=\(fontSize):fontcolor=\(fontColor):box=1:boxcolor=\(boxColor):x=w-tw-10:y=h-th-10"
        default:
            return "drawtext=text='\\%{gmtime\\:%H:%M:%S}':fontfile=\(fontPath):fontsize=\(fontSize):fontcolor=\(fontColor):box=1:boxcolor=\(boxColor):x=(w-tw)/2:y=h-th-10"
        }
    }
    
    func findAvailableFont() -> String {
        let fontPaths = [
            "/System/Library/Fonts/Helvetica.ttc",
            "/System/Library/Fonts/HelveticaNeue.ttc",
            "/System/Library/Fonts/SFPro.ttc",
            "/System/Library/Fonts/Arial.ttc",
            "/Library/Fonts/Arial.ttf"
        ]
        
        let fileManager = FileManager.default
        
        for path in fontPaths {
            if fileManager.fileExists(atPath: path) {
                return path
            }
        }
        
        return ""
    }
    
    func findFFmpeg() -> String {
        // Try bundle path first (included in app)
        if let bundlePath = Bundle.main.path(forResource: "ffmpeg", ofType: nil) {
            return bundlePath
        }
        
        // Fallback to system paths
        let paths = [
            "/usr/local/bin/ffmpeg",
            "/opt/homebrew/bin/ffmpeg",
            "/usr/bin/ffmpeg"
        ]
        
        for path in paths {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        
         return "/usr/bin/ffmpeg"
     }
 }
