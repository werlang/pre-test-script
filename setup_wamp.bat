@echo off

REM ========================================
REM Setup Script for WAMP Development
REM ========================================

echo Starting setup process...
echo.

REM ========================================
REM Step 1: Clean Current User Folders
REM ========================================
echo [1/6] Cleaning current user folders...

REM Clean all common user folder variations (handles both EN and PT-BR)
echo - Cleaning Downloads...
if exist "%USERPROFILE%\Downloads" rd /s /q "%USERPROFILE%\Downloads" 2>nul & md "%USERPROFILE%\Downloads" 2>nul

echo - Cleaning Documents/Documentos...
if exist "%USERPROFILE%\Documents" rd /s /q "%USERPROFILE%\Documents" 2>nul & md "%USERPROFILE%\Documents" 2>nul
if exist "%USERPROFILE%\Documentos" rd /s /q "%USERPROFILE%\Documentos" 2>nul & md "%USERPROFILE%\Documentos" 2>nul

echo - Cleaning Pictures/Imagens...
if exist "%USERPROFILE%\Pictures" rd /s /q "%USERPROFILE%\Pictures" 2>nul & md "%USERPROFILE%\Pictures" 2>nul
if exist "%USERPROFILE%\Imagens" rd /s /q "%USERPROFILE%\Imagens" 2>nul & md "%USERPROFILE%\Imagens" 2>nul

echo - Cleaning Videos...
if exist "%USERPROFILE%\Videos" rd /s /q "%USERPROFILE%\Videos" 2>nul & md "%USERPROFILE%\Videos" 2>nul

echo - Cleaning Music...
if exist "%USERPROFILE%\Music" rd /s /q "%USERPROFILE%\Music" 2>nul & md "%USERPROFILE%\Music" 2>nul

echo - Cleaning Desktop...
if exist "%USERPROFILE%\Desktop" rd /s /q "%USERPROFILE%\Desktop" 2>nul & md "%USERPROFILE%\Desktop" 2>nul

echo Current user folders cleaned successfully.
echo.

REM ========================================
REM Step 2: Clean ALUNO Public Folders
REM ========================================
echo [2/6] Cleaning ALUNO public folders...

set "DOC_PATH=D:\Documentos\aluno"
set "DOCS_PATH=D:\Documents\aluno"

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
echo [3/6] Cleaning ALUNO user profile folder...

set ALUNO_PROFILE=C:\Users\aluno

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
echo [4/6] Cleaning WAMP www folder...

set WAMP_WWW=C:\wamp64\www

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
REM Step 5: Remove all VS Code extensions
REM ========================================
echo [5/8] Removing all VS Code extensions...

if exist "extension_whitelist.txt" (
    for /f "usebackq delims=" %%i in (`code --list-extensions 2^>nul`) do (
        findstr /c:"%%i" "extension_whitelist.txt" >nul
        if errorlevel 1 (
            echo Uninstalling extension: %%i
            call code --uninstall-extension %%i
        ) else (
            echo Keeping whitelisted extension: %%i
        )
    )
) else (
    for /f "usebackq delims=" %%i in (`code --list-extensions 2^>nul`) do (
        echo Uninstalling extension: %%i
        call code --uninstall-extension %%i
    )
)
echo All extensions removed.
echo.

REM ========================================
REM Step 6: Empty the recycle bin
REM ========================================
echo [6/8] Emptying the recycle bin...

powershell -command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
echo Recycle bin emptied.
echo.

REM ========================================
REM Step 7: Copy project from flash drive
REM ========================================
echo [7/8] Copying project from flash drive...

set /p SOURCE_FOLDER="Enter source folder name on flash drive: "
set SOURCE_PATH=.\%SOURCE_FOLDER%

if not exist "%SOURCE_PATH%" (
    echo ERROR: Source folder not found at %SOURCE_PATH%
    pause
    exit /b 1
)

echo Copying from %SOURCE_PATH% to %WAMP_WWW%...
xcopy "%SOURCE_PATH%\*" "%WAMP_WWW%\%SOURCE_PATH%\" /E /I /H /Y

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to copy files.
    pause
    exit /b 1
)

echo Files copied successfully.
echo.

REM ========================================
REM Step 8: Start VS Code
REM ========================================
echo [8/8] Starting VS Code...

start "" code "%WAMP_WWW%\%SOURCE_PATH%"

echo.
echo ========================================
echo Setup completed successfully!
echo ========================================
echo.
pause
