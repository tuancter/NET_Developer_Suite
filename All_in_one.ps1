<#
.SYNOPSIS
    AUTOMATED SOFTWARE DOWNLOAD SCRIPT FOR .NET DEVELOPERS
.DESCRIPTION
    Script tự động tải về các công cụ cần thiết cho lập trình viên.
    Tự động check quyền Admin và tạo thư mục lưu trữ.
.AUTHOR
    TuanCter
#>

# ==============================================================================
# 1. AUTO ELEVATE TO ADMIN (Tự động xin quyền Admin)
# ==============================================================================
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Dang khoi dong lai voi quyen Administrator..." -ForegroundColor Yellow
    Start-Process PowerShell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Exit
}

$ErrorActionPreference = "Stop"
Clear-Host

# ==============================================================================
# 2. CONFIGURATION
# ==============================================================================
$DownloadDir = "C:\Installers"

# Cấu hình TLS 1.2 để tránh lỗi download từ GitHub/Docker
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Tạo thư mục nếu chưa có
if (-not (Test-Path -Path $DownloadDir)) {
    New-Item -ItemType Directory -Force -Path $DownloadDir | Out-Null
    Write-Host "[INFO] Da tao thu muc: $DownloadDir" -ForegroundColor Cyan
} else {
    Write-Host "[INFO] Su dung thu muc: $DownloadDir" -ForegroundColor Cyan
}
Write-Host "---------------------------------------------------"

# ==============================================================================
# 3. HELPER FUNCTIONS
# ==============================================================================

function Download-File {
    param(
        [string]$Url,
        [string]$FileName
    )
    $OutputPath = Join-Path -Path $DownloadDir -ChildPath $FileName
    
    Write-Host " [DOWN] Dang tai: $FileName ..." -NoNewline
    
    try {
        Invoke-WebRequest -Uri $Url -OutFile $OutputPath -UseBasicParsing
        Write-Host " [OK]" -ForegroundColor Green
    }
    catch {
        Write-Host " [FAIL]" -ForegroundColor Red
        Write-Warning "Loi: $($_.Exception.Message)"
    }
}

function Download-FromPageId {
    param(
        [string]$PageUrl,
        [string]$ElementId,
        [string]$FileName
    )
    Write-Host " [SCAN] Dang quet trang: $PageUrl tim ID '$ElementId'..."
    
    try {
        $page = Invoke-WebRequest -Uri $PageUrl -UseBasicParsing
        # Tìm thẻ 'a' có id khớp
        $link = $page.Links | Where-Object { $_.id -eq $ElementId } | Select-Object -ExpandProperty href -First 1

        if ($link) {
            # Xử lý link tương đối (relative path)
            if ($link -match "^/") {
                $uri = [Uri]$PageUrl
                $link = "{0}://{1}{2}" -f $uri.Scheme, $uri.Host, $link
            }
            # Gọi lại hàm download thường
            Download-File -Url $link -FileName $FileName
        } else {
            Write-Host " [FAIL] Khong tim thay Element ID: $ElementId" -ForegroundColor Red
        }
    }
    catch {
        Write-Host " [FAIL] Loi khi quet trang web." -ForegroundColor Red
        Write-Warning $_.Exception.Message
    }
}

# ==============================================================================
# 4. DOWNLOAD LIST (TuanCter Config)
# ==============================================================================

Write-Host "Bat dau tai cac cong cu..." -ForegroundColor Yellow

# 1. VS Code (Link System Installer ổn định hơn User)
Download-File -Url "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64" -FileName "vscode_setup.exe"

# 2. Git CLI (Quét trang chủ lấy link mới nhất qua ID)
Download-FromPageId -PageUrl "https://git-scm.com/install/windows" -ElementId "auto-download-link" -FileName "git_setup.exe"

# 3. Visual Studio Installer
Download-File -Url "https://c2rsetup.officeapps.live.com/c2r/downloadVS.aspx?sku=community&channel=stable&version=VS18" -FileName "vs_installer.exe"

# 4. Docker Desktop (Link direct clean)
Download-File -Url "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe" -FileName "docker_setup.exe"

# 5. pgAdmin 4
Download-File -Url "https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v9.11/windows/pgadmin4-9.11-x64.exe" -FileName "pgadmin4.exe"

# 6. Cursor (Link cập nhật)
Download-File -Url "https://downloader.cursor.sh/windows/x64" -FileName "cursor_setup.exe"

# 7. DBeaver Community
Download-File -Url "https://dbeaver.io/files/dbeaver-ce-latest-x86_64-setup.exe" -FileName "dbeaver_setup.exe"

# 8. Antigravity (Cần link trực tiếp, link cũ có token hết hạn sẽ lỗi)
# Download-File -Url "YOUR_DIRECT_LINK_HERE" -FileName "antigravity.exe"

# 9. NodeJS LTS (Link direct trỏ về bản v22 LTS mới nhất thay vì fix cứng v24)
Download-File -Url "https://nodejs.org/dist/v22.13.0/node-v22.13.0-x64.msi" -FileName "nodejs.msi"


# ==============================================================================
# 5. FINISH
# ==============================================================================
Write-Host "---------------------------------------------------"
Write-Host "[SUCCESS] Qua trinh tai ve hoan tat!" -ForegroundColor Green
Write-Host "File duoc luu tai: $DownloadDir"
Start-Process $DownloadDir
Write-Host "Nhan Enter de thoat..."
Read-Host
