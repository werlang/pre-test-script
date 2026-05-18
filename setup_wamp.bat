@echo off
setlocal

if not defined EXTENSION_LIST set "EXTENSION_LIST=%~dp0extensions.txt"

if /I "%~1"=="__SYNC_EXT__" goto :sync_extensions

REM Always run from this script folder (important when launched by double-click)
cd /d "%~dp0"

REM ========================================
REM Setup Script for WAMP Development
REM ========================================

if not defined USER_PROFILE_ROOT set "USER_PROFILE_ROOT=%USERPROFILE%"
if not defined DOC_PATH set "DOC_PATH=D:\Documentos\aluno"
if not defined DOCS_PATH set "DOCS_PATH=D:\Documents\aluno"
if not defined ALUNO_PROFILE set "ALUNO_PROFILE=C:\Users\aluno"
if not defined WAMP_WWW set "WAMP_WWW=C:\wamp64\www"

echo Starting setup process...
echo.

REM ========================================
REM Step 1: Clean Current User Folders
REM ========================================
echo [1/8] Cleaning current user folders...

REM Clean all common user folder variations (handles both EN and PT-BR)
echo - Cleaning Downloads...
if exist "%USER_PROFILE_ROOT%\Downloads" rd /s /q "%USER_PROFILE_ROOT%\Downloads" 2>nul & md "%USER_PROFILE_ROOT%\Downloads" 2>nul

echo - Cleaning Documents/Documentos...
if exist "%USER_PROFILE_ROOT%\Documents" rd /s /q "%USER_PROFILE_ROOT%\Documents" 2>nul & md "%USER_PROFILE_ROOT%\Documents" 2>nul
if exist "%USER_PROFILE_ROOT%\Documentos" rd /s /q "%USER_PROFILE_ROOT%\Documentos" 2>nul & md "%USER_PROFILE_ROOT%\Documentos" 2>nul

echo - Cleaning Pictures/Imagens...
if exist "%USER_PROFILE_ROOT%\Pictures" rd /s /q "%USER_PROFILE_ROOT%\Pictures" 2>nul & md "%USER_PROFILE_ROOT%\Pictures" 2>nul
if exist "%USER_PROFILE_ROOT%\Imagens" rd /s /q "%USER_PROFILE_ROOT%\Imagens" 2>nul & md "%USER_PROFILE_ROOT%\Imagens" 2>nul

echo - Cleaning Videos...
if exist "%USER_PROFILE_ROOT%\Videos" rd /s /q "%USER_PROFILE_ROOT%\Videos" 2>nul & md "%USER_PROFILE_ROOT%\Videos" 2>nul

echo - Cleaning Music...
if exist "%USER_PROFILE_ROOT%\Music" rd /s /q "%USER_PROFILE_ROOT%\Music" 2>nul & md "%USER_PROFILE_ROOT%\Music" 2>nul

echo - Cleaning Desktop...
if exist "%USER_PROFILE_ROOT%\Desktop" rd /s /q "%USER_PROFILE_ROOT%\Desktop" 2>nul & md "%USER_PROFILE_ROOT%\Desktop" 2>nul

echo Current user folders cleaned successfully.
echo.

REM ========================================
REM Step 2: Clean ALUNO Public Folders
REM ========================================
echo [2/8] Cleaning ALUNO public folders...

for /d %%D in ("%DOC_PATH%\*") do (
    echo Cleaning folder: %%~nxD
    del /f /q "%%D\*.*" 2>nul
    for /d %%S in ("%%D\*") do (
        rmdir /s /q "%%S" 2>nul
    )
)
for /d %%D in ("%DOCS_PATH%\*") do (
    echo Cleaning folder: %%~nxD
    del /f /q "%%D\*.*" 2>nul
    for /d %%S in ("%%D\*") do (
        rmdir /s /q "%%S" 2>nul
    )
)

REM ========================================
REM Step 3: Clean ALUNO User Profile Folder
REM ========================================
echo [3/8] Cleaning ALUNO user profile folder...

if not exist "%ALUNO_PROFILE%" (
    echo - ALUNO user profile not found, skipping...
    goto :skip_aluno_profile
)

echo - Found ALUNO profile at: %ALUNO_PROFILE%

REM Delete all files in root (excluding dot-starting, hidden, and system files)
echo - Cleaning ALUNO profile root files...
for %%F in ("%ALUNO_PROFILE%\*") do (
    set "fname=%%~nxF"
    set "fattr=%%~aF"
    setlocal enabledelayedexpansion
    if not "!fname:~0,1!"=="." (
        if "!fattr:~3,1!" NEQ "h" if "!fattr:~4,1!" NEQ "s" (
            del /F /Q "%%F" 2>nul
        )
    )
    endlocal
)

REM Delete all folders EXCEPT dot-starting, AppData, and hidden/system folders
echo - Cleaning ALUNO profile folders...
for /d %%D in ("%ALUNO_PROFILE%\*") do (
    set "dname=%%~nxD"
    set "dattr=%%~aD"
    setlocal enabledelayedexpansion
    if not "!dname:~0,1!"=="." (
        if /I not "!dname!"=="AppData" (
            if "!dattr:~3,1!" NEQ "h" if "!dattr:~4,1!" NEQ "s" (
                echo   Removing: %%~nxD
                rmdir "%%D" /s /q 2>nul
            )
        )
    )
    endlocal
)

REM Clean temporary files
echo - Cleaning ALUNO temporary files...
del /F /Q "%ALUNO_PROFILE%\AppData\Local\Temp\*.*" 2>nul
for /d %%p in ("%ALUNO_PROFILE%\AppData\Local\Temp\*") do rmdir "%%p" /s /q 2>nul

echo ALUNO user profile cleaned successfully.

:skip_aluno_profile
echo.

REM ========================================
REM Step 4: Clean WAMP www folder
REM ========================================
echo [4/8] Cleaning WAMP www folder...

if not exist "%WAMP_WWW%" (
    echo ERROR: WAMP www folder not found at %WAMP_WWW%
    echo Please update the WAMP_WWW path in this script.
    pause
    exit /b 1
)

del /F /Q "%WAMP_WWW%\*.*" 2>nul
for /d %%p in ("%WAMP_WWW%\*") do rmdir "%%p" /s /q 2>nul

echo WAMP www folder cleaned successfully.
echo.

REM ========================================
REM Step 5: Sync VS Code extensions
REM ========================================
echo [5/8] Syncing VS Code extensions...

if /I "%SETUP_WAMP_SKIP_EXTENSION_SYNC%"=="1" (
    echo Skipping extension sync.
) else if not exist "%EXTENSION_LIST%" (
    echo WARNING: Extension list not found at %EXTENSION_LIST%. Skipping extension sync.
) else (
    call :sync_extensions
)
echo VS Code extension sync step finished.
echo.

REM ========================================
REM Step 6: Empty the recycle bin
REM ========================================
echo [6/8] Emptying the recycle bin...

if /I "%SETUP_WAMP_SKIP_RECYCLE_BIN%"=="1" (
    echo Skipping recycle bin cleanup.
) else (
    powershell -command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
)
echo Recycle bin emptied.
echo.

REM ========================================
REM Step 7: Copy project from flash drive
REM ========================================
echo [7/8] Copying project from flash drive...

if defined SOURCE_FOLDER (
    echo Using source folder name: %SOURCE_FOLDER%
) else (
    set /p "SOURCE_FOLDER=Enter source folder name on flash drive: "
)

if "%SOURCE_FOLDER%"=="" (
    echo ERROR: Source folder name cannot be empty.
    pause
    exit /b 1
)

if not "%SOURCE_FOLDER%"=="%SOURCE_FOLDER:\=%" (
    echo ERROR: Source folder name cannot contain path separators.
    pause
    exit /b 1
)

if not "%SOURCE_FOLDER%"=="%SOURCE_FOLDER:/=%" (
    echo ERROR: Source folder name cannot contain path separators.
    pause
    exit /b 1
)

if "%SOURCE_FOLDER%"==".." (
    echo ERROR: Source folder name cannot be ..
    pause
    exit /b 1
)

if not "%SOURCE_FOLDER%"=="%SOURCE_FOLDER:..=%" (
    echo ERROR: Source folder name cannot contain ..
    pause
    exit /b 1
)

set "SOURCE_PATH=.\%SOURCE_FOLDER%"
set "PROJECT_DEST=%WAMP_WWW%\%SOURCE_FOLDER%"

if not exist "%SOURCE_PATH%" (
    echo ERROR: Source folder not found at %SOURCE_PATH%
    pause
    exit /b 1
)

echo Copying from %SOURCE_PATH% to %PROJECT_DEST%...
robocopy "%SOURCE_PATH%" "%PROJECT_DEST%" /E /COPY:DAT /R:2 /W:1 /NFL /NDL /NJH /NJS /NP >nul
set "COPY_EXIT_CODE=%ERRORLEVEL%"

if %COPY_EXIT_CODE% GEQ 8 (
    echo ERROR: Failed to copy files. Robocopy exit code: %COPY_EXIT_CODE%
    pause
    exit /b 1
)

echo Files copied successfully.
echo.

REM ========================================
REM Step 8: Start VS Code
REM ========================================
echo [8/8] Starting VS Code...

if /I "%SETUP_WAMP_SKIP_CODE_LAUNCH%"=="1" (
    echo Skipping VS Code launch.
) else (
    start "" code "%PROJECT_DEST%"
)

echo.
echo ========================================
echo Setup completed successfully!
echo ========================================
echo.
if /I not "%SETUP_WAMP_NO_PAUSE%"=="1" pause
exit /b 0

:sync_extensions
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { $ErrorActionPreference = 'Stop'; $extensionList = '%EXTENSION_LIST%'; if (-not (Test-Path -LiteralPath $extensionList)) { Write-Host ('WARNING: Extension list not found at ' + $extensionList + '. Skipping extension sync.'); exit 0 }; if (-not (Get-Command code -ErrorAction SilentlyContinue)) { Write-Host 'WARNING: VS Code CLI (code) not found. Skipping extension sync.'; exit 0 }; $desired = Get-Content -LiteralPath $extensionList | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') } | Sort-Object -Unique; $current = @(code --list-extensions); if ($LASTEXITCODE -ne 0) { Write-Host 'WARNING: Could not list installed extensions. Skipping extension sync.'; exit 0 }; $current = $current | ForEach-Object { $_.Trim() } | Where-Object { $_ } | Sort-Object -Unique; foreach ($ext in $current) { if ($desired -notcontains $ext) { Write-Host ('Uninstalling extension: ' + $ext); code --uninstall-extension $ext --force; if ($LASTEXITCODE -ne 0) { Write-Host ('WARNING: Failed to uninstall ' + $ext + '. Continuing...') } else { Write-Host ('Removed extension: ' + $ext) } } else { Write-Host ('Keeping required extension: ' + $ext) } }; foreach ($ext in $desired) { if ($current -notcontains $ext) { Write-Host ('Installing extension: ' + $ext); code --install-extension $ext; if ($LASTEXITCODE -ne 0) { Write-Host ('WARNING: Failed to install ' + $ext + '. Continuing...') } else { Write-Host ('Installed extension: ' + $ext) } } else { Write-Host ('Extension already installed: ' + $ext) } }; exit 0 }"
exit /b %ERRORLEVEL%
