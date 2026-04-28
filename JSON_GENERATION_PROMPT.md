# Prompt para Gerar project_structure.json Perfeito

## Objetivo
Gere um arquivo `project_structure.json` completo e preciso para este projeto THN Converter, facilitando a compreensao rapida por IAs sem necessidade de ler multiplos arquivos.

## Contexto do Projeto
- Aplicativo macOS para conversao de video
- Backend: FFmpeg (incluido no bundle)
- Frontend: SwiftUI (Swift) e CustomTkinter (Python)
- Recursos: multiplos codecs, resolues, framerates, timecode overlay

## Instrues para a IA

### 1. Analisar Estrutura Real
- Liste todos os arquivos na raiz e subdiretorios
- Identifique arquivos fonte (.swift, .py)
- Identifique recursos (imagens, icones)
- Identifique arquivos de configurao (.pbxproj, .entitlements, .plist)
- Verifique o que foi removido/excluido

### 2. Extrair Informaes Técnicas
- **Linguagens**: Ler imports/headers para listar dependências reais
- **FFmpeg**: Verificar tamanho, versao (execute `./ffmpeg -version`), caminhos de busca
- **Build Config**: Extrair do project.pbxproj:
  - Deployment target
  - Code signing settings
  - Build phases (CopyFiles, Resources)
- **Features**: Ler codigo para listar:
  - Codecs suportados (mapVideoCodec)
  - Resolues disponiveis
  - Posies de timecode

### 3. Estrutura Obrigatória do JSON
```json
{
  "project": "string",
  "version": "string",
  "description": "string",
  "platform": "string",
  "language": ["string"],
  "dependencies": {
    "Swift": ["string"],
    "Python": ["string"]
  },
  "external_tools": {
    "ffmpeg": {
      "version": "string",
      "size_bytes": number,
      "source": "string",
      "path": ["string"],
      "included_in_bundle": boolean,
      "build_phase": "string"
    }
  },
  "project_structure": {
    "root": ["string"],
    "source_files": {
      "Swift": ["string"],
      "Python": ["string"],
      "removed": ["string"]
    },
    "resources": {
      "images": ["string"],
      "icons": ["string"]
    }
  },
  "build_configurations": {
    "Xcode": {
      "schemes": ["string"],
      "deployment_target": "string",
      "code_sign": {
        "identity": "string",
        "app_sandbox": boolean,
        "hardened_runtime": boolean
      }
    }
  },
  "features": {
    "video_codec": ["string"],
    "audio_codec": ["string"],
    "resolution": ["string"],
    "framerate": ["string"],
    "timecode_overlay": boolean,
    "timecode_position": ["string"]
  },
  "known_issues": ["string"],
  "ai_context": {
    "quick_summary": "string",
    "key_files": {
      "entry_point": "string",
      "video_logic": "string",
      "ui": "string",
      "python_alt": "string"
    },
    "common_tasks": {
      "task_name": "string"
    },
    "update_script": "string"
  },
  "last_modified": "YYYY-MM-DD"
}
```

### 4. Regras de Preenchimento
- **Nao invente dados**: Se nao encontrar, use "unknown" ou null
- **Caminhos**: Use barras normais (/) e caminhos relativos a raiz
- **Arrays**: Nao duplique valores
- **Versoes**: Seja preciso (ex: "1.0.0", nao "latest")
- **Tamanhos**: Em bytes, numero inteiro
- **Datas**: Formato ISO 8601 (YYYY-MM-DD)

### 5. Verificao Especial para Este Projeto
- [ ] FFmpeg realmente no bundle? Verifique tamanho > 50MB
- [ ] SwiftUI usa ObservableObject? (VideoConverter)
- [ ] Python usa threading? (VideoConverter.convert)
- [ ] Timecode usa `gmtime:%H:%M:%S`? (nao `%{pts\:HMS}`)
- [ ] Fonte Helvetica.ttc existe? (`ls /System/Library/Fonts/`)
- [ ] Build phase "CopyFiles" configurado no pbxproj?
- [ ] .gitignore nao bloqueia ffmpeg?

### 6. Atualizao
- O JSON deve ser atualizado quando:
  - Novos arquivos fonte sao adicionados
  - FFmpeg e atualizado
  - Configuraes de build mudam
  - Novos recursos sao adicionados
- Use o script `update_project_json.sh` para atualizao automatica

## Exemplo de Execuo
1. Leia todos os arquivos .swift e .py
2. Execute `./ffmpeg -version` para pegar versao
3. Use `stat -f%z ffmpeg` para tamanho
4. Extraia deployment target do project.pbxproj
5. Liste codecs do mapVideoCodec() no ContentView.swift
6. Gere JSON com todas as informaes
7. Valide sintaxe com `python3 -m json.tool`

## Observaes Finais
- Mantenha o JSON formatado (2 espacos de indentao)
- Nao use tabulaçoes
- Comentarios nao sao permitidos em JSON
- Salve na raiz como `project_structure.json`
