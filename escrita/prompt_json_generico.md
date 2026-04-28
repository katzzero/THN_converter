# Prompt Genérico: Criar JSON de Documentação de Projeto (v2.0)

Copie e cole este prompt para qualquer IA (ChatGPT, Claude, opencode, etc.) para gerar um arquivo de documentação JSON que reduz drasticamente a necessidade de leitura de múltiplos arquivos.

---

## Prompt para Gerar `project_info.json`

```
# Tarefa: Gerar Documentação JSON do Projeto (v2.0)

## Objetivo
Analise este projeto e gere um arquivo `project_info.json` na raiz que permita a qualquer IA entender rapidamente a estrutura, dependências e funcionamento SEM precisar ler todos os arquivos.

## Instruções de Análise

### 1. Estrutura do Projeto
- Liste todos os arquivos na raiz e subdiretórios (use glob: **/*)
- Identifique arquivos de configuração (.json, .yaml, .toml, .xml, .pbxproj, etc.)
- Identifique arquivos fonte por extensão (.py, .js, .ts, .swift, .go, etc.)
- Identifique recursos (imagens, ícones, assets)
- Note o que foi removido/excluído (check .gitignore ou git log)

### 2. Extração de Metadados
- **Linguagens**: Ler shebangs (#!/usr/bin/...) e extensões de arquivos
- **Dependências**: Ler package.json, requirements.txt, Cargo.toml, go.mod, Podfile, etc.
- **Build/Deploy**: Extrair versões alvo, scripts de build, configurações de CI/CD
- **Ferramentas externas**: Identificar binários incluídos ou dependências externas
- **Git state**: branch atual, último commit, se há mudanças pendentes

### 3. Estrutura Obrigatória do JSON (v2.0)

```json
{
  "project_name": "string",
  "version": "string",
  "description": "breve descrição em inglês",
  "created_date": "YYYY-MM-DD",
  "last_updated": "YYYY-MM-DD",
  "platform": ["string"],
  "languages": ["string"],
  "frameworks": ["string"],
  "git_state": {
    "branch": "string",
    "last_commit": "string",
    "last_commit_date": "YYYY-MM-DD",
    "last_commit_msg": "string",
    "dirty": boolean
  },
  "dependencies": {
    "runtime": ["string"],
    "development": ["string"],
    "external_tools": [
      {
        "name": "string",
        "version": "string",
        "size_bytes": number,
        "checksum_md5": "string",
        "included_in_project": boolean,
        "search_paths": ["string"]
      }
    ]
  },
  "file_metadata": {
    "source_files": [
      {"path": "string", "size_bytes": number, "purpose": "string"}
    ],
    "config_files": [
      {"path": "string", "size_bytes": number, "purpose": "string"}
    ],
    "removed_files": [
      {"path": "string", "reason": "string"}
    ]
  },
  "project_structure": {
    "root_files": ["string"],
    "source_directories": ["string"],
    "config_files": ["string"],
    "asset_directories": ["string"]
  },
  "build_and_test": {
    "build_command": "string",
    "test_command": "string",
    "clean_command": "string",
    "run_alt": "string"
  },
  "entry_points": {
    "main": "string",
    "tests": ["string"],
    "scripts": ["string"]
  },
  "features": {
    "key_features": ["string"],
    "configurable_options": ["string"]
  },
  "quick_ref": {
    "purpose": "string",
    "tech_stack": "string",
    "entry_point": "string",
    "key_files_ordered": ["string"]
  },
  "file_relationships": {
    "file1.swift": ["dep1", "dep2"],
    "file2.py": ["dep1", "external_tool"]
  },
  "troubleshooting": [
    {
      "error_pattern": "regex pattern",
      "cause": "string",
      "solution": "string",
      "files_to_check": ["string"],
      "code_location": "string"
    }
  ],
  "known_issues": ["string"],
  "ai_context": {
    "quick_summary": "string (1 linha)",
    "read_order": ["string"],
    "skip_files_over": number,
    "key_files": {
      "core_logic": "string",
      "ui": "string",
      "config": "string"
    },
    "common_tasks": {
      "task_name": {"where": "string", "how": "string"}
    },
    "update_script": "string"
  }
}
```

### 4. Regras de Preenchimento
- **NÃO invente dados**: Se não encontrar, use "unknown" ou null
- **Caminhos**: Use barras normais (/), relativos à raiz do projeto
- **Arrays**: Não duplique valores
- **Tamanhos**: Em bytes (número inteiro)
- **Datas**: Formato ISO 8601 (YYYY-MM-DD)
- **Versões**: Sejam precisas (ex: "1.0.0", não "latest")
- **Checksums**: Use md5sum ou equivalente, ou "unknown"

### 5. Verificações Especiais
Para o tipo de projeto que você identificar, verifique:
- [ ] Web: framework (React, Vue, etc.), bundler config
- [ ] Mobile: plataforma (iOS, Android), versão mínima
- [ ] CLI: ponto de entrada, argumentos aceitos
- [ ] Library: API pública, exports principais
- [ ] Game: engine usada, assets directory
- [ ] Data: banco de dados, ORMs, migrations

### 6. Troubleshooting (NOVO!)
Para cada erro comum que você identificar no código ou logs, adicione:
- **error_pattern**: Regex para identificar o erro no log
- **cause**: Causa raiz do problema
- **solution**: Como corrigir
- **files_to_check**: Quais arquivos verificar
- **code_location**: Onde exatamente no código (arquivo + linha)

### 7. Otimização para IAs
O JSON deve permitir que uma IA:
1. Entenda o projeto lendo APENAS este arquivo (85% de redução de contexto)
2. Saiba onde editar para tarefas comuns (via `ai_context.common_tasks`)
3. Evite ler arquivos desnecessários (via `entry_points` e `key_files`)
4. Identifique rapidamente dependências (via `dependencies`)
5. Troubleshooting rápido sem ler código (via `troubleshooting`)

## Formato de Saída
1. Primeiro, mostre um resumo do que encontrou
2. Depois, gere o JSON completo
3. Valide a sintaxe (sem vírgulas finais, aspas duplas)
4. Salve como `project_info.json` na raiz

## Exemplo de Execução
1. Liste arquivos: `find . -type f -name "*.py" -o -name "*.json"`
2. Leia package.json / requirements.txt para dependências
3. Identifique entry point (main, index, App, etc.)
4. Capture git state: `git branch`, `git log -1`
5. Gere JSON com todas as informações
6. Formate com indentação de 2 espaços
7. Valide: `python3 -m json.tool project_info.json`
```

---

## Como Usar

1. **Copie** todo o prompt acima (dentro das crases)
2. **Cole** no chat da IA junto com a mensagem: "Analise meu projeto em [CAMINHO_DO_PROJETO]"
3. A IA irá:
   - Ler e analisar a estrutura
   - Extrair metadados
   - Gerar o `project_info.json`
4. **Revise** o JSON gerado
5. **Salve** na raiz do seu projeto
6. **Adicione ao repositório** (git add project_info.json)

---

## Benefícios da v2.0

| Cenário | Sem JSON | Com JSON v1.0 | Com JSON v2.0 | Redução |
|---------|-----------|-----------------|---------------|----------|
| Entender projeto | 10-15 arquivos | 1-2 arquivos | **1 arquivo** | **90%** |
| Achar arquivo específico | grep/glob múltiplo | JSON lookup | **JSON lookup + size** | **95%** |
| Ver dependências | Ler package.json, etc. | JSON `dependencies` | **JSON `dependencies`** | **100%** |
| Identificar issues | Ler código e commits | JSON `known_issues` | **JSON `troubleshooting` + `known_issues`** | **100%** |
| Troubleshooting rápido | Debug manual | Não tem | **JSON `troubleshooting`** | **90%** |
| Verificar mudanças | `git diff` | Não tem | **`git_state` + `file_metadata`** | **85%** |

---

## Dica: Atualize o JSON quando:
- Novos arquivos fonte são adicionados
- Dependências mudam
- Configurações de build são alteradas
- Novos recursos são implementados
- Novos erros comuns são descobertos (atualize `troubleshooting`)

---

## Comparação: v1.0 vs v2.0

| Campo | v1.0 | v2.0 |
|-------|------|------|
| git_state | ❌ | ✅ |
| file_metadata + sizes | ❌ | ✅ |
| troubleshooting | ❌ | ✅ |
| file_relationships | ❌ | ✅ |
| build_and_test | ❌ | ✅ |
| quick_ref | ❌ | ✅ |
| skip_files_over | ❌ | ✅ |
| checksum_md5 | ❌ | ✅ |
