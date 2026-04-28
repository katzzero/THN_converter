import Foundation
import AppKit

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

class VideoConverter: ObservableObject {
    private var process: Process?
    
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
        let outPipe = Pipe()
        process?.standardOutput = outPipe
        
        try process?.run()
        
        errPipe.fileHandleForReading.readabilityHandler = { fileHandle in
            let data = fileHandle.availableData
            if data.isEmpty { return }
            if let line = String(data: data, encoding: .utf8) {
                onOutput("[ERROR] " + line)
            }
        }
        
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
    
    private func getTimecodeFilter(position: String) -> String {
        let fontColor = "white"
        let fontSize = "24"
        let boxColor = "black@0.7"
        let fontPath = "/System/Library/Fonts/Helvetica.ttc"
        
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
    
    private func parseProgress(_ line: String, onProgress: @escaping (Double) -> Void) {
        if line.contains("time=") {
            let components = line.components(separatedBy: "time=")
            if components.count > 1 {
                let timeComponent = components[1].components(separatedBy: " ")[0]
                let timeParts = timeComponent.components(separatedBy: ":")
                if timeParts.count == 3 {
                    if let h = Double(timeParts[0]), let m = Double(timeParts[1]), let s = Double(timeParts[2]) {
                        let currentTime = h * 3600 + m * 60 + s
                        onProgress(currentTime / 36000)
                    }
                }
            }
        }
    }
    
    private func findFFmpeg() -> String {
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
    
    func cancel() {
        process?.terminate()
    }
}
