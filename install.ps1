<#
  complaint-order Installer (Fixed - No Garbled + Path Fix)
  Compatible with PowerShell 5.1
#>

# Fix Encoding (NO CHINESE = NO GARBLED TEXT)
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Fix GitHub Connection
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Clear-Host
Write-Host "=== complaint-order Auto Installer ===" -ForegroundColor Cyan
Write-Host ""

# ======================
# FIX 1: Avoid Read-Only Variable $home
# FIX 2: Auto Detect OpenClaw Path Correctly
# ======================
$userHome = $env:USERPROFILE
$openClawDir = Join-Path $userHome ".openclaw"
$skillsDir = Join-Path $openClawDir "skills"
$targetDir = Join-Path $skillsDir "complaint-order"

# Debug: Show Check Path
Write-Host "[1/5] Checking OpenClaw Directory..." -ForegroundColor Yellow
Write-Host "Detected Path: $skillsDir" -ForegroundColor Gray

# Check OpenClaw
if (-not (Test-Path $skillsDir)) {
    Write-Host "[ERROR] OpenClaw skills folder not found!" -ForegroundColor Red
    Write-Host "Please install OpenClaw first, then run this script again." -ForegroundColor Red
    exit 1
}
Write-Host "[OK] OpenClaw Detected" -ForegroundColor Green
Write-Host ""

# Backup Old Version
if (Test-Path $targetDir) {
    Write-Host "[2/5] Backing up old version..." -ForegroundColor Yellow
    $backup = "$targetDir-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Move-Item -Path $targetDir -Destination $backup -Force
    Write-Host "[OK] Backup: $backup" -ForegroundColor Green
    Write-Host ""
}

# Create Folder
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
    Write-Host "[ERROR] Download Failed! Check Network." -ForegroundColor Red
    exit 1
}

# Unzip
Expand-Archive -Path $zip -DestinationPath $env:TEMP -Force
Get-ChildItem "$env:TEMP/complaint-order-main/*" | Copy-Item -Destination $targetDir -Recurse -Force

# Clean Temp
Remove-Item $zip -Force
Remove-Item "$env:TEMP/complaint-order-main" -Recurse -Force
Write-Host "[OK] Download Complete" -ForegroundColor Green
Write-Host ""

# Config Account
Write-Host "[5/5] Configure Account" -ForegroundColor Yellow
$phone = Read-Host "Enter Phone Number"
$password = Read-Host "Enter Password"

# Update index.js
$indexFile = Join-Path $targetDir "index.js"
$indexContent = Get-Content $indexFile -Raw -Encoding UTF8
$indexContent = $indexContent -replace 'phone: ".*?"', "phone: `"$phone`""
$indexContent = $indexContent -replace 'password: ".*?"', "password: `"$password`""
$indexContent | Out-File $indexFile -Encoding UTF8

Write-Host "[OK] Account Configured" -ForegroundColor Green
Write-Host ""

# Install Dependencies
Write-Host "Installing npm dependencies..." -ForegroundColor Yellow
Set-Location $targetDir
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "[WARNING] npm install failed, run manually: cd '$targetDir'; npm install" -ForegroundColor Yellow
}
else {
    Write-Host "[OK] Dependencies Installed" -ForegroundColor Green
}

# Finish
Write-Host "========================================" -ForegroundColor Green
Write-Host "Install Success!" -ForegroundColor Green
Write-Host "Restart Gateway: openclaw gateway restart"
Write-Host "========================================"
Write-Host ""
