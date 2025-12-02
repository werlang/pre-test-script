# Copilot Instructions for WAMP Lab Setup

## Project Overview

This is a **Windows batch script** project for preparing lab computers before practical exams. The script runs from a USB flash drive, cleans student files from previous sessions, removes unauthorized VS Code extensions (especially AI tools like Copilot/Tabnine), and deploys exam files to WAMP.

**Key context**: Network cables are physically removed during exams - no internet access. We do NOT have admin privileges on school PCs.

## Architecture

### Core Files
- `setup_wamp.bat` - Main automation script (8 steps), runs from USB flash drive
- `extension_whitelist.txt` - VS Code extensions to keep (database clients for MySQL exams)

### Execution Flow
1. Clean current user profile folders (handles EN/PT-BR: Documents/Documentos, Pictures/Imagens)
2. Clean shared "ALUNO" public folders on D: drive
3. Clean ALUNO user profile (C:\Users\aluno), preserving AppData
4. Reset WAMP www folder (C:\wamp64\www)
5. Remove VS Code extensions not in whitelist (blocks AI cheating tools)
6. Empty recycle bin (prevent file recovery)
7. Prompt for exam folder name, copy from USB to WAMP www
8. Launch VS Code with the exam project

## Conventions

### Batch Script Patterns
- Use `REM ========` section headers for visual separation
- Redirect errors to nul (`2>nul`) for silent failure handling
- Always check existence before operations (`if exist`)
- Support both English and Portuguese folder names (Documents/Documentos, Pictures/Imagens)
- Use `setlocal enabledelayedexpansion` for variable expansion in loops

### Path Constants
```batch
set WAMP_WWW=C:\wamp64\www
set ALUNO_PROFILE=C:\Users\aluno
set "DOC_PATH=D:\Documentos\aluno"
set "DOCS_PATH=D:\Documents\aluno"
```

### Extension Whitelist Format
One extension ID per line in `extension_whitelist.txt`. Comments start with `#`.

## Key Behaviors

- **No admin required**: Script works with standard user permissions only
- **Destructive operations**: Script permanently deletes user data - intended for lab reset
- **Skip hidden/system files**: Uses attribute checks (`%~aF`) to avoid system corruption
- **Preserve AppData**: ALUNO profile cleanup explicitly keeps AppData folder
- **Interactive input**: Step 7 prompts for exam folder name from flash drive

## USB Flash Drive Structure
```
📁 Pendrive/
├── setup_wamp.bat
├── extension_whitelist.txt
└── 📁 prova-php-01/    ← Exam files folder
    ├── index.php
    └── ...
```

## When Modifying

- Add new cleanup targets following the existing section pattern (numbered steps with echo feedback)
- Update step counter in all echo statements if adding/removing steps (currently shows [X/8])
- Test on a non-production machine - script is destructive by design
- No admin-dependent commands (no `runas`, no services, no registry edits)
