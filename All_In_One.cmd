@echo off
setlocal EnableDelayedExpansion

:: ===============================================================================================
:: AUTOMATED SOFTWARE DOWNLOAD TEMPLATE FOR .NET DEVELOPERS
:: Author: TuanCter
:: Usage: Run this file with Admin privileges (Right-click -> Run as Administrator)
:: ===============================================================================================

:: 1. CHECK ADMIN PRIVILEGES
NET SESSION >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] You need to run this file as Administrator.
    echo.
    pause
    exit /b
)

:: 2. CONFIGURE DOWNLOAD DIRECTORY
set "DOWNLOAD_DIR=C:\Installers"

if not exist "%DOWNLOAD_DIR%" (
    mkdir "%DOWNLOAD_DIR%"
    echo [INFO] Created download directory: %DOWNLOAD_DIR%
) else (
    echo [INFO] Using directory: %DOWNLOAD_DIR%
)
echo.

:: ===============================================================================================
:: USER CONFIGURATION AREA
:: -----------------------------------------------------------------------------------------------
:: Option 1: Direct Link (Recommended)
:: Syntax: call :DownloadFile "DIRECT_LINK" "FILENAME.exe"
::
:: Option 2: Get Link from Page via ID (Advanced)
:: Syntax: call :DownloadFromPageId "WEBPAGE_URL" "ELEMENT_ID" "FILENAME.exe"
:: ===============================================================================================

echo Starting download and install via Winget...
echo ---------------------------------------------------

:: 1. VS Code
winget install -e --id Microsoft.VisualStudioCode

:: 2. Git
winget install -e --id Git.Git

:: 3. Visual Studio Community 2022
winget install -e --id Microsoft.VisualStudio.2022.Community

:: 4. Docker Desktop
winget install -e --id Docker.DockerDesktop

:: 5. pgAdmin 4
winget install -e --id PostgreSQL.pgAdmin

:: 6. Cursor (Nếu có trên winget, nếu chưa thì dùng curl như cũ)
:: Hiện tại Cursor chưa ổn định trên winget, giữ lại lệnh curl của bạn cho Cursor là OK.

:: 7. DBeaver
winget install -e --id DBeaver.DBeaver

:: 8. NodeJS (LTS)
winget install -e --id OpenJS.NodeJS.LTS

:: ===============================================================================================
:: END OF USER CONFIGURATION
:: ===============================================================================================

echo.
echo ---------------------------------------------------
echo [SUCCESS] Download process completed!
echo Files saved at: %DOWNLOAD_DIR%
start %DOWNLOAD_DIR%
pause
exit /b

:: ===============================================================================================
:: FUNCTION 1: DOWNLOAD DIRECT FILE
:: ===============================================================================================
:DownloadFile
set "URL=%~1"
set "FILENAME=%~2"

echo [DIRECT] Downloading: %FILENAME% ...
curl -L -o "%DOWNLOAD_DIR%\%FILENAME%" "%URL%"

if %errorLevel% equ 0 (
    echo [OK] Download successful: %FILENAME%
) else (
    echo [FAIL] Error downloading: %FILENAME%
)
echo.
exit /b

:: ===============================================================================================
:: FUNCTION 2: CRAWL PAGE FOR LINK BY ID
:: ===============================================================================================
:DownloadFromPageId
set "PAGE_URL=%~1"
set "ELEMENT_ID=%~2"
set "FILENAME=%~3"

echo [SCAN] Scanning page: %PAGE_URL%
echo        Looking for ID: "%ELEMENT_ID%" ...

:: Execute PowerShell Command to Parse HTML
:: Logic: Fetch HTML -> Find Link with matching ID -> Handle relative URLs -> Download
powershell -Command "$ProgressPreference = 'SilentlyContinue'; try { $page = Invoke-WebRequest -Uri '%PAGE_URL%' -UseBasicParsing; $target = $page.Links | Where-Object { $_.outerHTML -match 'id=[\""'']%ELEMENT_ID%[\""'']' } | Select-Object -First 1; if (-not $target) { throw 'Element ID not found' }; $link = $target.href; if ($link.StartsWith('/')) { $u = [Uri]'%PAGE_URL%'; $link = $u.Scheme + '://' + $u.Host + $link }; Write-Host '        [FOUND] Link: ' $link; Invoke-WebRequest -Uri $link -OutFile '%DOWNLOAD_DIR%\%FILENAME%' } catch { Write-Error 'Failed: ' + $_.Exception.Message; exit 1 }"

if %errorLevel% equ 0 (
    echo [OK] Download successful: %FILENAME%
) else (
    echo [FAIL] Could not retrieve or download file from page.
)
echo.
exit /b
