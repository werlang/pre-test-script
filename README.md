# WAMP Lab Setup Script

Script de automação para preparação de computadores de laboratório para provas práticas de programação web.

## Propósito

Este script foi desenvolvido para preparar os computadores do laboratório antes de provas. Ele realiza a limpeza completa dos arquivos de alunos anteriores e instala os arquivos necessários para a prova.

### Contexto de Uso

- **Quando usar**: Antes de aplicar provas práticas nos laboratórios de informática
- **Ambiente**: Computadores com WAMP64 instalado para desenvolvimento web (PHP/MySQL)
- **Segurança**: Os cabos de rede são removidos fisicamente dos PCs para garantir que não haja acesso à internet durante a prova

## O que o Script Faz

| Etapa | Ação | Motivo |
|-------|------|--------|
| 1 | Limpa pastas do usuário atual | Remove arquivos de sessões anteriores |
| 2 | Limpa pastas públicas "ALUNO" (D:) | Limpa áreas compartilhadas onde alunos salvam arquivos |
| 3 | Limpa perfil do usuário ALUNO | Remove arquivos do perfil padrão de aluno |
| 4 | Limpa pasta www do WAMP | Prepara ambiente limpo para a prova |
| 5 | Remove extensões do VS Code | **Remove extensões de IA e outras não permitidas** |
| 6 | Esvazia lixeira | Impede recuperação de arquivos anteriores |
| 7 | Copia arquivos da prova | Transfere arquivos do pendrive para o WAMP |
| 8 | Abre VS Code | Inicia o ambiente de desenvolvimento |

## Como Usar

### Preparação

1. Copie o script `setup_wamp.bat` para um pendrive
2. Crie uma pasta no pendrive com os arquivos da prova (ex: `prova-php-01`)
3. Edite `extension_whitelist.txt` se precisar manter extensões específicas

### Execução

1. Remova o cabo de rede do computador
2. Insira o pendrive no PC
3. Execute `setup_wamp.bat`
4. Quando solicitado, digite o nome da pasta da prova (ex: `prova-php-01`)
5. Aguarde a conclusão

### Estrutura do Pendrive

```
📁 Pendrive (E:\ ou F:\)
├── setup_wamp.bat
├── extension_whitelist.txt
└── 📁 prova-php-01/          ← Pasta com arquivos da prova
    ├── index.php
    ├── conexao.php
    └── ...
```

## Extensões do VS Code

O script remove **todas** as extensões do VS Code, exceto as listadas em `extension_whitelist.txt`.

### Por que remover extensões?

- Alunos instalam extensões de **IA** (GitHub Copilot, Tabnine, etc.) que não são permitidas em provas
- Extensões desnecessárias podem atrapalhar ou dar vantagem indevida

Para adicionar extensões permitidas, edite `extension_whitelist.txt` com o ID da extensão (uma por linha).

## Caminhos Configurados

| Variável | Caminho | Descrição |
|----------|---------|-----------|
| `WAMP_WWW` | `C:\wamp64\www` | Pasta raiz do servidor web |
| `ALUNO_PROFILE` | `C:\Users\aluno` | Perfil padrão dos alunos |
| `DOC_PATH` | `D:\Documentos\aluno` | Pasta pública (PT-BR) |
| `DOCS_PATH` | `D:\Documents\aluno` | Pasta pública (EN) |

## ⚠️ Avisos Importantes

- **Script destrutivo**: Apaga permanentemente arquivos de usuários
- **Execute apenas em laboratórios**: Nunca execute em máquinas pessoais
- **Teste antes**: Valide em um PC de teste antes de aplicar em todos
- **Backup**: Se necessário, faça backup antes de executar

## Requisitos

- Windows 10/11
- WAMP64 instalado em `C:\wamp64`
- VS Code instalado e acessível via linha de comando (`code`)

## Licença

MIT License - Veja [LICENSE](LICENSE) para detalhes.
