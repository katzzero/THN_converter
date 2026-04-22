import SwiftUI

struct SettingsView: View {
    @Binding var selectedVideoCodec: String
    @Binding var selectedQuality: String
    @Binding var selectedResolution: String
    @Binding var selectedFramerate: String
    @Binding var selectedAudioCodec: String
    @Binding var selectedAudioBitrate: String
    @Binding var selectedAudioSampleRate: String
    @Binding var showTimecode: Bool
    @Binding var timecodePosition: String
    
    let videoCodecs: [String]
    let qualities: [String]
    let resolutions: [String]
    let framerates: [String]
    let audioCodecs: [String]
    let audioBitrates: [String]
    let audioSampleRates: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Configurações de Conversão")
                .font(.headline)
            
            // Video Settings
            GroupBox("Vídeo") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Codec:").frame(width: 80, alignment: .leading)
                        Picker("", selection: $selectedVideoCodec) {
                            ForEach(videoCodecs, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    HStack {
                        Text("Qualidade:").frame(width: 80, alignment: .leading)
                        Picker("", selection: $selectedQuality) {
                            ForEach(qualities, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    HStack {
                        Text("Resolução:").frame(width: 80, alignment: .leading)
                        Picker("", selection: $selectedResolution) {
                            ForEach(resolutions, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    HStack {
                        Text("Framerate:").frame(width: 80, alignment: .leading)
                        Picker("", selection: $selectedFramerate) {
                            ForEach(framerates, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)
                    }
                }
                .padding(.vertical, 8)
            }
            
        // Audio Settings
        GroupBox("Áudio") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Codec:").frame(width: 80, alignment: .leading)
                    Picker("", selection: $selectedAudioCodec) {
                        ForEach(audioCodecs, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.menu)
                }
                
                // Configurações de áudio (apenas se não for copy)
                if selectedAudioCodec != "copy" {
                    HStack {
                        Text("Bitrate:").frame(width: 80, alignment: .leading)
                        Picker("", selection: $selectedAudioBitrate) {
                            ForEach(audioBitrates, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    HStack {
                        Text("Sample Rate:").frame(width: 80, alignment: .leading)
                        Picker("", selection: $selectedAudioSampleRate) {
                            ForEach(audioSampleRates, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)
                    }
                }
            }
            .padding(.vertical, 8)
        }
            
            // Timecode Overlay
            GroupBox("Timecode Overlay") {
                VStack(alignment: .leading, spacing: 12) {
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
                    .padding(.vertical, 8)
                }
                .padding(.vertical, 8)
            }
            
            // Video Settings
            GroupBox("🎬 Vídeo") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Codec:").frame(width: 80, alignment: .leading)
                        Picker("", selection: $selectedVideoCodec) {
                            ForEach(videoCodecs, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    HStack {
                        Text("Qualidade:").frame(width: 80, alignment: .leading)
                        Picker("", selection: $selectedQuality) {
                            ForEach(qualities, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    HStack {
                        Text("Resolução:").frame(width: 80, alignment: .leading)
                        Picker("", selection: $selectedResolution) {
                            ForEach(resolutions, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    HStack {
                        Text("Framerate:").frame(width: 80, alignment: .leading)
                        Picker("", selection: $selectedFramerate) {
                            ForEach(framerates, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Audio Settings
            GroupBox("🔊 Áudio") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Codec:").frame(width: 80, alignment: .leading)
                        Picker("", selection: $selectedAudioCodec) {
                            ForEach(audioCodecs, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    if selectedAudioCodec != "copy" {
                        HStack {
                            Text("Bitrate:").frame(width: 80, alignment: .leading)
                            Picker("", selection: $selectedAudioBitrate) {
                                ForEach(audioBitrates, id: \.self) { Text($0) }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        HStack {
                            Text("Sample Rate:").frame(width: 80, alignment: .leading)
                            Picker("", selection: $selectedAudioSampleRate) {
                                ForEach(audioSampleRates, id: \.self) { Text($0) }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Timecode Overlay
            GroupBox("⏱️ Timecode Overlay") {
                VStack(alignment: .leading, spacing: 12) {
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
                .padding(.vertical, 8)
            }
        }
    }
}
    }
}
