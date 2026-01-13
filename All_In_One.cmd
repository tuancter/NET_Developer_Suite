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

echo Starting download of necessary tools...
echo ---------------------------------------------------

:: 1. VS Code
:: call :DownloadFile "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user" "vscode.exe"

:: 2. Git Cli
:: call :DownloadFromPageId "https://git-scm.com/install/windows" "auto-download-link" "git_setup.exe"

:: 3. Visual Studio Installer
:: call :DownloadFile "https://c2rsetup.officeapps.live.com/c2r/downloadVS.aspx?sku=community&channel=stable&version=VS18&source=VSLandingPage&cid=2500:96daf4c80ba848068751b9f9a688ff0d" "vs_installer.exe"

:: 4. Docker
:: call :DownloadFile "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe?utm_source=docker&utm_medium=webreferral&utm_campaign=dd-smartbutton&utm_location=module&_gl=1*148xoyb*_gcl_au*MTM3MTEyNjYzMC4xNzY4Mjc3NTI3*_ga*MTE2MzAyNjczMi4xNzY4Mjc3NTI4*_ga_XJWPQMJYHQ*czE3NjgyODkxOTQkbzIkZzEkdDE3NjgyODkxOTckajU3JGwwJGgw" "docker.exe"

:: 5. pgAdmin4
:: call :DownloadFile "https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v9.11/windows/pgadmin4-9.11-x64.exe" "pgAdmin4.exe"

:: 6. Cursor
:: call :DownloadFile "https://api2.cursor.sh/updates/download/golden/win32-x64/cursor/2.3" "cursor.exe"

:: 7. Dbeaver 
:: call :DownloadFile "https://dbeaver.io/files/dbeaver-ce-latest-x86_64-setup.exe" "dbeaver.exe"

:: 8. Antigravity
:: call :DownloadFile "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.13.3-4533425205018624/windows-x64/Antigravity.exe" "antigravity.exe"

:: 9. NodeJS 
:: call :DownloadFile "https://nodejs.org/dist/v24.12.0/node-v24.12.0-x64.msi" "nodejs.exe"

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
