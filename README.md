# THN Converter - Versão Python 🐍

Versão portátil do conversor de vídeo em Python com interface gráfica moderna.

## ✨ Features

- ✅ Interface moderna e responsiva (dark/light mode)
- ✅ Drag & drop de arquivos
- ✅ Múltiplos codecs de vídeo (H.264, H.265, ProRes, DNxHD, VP9)
- ✅ Controle de resolução, framerate e qualidade (CRF)
- ✅ Codecs de áudio independentes
- ✅ Overlay de timecode queimado no vídeo
- ✅ Barra de progresso em tempo real
- ✅ Log de conversão detalhado
- ✅ Otimizado para Apple Silicon
- ✅ Escolha personalizada do local de salvamento
- ✅ Configurações de áudio somente quando necessário
- ✅ Interface otimizada com grid de opções

## 🚀 Instalação Rápida

```bash
# 1. Instale as dependências e baixe o FFmpeg
./install.sh

# 2. Rode o app
python3 thn_converter.py
```

## 📦 Criar App Instalável

```bash
# Criar app bundle
./create-app.sh

# Instalar no Applications
cp -r THN-Converter.app /Applications/
```

## 🎯 Uso

1. **Abra o app** (via terminal ou ícone)
2. **Arraste** um vídeo ou clique em "Selecionar Arquivo"
3. **Selecione o local de salvamento** (ou aceite o padrão)
4. **Configure** as opções:
   - Codec de vídeo
   - Qualidade (CRF)
   - Resolução (4K, Full HD, HD, SD, Original)
   - Framerate (60, 30, 24, etc)
   - Codec de áudio
   - Bitrate de áudio (aparece apenas se não for "copy")
   - Sample rate
   - Timecode overlay (opcional)
5. **Clique em "Converter"**
6. **Aguarde** - arquivo salvo no local escolhido

## 📁 Estrutura

```
THN-Converter-Python/
├── thn_converter.py      # App principal
├── requirements.txt      # Dependências Python
├── install.sh           # Script de instalação
├── create-app.sh        # Criar app bundle
└── ffmpeg              # FFmpeg binário (baixado automaticamente)
```

## 🔧 Requisitos

- macOS 13.0+
- Python 3.8+ (já vem no macOS)
- pip3 (gerenciador de pacotes Python)

## 🎨 Tecnologias

- **CustomTkinter** - Interface moderna
- **FFmpeg** - Engine de conversão
- **Python 3** - Linguagem

## 💡 Dicas

- A primeira execução baixa o FFmpeg automaticamente
- Os arquivos convertidos podem ser salvos em qualquer local
- Use "Original" para manter resolução/framerate do arquivo fonte
- Timecode é baseado no PTS (Presentation Timestamp) do vídeo

## 🐛 Problemas Comuns

**Erro: "customtkinter not found"**
```bash
pip3 install customtkinter
```

**Erro: "ffmpeg not found"**
```bash
./install.sh
```

**App não abre**
```bash
python3 thn_converter.py
```
