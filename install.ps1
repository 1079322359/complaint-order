<#
  complaint-order Installer - Final Fixed Version
  Fix: Join-Path Syntax Error + Enhanced Path Search + No Garbled
#>

# Fix Encoding & Network
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Clear-Host
Write-Host "=== complaint-order Auto Installer ===" -ForegroundColor Cyan
Write-Host ""

# ==============================================
#  Enhanced OpenClaw Path Finder (Fixed Syntax)
# ==============================================
function Find-OpenClaw {
    $basePath = $env:USERPROFILE
    $defaultPath = Join-Path $basePath ".openclaw"
    
    $searchPaths = @()
    $searchPaths += $defaultPath
    $searchPaths += "C:\OpenClaw"
    $searchPaths += "D:\.openclaw"
    $searchPaths += "E:\.openclaw"
    $searchPaths += "F:\.openclaw"
    $searchPaths += "C:\Program Files\OpenClaw"

    
    if ($env:OPENCLAW_PATH) {
        $searchPaths += $env:OPENCLAW_PATH
    }

    foreach ($path in $searchPaths) {
        $skillPath = Join-Path $path "skills"
        if (Test-Path $skillPath) {
            return $path
        }
    }
    return $null
}

# Start Search
Write-Host "[1/5] Searching OpenClaw..." -ForegroundColor Yellow
$openClawDir = Find-OpenClaw

if (-not $openClawDir) {
    Write-Host "[ERROR] OpenClaw not found!" -ForegroundColor Red
    Write-Host "Path checked: $searchPaths" -ForegroundColor Gray
    exit 1
}

$skillsDir = Join-Path $openClawDir "skills"
$targetDir = Join-Path $skillsDir "complaint-order"

Write-Host "[OK] OpenClaw located at: $openClawDir" -ForegroundColor Green
Write-Host ""

# Backup Old Version
if (Test-Path $targetDir) {
    Write-Host "[2/5] Backing up old version..." -ForegroundColor Yellow
    $backup = "$targetDir-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Move-Item -Path $targetDir -Destination $backup -Force
    Write-Host "[OK] Backup completed" -ForegroundColor Green
    Write-Host ""
}

# Create Directory
Write-Host "[3/5] Creating directory..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

# Download
Write-Host "[4/5] Downloading files..." -ForegroundColor Yellow
$zip = Join-Path $env:TEMP "complaint-order.zip"
$downloadUrl = "https://github.com/duheng-ai/complaint-order/archive/refs/heads/main.zip"

try {
    Invoke-WebRequest -UseBasicParsing -Uri $downloadUrl -OutFile $zip -TimeoutSec 20
}
catch {
    Write-Host "[ERROR] Download failed! Check network." -ForegroundColor Red
    exit 1
}

# Unzip
Expand-Archive -Path $zip -DestinationPath $env:TEMP -Force
Get-ChildItem "$env:TEMP/complaint-order-main/*" | Copy-Item -Destination $targetDir -Recurse -Force

# Clean Temp Files
Remove-Item $zip -Force
Remove-Item "$env:TEMP/complaint-order-main" -Recurse -Force
Write-Host "[OK] Download & Unzip Success" -ForegroundColor Green
Write-Host ""

# Configure Account
Write-Host "[5/5] Configure your account" -ForegroundColor Yellow
$phone = Read-Host "Phone Number"
$password = Read-Host "Password"

# Modify index.js
$indexFile = Join-Path $targetDir "index.js"
$content = Get-Content $indexFile -Raw -Encoding UTF8
$content = $content -replace 'phone: ".*?"', "phone: `"$phone`""
$content = $content -replace 'password: ".*?"', "password: `"$password`""
$content | Out-File $indexFile -Encoding UTF8

Write-Host "[OK] Account configured successfully" -ForegroundColor Green
Write-Host ""

# Install Dependencies
Write-Host "Installing npm dependencies..." -ForegroundColor Yellow
Set-Location $targetDir
npm install --silent
if ($LASTEXITCODE -ne 0) {
    Write-Host "[WARNING] npm install failed, please run manually" -ForegroundColor Yellow
} else {
    Write-Host "[OK] Dependencies installed" -ForegroundColor Green
}

# Finish
Write-Host "========================================" -ForegroundColor Green
Write-Host "INSTALL SUCCESSFUL!" -ForegroundColor Green
Write-Host "Restart Gateway: openclaw gateway restart"
Write-Host "========================================"
Write-Host ""
