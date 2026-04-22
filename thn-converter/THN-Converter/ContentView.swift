import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var droppedFileURL: URL?
    @State private var isConverting = false
    @State private var conversionProgress: Double = 0
    @State private var statusMessage = "Arraste um arquivo de vídeo aqui"
    @State private var logOutput = ""
    
    @State private var outputURL: URL?
    
    // Video settings
    @State private var selectedVideoCodec = "H.264"
    @State private var selectedQuality = "23"
    @State private var selectedResolution = "Original"
    @State private var selectedFramerate = "Original"
    
    // Audio settings
    @State private var selectedAudioCodec = "copy"
    @State private var selectedAudioBitrate = "192k"
    @State private var selectedAudioSampleRate = "48000"
    
    // Overlay settings
    @State private var showTimecode = true
    @State private var timecodePosition = "bottom-center"
    
    var body: some View {
        TabView {
            // ====== TAB 1: Principal ======
            VStack(spacing: 20) {
                // Drop zone
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.secondary.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [10]))
                        .foregroundColor(isConverting ? .gray : .blue)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.05))
                        )
                    
                    VStack(spacing: 12) {
                        Image(systemName: "film")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                        
                        Text(statusMessage)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let file = droppedFileURL {
                            Text(file.lastPathComponent)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(40)
                }
                .frame(height: 200)
                .onDrop(of: ["public.movie", "public.video", "public.quicktime-movie", "public.mpeg-4", "com.microsoft.avi"], isTargeted: nil) { providers in
                    handleDrop(providers: providers)
                    return true
                }
                .disabled(isConverting)
                
                // Output selection
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("💾 Destino da Conversão")
                            .font(.headline)
                        
                        if let fileURL = outputURL {
                            Text(fileURL.lastPathComponent)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Clique para escolher destino")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button("📁 Selecionar Destino") {
                        selectOutputFile()
                    }
                    .disabled(isConverting)
                }
                .padding(.horizontal)
                
                // Progress
                VStack(spacing: 8) {
                    ProgressView(value: conversionProgress)
                        .progressViewStyle(.linear)
                        .frame(maxWidth: .infinity)
                    
                    Text(String(format: "%.1f%%", conversionProgress * 100))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Convert button
                Button(action: convertVideo) {
                    HStack {
                        Image(systemName: isConverting ? "arrow.triangle.2.circlepath" : "arrow.down.circle")
                        Text(isConverting ? "Convertendo..." : "Converter")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isConverting ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(droppedFileURL == nil || isConverting)
                
                Spacer()
            }
            .padding(30)
            .tabItem {
                Label("Principal", systemImage: "gear")
            }
            
            // ====== TAB 2: Opções ======
            ScrollView {
                VStack(spacing: 20) {
                    // Video Settings
                    GroupBox("🎬 Vídeo") {
                        VStack(spacing: 12) {
                            HStack {
                                Text("Codec:").frame(width: 80, alignment: .leading)
                                Picker("", selection: $selectedVideoCodec) {
                                    Text("H.264").tag("H.264")
                                    Text("H.265/HEVC").tag("H.265/HEVC")
                                    Text("ProRes").tag("ProRes")
                                    Text("DNxHD").tag("DNxHD")
                                    Text("VP9").tag("VP9")
                                    Text("MPEG-4").tag("MPEG-4")
                                }
                                .pickerStyle(.menu)
                            }
                            
                            HStack {
                                Text("Qualidade:").frame(width: 80, alignment: .leading)
                                Picker("", selection: $selectedQuality) {
                                    Text("0 (Highest)").tag("0")
                                    Text("10").tag("10")
                                    Text("15").tag("15")
                                    Text("20").tag("20")
                                    Text("23 (Default)").tag("23")
                                    Text("28").tag("28")
                                    Text("35").tag("35")
                                    Text("50 (Lowest)").tag("50")
                                }
                                .pickerStyle(.menu)
                            }
                            
                            HStack {
                                Text("Resolução:").frame(width: 80, alignment: .leading)
                                Picker("", selection: $selectedResolution) {
                                    Text("Original").tag("Original")
                                    Text("3840x2160 (4K)").tag("3840x2160")
                                    Text("1920x1080 (Full HD)").tag("1920x1080")
                                    Text("1280x720 (HD)").tag("1280x720")
                                    Text("854x480 (SD)").tag("854x480")
                                }
                                .pickerStyle(.menu)
                            }
                            
                            HStack {
                                Text("Framerate:").frame(width: 80, alignment: .leading)
                                Picker("", selection: $selectedFramerate) {
                                    Text("Original").tag("Original")
                                    Text("60").tag("60")
                                    Text("59.94").tag("59.94")
                                    Text("30").tag("30")
                                    Text("29.97").tag("29.97")
                                    Text("24").tag("24")
                                    Text("23.976").tag("23.976")
                                }
                                .pickerStyle(.menu)
                            }
                        }
                    }
                    
                    // Audio Settings
                    GroupBox("🔊 Áudio") {
                        VStack(spacing: 12) {
                            HStack {
                                Text("Codec:").frame(width: 80, alignment: .leading)
                                Picker("", selection: $selectedAudioCodec) {
                                    Text("copy (não converter)").tag("copy")
                                    Text("AAC").tag("AAC")
                                    Text("MP3").tag("MP3")
                                    Text("Opus").tag("Opus")
                                    Text("Vorbis").tag("Vorbis")
                                    Text("FLAC").tag("FLAC")
                                    Text("PCM").tag("PCM")
                                }
                                .pickerStyle(.menu)
                            }
                            
                            if selectedAudioCodec != "copy" {
                                HStack {
                                    Text("Bitrate:").frame(width: 80, alignment: .leading)
                                    Picker("", selection: $selectedAudioBitrate) {
                                        Text("320k").tag("320k")
                                        Text("256k").tag("256k")
                                        Text("192k").tag("192k")
                                        Text("128k").tag("128k")
                                        Text("96k").tag("96k")
                                    }
                                    .pickerStyle(.menu)
                                }
                                
                                HStack {
                                    Text("Sample Rate:").frame(width: 80, alignment: .leading)
                                    Picker("", selection: $selectedAudioSampleRate) {
                                        Text("48000").tag("48000")
                                        Text("44100").tag("44100")
                                        Text("96000").tag("96000")
                                    }
                                    .pickerStyle(.menu)
                                }
                            }
                        }
                    }
                    
                    // Timecode Overlay
                    GroupBox("⏱️ Timecode Overlay") {
                        VStack(spacing: 12) {
                            Toggle("Mostrar Timecode", isOn: $showTimecode)
                            
                            if showTimecode {
                                HStack {
                                    Text("Posição:").frame(width: 80, alignment: .leading)
                                    Picker("", selection: $timecodePosition) {
                                        Text("Superior Esquerdo").tag("top-left")
                                        Text("Superior Centro").tag("top-center")
                                        Text("Superior Direito").tag("top-right")
                                        Text("Inferior Esquerdo").tag("bottom-left")
                                        Text("Inferior Centro").tag("bottom-center")
                                        Text("Inferior Direito").tag("bottom-right")
                                    }
                                    .pickerStyle(.menu)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 10)
            }
            .padding(30)
            .tabItem {
                Label("Opções", systemImage: "slider.horizontal.3")
            }
            
            // ====== TAB 3: Log ======
            VStack(alignment: .leading, spacing: 10) {
                Text("📋 Log de Conversão")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                TextEditor(text: $logOutput)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(minHeight: 400)
                    .padding()
                    .border(Color.gray.opacity(0.3))
                
                Spacer()
            }
            .padding(30)
            .tabItem {
                Label("Log", systemImage: "list.bullet")
            }
        }
        .frame(minWidth: 700, minHeight: 650)
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        guard let provider = providers.first else { return }
        
        provider.loadItem(forTypeIdentifier: "public.movie", options: nil) { item, error in
            if let url = item as? URL {
                DispatchQueue.main.async {
                    droppedFileURL = url
                    statusMessage = "Arquivo pronto para conversão"
                }
            }
        }
    }
    
    private func selectOutputFile() {
        let panel = NSSavePanel()
        if let fileURL = droppedFileURL {
            panel.nameFieldStringValue = fileURL.deletingPathExtension().lastPathComponent + "_converted.mp4"
        } else {
            panel.nameFieldStringValue = "video_converted.mp4"
        }
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                outputURL = url
            }
        }
    }
    
    private func convertVideo() {
        guard let inputURL = droppedFileURL else { return }
        
        isConverting = true
        conversionProgress = 0
        statusMessage = "Convertendo..."
        
        Task {
            do {
                let converter = VideoConverter()
                
                let finalOutputURL: URL
                if let fileURL = outputURL {
                    finalOutputURL = fileURL
                } else {
                    let downloadDir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
                    finalOutputURL = downloadDir.appendingPathComponent(inputURL.deletingPathExtension().lastPathComponent + "_converted.mp4")
                    
                    outputURL = finalOutputURL
                }
                
                let settings = ConversionSettings(
                    videoCodec: mapVideoCodec(selectedVideoCodec),
                    quality: selectedQuality,
                    resolution: selectedResolution,
                    framerate: selectedFramerate,
                    audioCodec: selectedAudioCodec,
                    audioBitrate: selectedAudioBitrate,
                    audioSampleRate: selectedAudioSampleRate,
                    addTimecode: showTimecode,
                    timecodePosition: timecodePosition,
                    outputPath: finalOutputURL.path
                )
                
                try await converter.convert(
                    inputURL: inputURL,
                    settings: settings,
                    onProgress: { progress in
                        DispatchQueue.main.async {
                            conversionProgress = progress
                        }
                    },
                    onOutput: { output in
                        DispatchQueue.main.async {
                            logOutput.append(output + "\n")
                        }
                    }
                )
                
                DispatchQueue.main.async {
                    statusMessage = "✅ Conversão concluída!"
                    isConverting = false
                }
            } catch {
                DispatchQueue.main.async {
                    statusMessage = "❌ Erro: \(error.localizedDescription)"
                    isConverting = false
                }
            }
        }
    }
    
    private func mapVideoCodec(_ codec: String) -> String {
        switch codec {
        case "H.264": return "libx264"
        case "H.265/HEVC": return "libx265"
        case "ProRes": return "prores_ks"
        case "DNxHD": return "dnxhd"
        case "VP9": return "libvpx-vp9"
        case "MPEG-4": return "mpeg4"
        default: return "libx264"
        }
    }
}
