#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import customtkinter as ctk
import tkinter as tk
from tkinter import filedialog, messagebox
import subprocess
import threading
import os
import re
import platform
from pathlib import Path
from datetime import datetime

class ConversionSettings:
    def __init__(self):
        self.video_codec = "libx264"
        self.quality = "23"
        self.resolution = "Original"
        self.framerate = "Original"
        self.audio_codec = "copy"
        self.audio_bitrate = "192k"
        self.audio_sample_rate = "48000"
        self.add_timecode = True
        self.timecode_position = "bottom-center"
        self.output_path = ""


class VideoConverter:
    def __init__(self):
        self.process = None
        self.ffmpeg_path = self.find_ffmpeg()
    
    def find_ffmpeg(self):
        paths = [
            "./ffmpeg",
            "/usr/local/bin/ffmpeg",
            "/opt/homebrew/bin/ffmpeg",
            "/usr/bin/ffmpeg"
        ]
        for path in paths:
            if os.path.exists(path):
                return path
        return "ffmpeg"
    
    def get_timecode_filter(self, position):
        font_color = "white"
        font_size = "24"
        box_color = "black@0.7"
        
        positions = {
            "top-left": "x=10:y=10",
            "top-right": "x=w-tw-10:y=10",
            "top-center": "x=(w-tw)/2:y=10",
            "bottom-left": "x=10:y=h-th-10",
            "bottom-right": "x=w-tw-10:y=h-th-10",
            "bottom-center": "x=(w-tw)/2:y=h-th-10"
        }
        
        coords = positions.get(position, positions["bottom-center"])
        return f"drawtext=text='\\%{{gmtime\\:%H:%M:%S}}':fontfile=/System/Library/Fonts/Helvetica.ttc:fontsize={font_size}:fontcolor={font_color}:box=1:boxcolor={box_color}:{coords}"
    
    def convert(self, input_path, output_path, settings, on_progress=None, on_output=None):
        args = [
            self.ffmpeg_path,
            "-i", input_path,
            "-c:v", settings.video_codec,
        ]
        
        if settings.video_codec in ["libx264", "libx265"]:
            args.extend(["-preset", "medium", "-crf", settings.quality])
        elif settings.video_codec == "prores_ks":
            args.extend(["-profile:v", "3"])
        
        # Resolution and timecode filters
        vf_filters = []
        
        if settings.resolution != "Original":
            vf_filters.append(f"scale={settings.resolution}")
        
        if settings.add_timecode:
            vf_filters.append(self.get_timecode_filter(settings.timecode_position))
        
        if vf_filters:
            args.extend(["-vf", ",".join(vf_filters)])
        
        # Framerate
        if settings.framerate != "Original":
            args.extend(["-r", settings.framerate])
        
        # Audio codec settings
        args.extend(["-c:a", settings.audio_codec])
        
        if settings.audio_codec != "copy":
            args.extend(["-b:a", settings.audio_bitrate, "-ar", settings.audio_sample_rate])
        
        args.append(output_path)
        
        if on_output:
            on_output(f"Iniciando conversão...\n")
            on_output(f"Entrada: {input_path}\n")
            on_output(f"Saída: {output_path}\n")
            on_output(f"Codec: {settings.video_codec} | Qualidade: {settings.quality}\n")
            on_output(f"Áudio: {settings.audio_codec}\n")
            
        self.process = subprocess.Popen(
            args,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            universal_newlines=True,
            encoding='utf-8',
            errors='replace'
        )
        
        duration = None
        current_time = 0
        
        for line in iter(self.process.stdout.readline, ''):
            if on_output:
                on_output(line)
            
            if duration is None and 'Duration:' in line:
                match = re.search(r'Duration: (\d+):(\d+):(\d+\.\d+)', line)
                if match:
                    h, m, s = map(float, match.groups())
                    duration = h * 3600 + m * 60 + s
            
            if duration and 'time=' in line:
                match = re.search(r'time=(\d+):(\d+):(\d+\.\d+)', line)
                if match:
                    h, m, s = map(float, match.groups())
                    current_time = h * 3600 + m * 60 + s
                    if on_progress:
                        on_progress(current_time / duration)
        
        self.process.wait()
        
        if self.process.returncode == 0:
            if on_progress:
                on_progress(1.0)
            return True
        else:
            raise Exception(f"FFmpeg failed with code {self.process.returncode}")
    
    def cancel(self):
        if self.process:
            self.process.terminate()

class ConverterApp(ctk.CTk):
    def __init__(self):
        super().__init__()
        
        self.title("THN Converter")
        self.geometry("800x700")
        self.minsize(700, 600)
        
        ctk.set_appearance_mode("dark")
        ctk.set_default_color_theme("blue")
        
        self.dropped_file = None
        self.output_file = None
        self.is_converting = False
        self.converter = VideoConverter()
        
        self.create_widgets()
    
    def create_widgets(self):
        # Tabbed interface
        self.tab_bar = ctk.CTkTabbar(self)
        self.tab_bar.pack(fill="both", expand=True, padx=15, pady=15)
        
        # Tab 1: Principal
        tab_principal = self.tab_bar.add_tab("Principal")
        self.create_principal_tab(tab_principal)
        
        # Tab 2: Opções
        tab_opcoes = self.tab_bar.add_tab("Opções")
        self.create_opcoes_tab(tab_opcoes)
        
        # Tab 3: Log
        tab_log = self.tab_bar.add_tab("Log")
        self.create_log_tab(tab_log)
    
    def create_principal_tab(self, parent):
        """Tab 1: Principal - Drop zone, destinations, progress"""
        parent.grid_columnconfigure(0, weight=1)
        
        # Drop zone
        drop_frame = ctk.CTkFrame(parent, corner_radius=12)
        drop_frame.grid(row=0, column=0, padx=20, pady=(20, 15), sticky="ew")
        
        ctk.CTkLabel(
            drop_frame,
            text="🎬 Arraste um arquivo de vídeo aqui\nou clique para selecionar",
            font=ctk.CTkFont(size=16),
            justify="center"
        ).pack(pady=40)
        
        self.file_label = ctk.CTkLabel(
            drop_frame,
            text="",
            font=ctk.CTkFont(size=12),
            text_color="gray",
            justify="center"
        )
        self.file_label.pack(pady=(0, 15))
        
        self.drop_button = ctk.CTkButton(
            drop_frame,
            text="📁 Selecionar Arquivo",
            command=self.select_file,
            height=40
        )
        self.drop_button.pack(pady=(0, 20))
        
        # Output selection
        output_frame = ctk.CTkFrame(parent, corner_radius=12)
        output_frame.grid(row=1, column=0, padx=20, pady=(0, 15), sticky="ew")
        
        ctk.CTkLabel(
            output_frame,
            text="💾 Destino da Conversão",
            font=ctk.CTkFont(size=14, weight="bold")
        ).pack(anchor="w", padx=15, pady=(15, 5))
        
        self.output_label = ctk.CTkLabel(
            output_frame,
            text="Clique para escolher destino",
            font=ctk.CTkFont(size=12),
            text_color="gray",
            justify="center"
        )
        self.output_label.pack(pady=(0, 15))
        
        self.output_button = ctk.CTkButton(
            output_frame,
            text="📁 Selecionar Destino",
            command=self.select_output_file,
            height=40
        )
        self.output_button.pack(pady=(0, 20))
        
        # Progress
        progress_frame = ctk.CTkFrame(parent)
        progress_frame.grid(row=2, column=0, padx=20, pady=(0, 15), sticky="ew")
        
        self.progress_bar = ctk.CTkProgressBar(progress_frame)
        self.progress_bar.pack(fill="x", padx=15, pady=(15, 5))
        self.progress_bar.set(0)
        
        self.progress_label = ctk.CTkLabel(
            progress_frame,
            text="0.0%",
            font=ctk.CTkFont(size=12),
            text_color="gray"
        )
        self.progress_label.pack(pady=(0, 15))
        
        # Convert button
        self.convert_button = ctk.CTkButton(
            parent,
            text="▶ Converter",
            command=self.start_conversion,
            height=50,
            font=ctk.CTkFont(size=18, weight="bold"),
            corner_radius=12
        )
        self.convert_button.grid(row=3, column=0, padx=20, pady=(0, 20), sticky="ew")
        
        self.file_label = self.drop_frame = self.output_frame = None  # Prevent duplicates
    
    def create_opcoes_tab(self, parent):
        """Tab 2: Opções - All conversion settings"""
        parent.grid_columnconfigure(0, weight=1)
        parent.grid_columnconfigure(1, weight=1)
        
        # Video Settings
        video_frame = ctk.CTkFrame(parent)
        video_frame.grid(row=0, column=0, columnspan=2, padx=20, pady=(15, 10), sticky="ew")
        
        ctk.CTkLabel(video_frame, text="🎬 Vídeo", font=ctk.CTkFont(size=14, weight="bold")).grid(
            row=0, column=0, padx=15, pady=(10, 5), sticky="w"
        )
        
        self.video_codec_var = ctk.StringVar(value="H.264")
        self.create_setting_row(video_frame, 1, "Codec:", self.video_codec_var, 
                               ["H.264", "H.265/HEVC", "ProRes", "DNxHD", "VP9", "MPEG-4"])
        
        self.quality_var = ctk.StringVar(value="23")
        self.create_setting_row(video_frame, 2, "Qualidade:", self.quality_var,
                               ["0", "10", "15", "20", "23", "28", "35", "50"])
        
        self.resolution_var = ctk.StringVar(value="Original")
        self.create_setting_row(video_frame, 3, "Resolução:", self.resolution_var,
                               ["Original", "3840x2160", "1920x1080", "1280x720", "854x480"])
        
        self.framerate_var = ctk.StringVar(value="Original")
        self.create_setting_row(video_frame, 4, "Framerate:", self.framerate_var,
                               ["Original", "60", "59.94", "30", "29.97", "24", "23.976"])
        
        # Audio Settings
        audio_frame = ctk.CTkFrame(parent)
        audio_frame.grid(row=1, column=0, columnspan=2, padx=20, pady=(0, 10), sticky="ew")
        
        ctk.CTkLabel(audio_frame, text="🔊 Áudio", font=ctk.CTkFont(size=14, weight="bold")).grid(
            row=0, column=0, padx=15, pady=(10, 5), sticky="w"
        )
        
        self.audio_codec_var = ctk.StringVar(value="copy (não converter)")
        self.create_setting_row(audio_frame, 1, "Codec:", self.audio_codec_var,
                               ["copy (não converter)", "AAC", "MP3", "Opus", "Vorbis", "FLAC", "PCM"])
        
        # Configurações de áudio (apenas se não for copy)
        self.audio_bitrate_frame = ctk.CTkFrame(audio_frame, fg_color="transparent")
        self.audio_bitrate_frame.grid(row=2, column=0, columnspan=2, padx=15, pady=5, sticky="ew")
        
        self.audio_bitrate_var = ctk.StringVar(value="192k")
        ctk.CTkLabel(self.audio_bitrate_frame, text="Bitrate:", width=80).grid(row=0, column=0, sticky="w")
        audio_bitrate_menu = ctk.CTkOptionMenu(self.audio_bitrate_frame, variable=self.audio_bitrate_var,
                                               values=["320k", "256k", "192k", "128k", "96k"])
        audio_bitrate_menu.grid(row=0, column=1, sticky="ew", padx=(10, 15))
        self.audio_bitrate_frame.grid_forget()
        
        self.audio_sample_rate_frame = ctk.CTkFrame(audio_frame, fg_color="transparent")
        self.audio_sample_rate_frame.grid(row=3, column=0, columnspan=2, padx=15, pady=5, sticky="ew")
        
        self.audio_sample_rate_var = ctk.StringVar(value="48000")
        ctk.CTkLabel(self.audio_sample_rate_frame, text="Sample Rate:", width=80).grid(row=0, column=0, sticky="w")
        audio_sample_rate_menu = ctk.CTkOptionMenu(self.audio_sample_rate_frame, variable=self.audio_sample_rate_var,
                                                  values=["48000", "44100", "96000"])
        audio_sample_rate_menu.grid(row=0, column=1, sticky="ew", padx=(10, 15))
        self.audio_sample_rate_frame.grid_forget()
        
        self.audio_codec_var.trace_add("write", self.update_audio_settings_visibility)
        
        # Timecode Overlay
        overlay_frame = ctk.CTkFrame(parent)
        overlay_frame.grid(row=2, column=0, columnspan=2, padx=20, pady=(0, 10), sticky="ew")
        
        ctk.CTkLabel(overlay_frame, text="⏱️ Timecode Overlay", font=ctk.CTkFont(size=14, weight="bold")).grid(
            row=0, column=0, padx=15, pady=(10, 5), sticky="w"
        )
        
        self.timecode_var = ctk.BooleanVar(value=True)
        timecode_check = ctk.CTkCheckBox(overlay_frame, text="Mostrar Timecode", variable=self.timecode_var)
        timecode_check.grid(row=1, column=0, padx=15, pady=5, sticky="w")
        
        self.timecode_position_var = ctk.StringVar(value="bottom-center")
        position_frame = ctk.CTkFrame(overlay_frame, fg_color="transparent")
        position_frame.grid(row=2, column=0, padx=15, pady=5, sticky="w")
        ctk.CTkLabel(position_frame, text="Posição:").pack(side="left", padx=(0, 10))
        position_menu = ctk.CTkOptionMenu(position_frame, variable=self.timecode_position_var,
                                          values=["top-left", "top-center", "top-right", 
                                                  "bottom-left", "bottom-center", "bottom-right"])
        position_menu.pack(side="left")
        
        self.video_frame = self.audio_frame = self.overlay_frame = None  # Prevent duplicates
    
    def create_log_tab(self, parent):
        """Tab 3: Log - Progress output"""
        parent.grid_columnconfigure(0, weight=1)
        
        ctk.CTkLabel(
            parent,
            text="📋 Log de Conversão",
            font=ctk.CTkFont(size=14, weight="bold")
        ).pack(anchor="w", padx=20, pady=(15, 5))
        
        self.log_text = ctk.CTkTextbox(parent, font=ctk.CTkFont(family="monospace", size=11))
        self.log_text.pack(fill="both", expand=True, padx=15, pady=(0, 15))
        
        self.log_frame = None  # Prevent duplicates
    
    def create_setting_row(self, parent, row, label_text, variable, values):
        frame = ctk.CTkFrame(parent, fg_color="transparent")
        frame.grid(row=row, column=0, columnspan=2, padx=15, pady=5, sticky="ew")
        frame.grid_columnconfigure(1, weight=1)
        
        ctk.CTkLabel(frame, text=label_text, width=80).grid(row=0, column=0, sticky="w")
        menu = ctk.CTkOptionMenu(frame, variable=variable, values=values)
        menu.grid(row=0, column=1, sticky="ew", padx=(10, 15))
    
    def update_audio_settings_visibility(self, *args):
        if self.audio_codec_var.get().startswith("copy"):
            self.audio_bitrate_frame.grid_forget()
            self.audio_sample_rate_frame.grid_forget()
        else:
            self.audio_bitrate_frame.grid()
            self.audio_sample_rate_frame.grid()
    
    def select_file(self):
        file_path = filedialog.askopenfilename(
            title="Selecionar arquivo de vídeo",
            filetypes=[
                ("Vídeo", "*.mp4 *.mov *.avi *.mkv *.wmv *.flv *.webm *.m4v *.mxf"),
                ("Todos", "*.*")
            ]
        )
        if file_path:
            self.dropped_file = file_path
            self.file_label.configure(text=Path(file_path).name)
            self.drop_label.configure(text="✅ Arquivo selecionado")
            
            # Se não foi definido output, definir padrão
            if not self.output_file:
                output_dir = str(Path.home() / "Downloads")
                codec_suffix = self.video_codec_var.get().lower().replace("/", "_").replace(" ", "_")
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                output_name = Path(file_path).stem + f"_{codec_suffix}_{timestamp}.mp4"
                self.output_file = os.path.join(output_dir, output_name)
                self.output_label.configure(text=Path(self.output_file).name)
    
    def select_output_file(self):
        file_path = filedialog.asksaveasfilename(
            title="Selecionar local de salvamento",
            defaultextension=".mp4",
            filetypes=[
                ("MP4", "*.mp4"),
                ("MOV", "*.mov"),
                ("AVI", "*.avi"),
                ("Todos", "*.*")
            ]
        )
        if file_path:
            self.output_file = file_path
            self.output_label.configure(text=Path(file_path).name)
    
    def start_conversion(self):
        if not self.dropped_file:
            messagebox.showwarning("Aviso", "Por favor, selecione um arquivo de vídeo primeiro!")
            return
        
        if self.is_converting:
            return
        
        self.is_converting = True
        self.convert_button.configure(text="⏳ Convertendo...", state="disabled")
        self.progress_bar.set(0)
        self.progress_label.configure(text="0.0%")
        self.log_text.delete("1.0", "end")
        
        def map_video_codec(codec_name):
            mapping = {
                "H.264": "libx264",
                "H.265/HEVC": "libx265",
                "ProRes": "prores_ks",
                "DNxHD": "dnxhd",
                "VP9": "libvpx-vp9",
                "MPEG-4": "mpeg4"
            }
            return mapping.get(codec_name, "libx264")
        
        def map_quality(quality_text):
            if quality_text == "Excelente (18)": return "18"
            elif quality_text == "Muito Boa (20)": return "20"
            elif quality_text == "Boa (23)": return "23"
            elif quality_text == "Média (26)": return "26"
            elif quality_text == "Baixa (28)": return "28"
            else: return "23"
        
        settings = ConversionSettings()
        settings.video_codec = map_video_codec(self.video_codec_var.get())
        settings.quality = self.quality_var.get()
        settings.resolution = self.resolution_var.get().split()[0] if self.resolution_var.get() != "Original" else "Original"
        settings.framerate = self.framerate_var.get() if self.framerate_var.get() != "Original" else "Original"
        settings.audio_codec = self.audio_codec_var.get().split()[0] if self.audio_codec_var.get() != "copy (não converter)" else "copy"
        settings.audio_bitrate = self.audio_bitrate_var.get()
        settings.audio_sample_rate = self.audio_sample_rate_var.get()
        settings.add_timecode = self.timecode_var.get()
        settings.timecode_position = self.timecode_position_var.get()
        settings.output_path = self.output_file if self.output_file else ""
        
        if not settings.output_path:
            # Gerar nome padrão
            output_dir = str(Path.home() / "Downloads")
            codec_suffix = self.video_codec_var.get().lower().replace("/", "_").replace(" ", "_")
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            output_name = Path(self.dropped_file).stem + f"_{codec_suffix}_{timestamp}.mp4"
            settings.output_path = os.path.join(output_dir, output_name)
        
        def on_progress(progress):
            self.progress_bar.set(progress)
            self.progress_label.configure(text=f"{progress*100:.1f}%")
        
        def on_output(text):
            self.log_text.insert("end", text)
            self.log_text.see("end")
        
        def conversion_thread():
            try:
                self.converter.convert(
                    self.dropped_file, settings.output_path, settings,
                    on_progress=on_progress,
                    on_output=on_output
                )
                self.after(0, lambda: self.conversion_complete(True, settings.output_path))
            except Exception as e:
                self.after(0, lambda: self.conversion_complete(False, str(e)))
        
        thread = threading.Thread(target=conversion_thread, daemon=True)
        thread.start()
    
    def conversion_complete(self, success, result):
        self.is_converting = False
        self.convert_button.configure(text="▶ Converter", state="normal")
        
        if success:
            self.progress_label.configure(text="✅ 100% - Concluído!")
            self.log_text.insert("end", f"\n✅ Conversão concluída!\nArquivo salvo em: {result}\n")
            messagebox.showinfo("Sucesso", f"Conversão concluída!\n\nArquivo salvo em:\n{result}")
        else:
            self.progress_label.configure(text="❌ Erro")
            self.log_text.insert("end", f"\n❌ Erro: {result}\n")
            messagebox.showerror("Erro", f"Falha na conversão:\n{result}")

if __name__ == "__main__":
    app = ConverterApp()
    app.mainloop()
