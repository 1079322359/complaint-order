# complaint-order Skill Installer
# Usage: powershell -ExecutionPolicy Bypass -File install.ps1

$ErrorActionPreference = "Stop"

# Configuration
$SkillName = "complaint-order"
$RepoUrl = "https://github.com/duheng-ai/complaint-order.git"
$OpenClawSkillsDir = "$env:USERPROFILE\.openclaw\workspace\skills"
$TempDir = "$env:TEMP\$SkillName-install"

Write-Host "========================================"
Write-Host "  Installing $SkillName"
Write-Host "========================================"
Write-Host ""

# Step 1: Check OpenClaw
Write-Host "[1/6] Checking OpenClaw installation..." -ForegroundColor Cyan
if (-not (Test-Path $OpenClawSkillsDir)) {
    Write-Host "ERROR: OpenClaw not found at: $OpenClawSkillsDir" -ForegroundColor Red
    Write-Host "Please install OpenClaw first." -ForegroundColor Yellow
    exit 1
}
Write-Host "OK: OpenClaw found" -ForegroundColor Green
Write-Host ""

# Step 2: Backup old version
$SkillDir = Join-Path $OpenClawSkillsDir $SkillName
if (Test-Path $SkillDir) {
    Write-Host "[2/6] Backing up old version..." -ForegroundColor Cyan
    $BackupDir = "$SkillDir-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Move-Item -Path $SkillDir -Destination $BackupDir -Force
    Write-Host "OK: Backup saved to: $BackupDir" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "[2/6] No old version found, skipping backup" -ForegroundColor Cyan
    Write-Host ""
}

# Step 3: Clone repository
Write-Host "[3/6] Cloning repository from GitHub..." -ForegroundColor Cyan
if (Test-Path $TempDir) {
    Remove-Item -Path $TempDir -Recurse -Force
}
git clone $RepoUrl $TempDir
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to clone repository" -ForegroundColor Red
    Write-Host "Please check your network connection and try again." -ForegroundColor Yellow
    exit 1
}
Write-Host "OK: Repository cloned" -ForegroundColor Green
Write-Host ""

# Step 4: Install skill
Write-Host "[4/6] Installing skill to OpenClaw..." -ForegroundColor Cyan
Move-Item -Path $TempDir -Destination $SkillDir -Force
Write-Host "OK: Skill installed to: $SkillDir" -ForegroundColor Green
Write-Host ""

# Step 5: Install dependencies
Write-Host "[5/6] Installing npm dependencies..." -ForegroundColor Cyan
Set-Location $SkillDir
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: npm install failed" -ForegroundColor Yellow
    Write-Host "Please run manually: cd '$SkillDir' && npm install" -ForegroundColor White
} else {
    Write-Host "OK: Dependencies installed" -ForegroundColor Green
}
Write-Host ""

# Step 6: Cleanup
Write-Host "[6/6] Cleaning up temporary files..." -ForegroundColor Cyan
if (Test-Path $TempDir) {
    Remove-Item -Path $TempDir -Recurse -Force
}
Write-Host "OK: Cleanup completed" -ForegroundColor Green
Write-Host ""

# Configuration instructions
Write-Host "========================================"
Write-Host "  Configuration Required"
Write-Host "========================================"
Write-Host ""
Write-Host "Please edit this file:" -ForegroundColor Yellow
Write-Host "  $SkillDir\index.js" -ForegroundColor White
Write-Host ""
Write-Host "Find the CONFIG section and modify:" -ForegroundColor Yellow
Write-Host "  phone:    'your_phone_number'" -ForegroundColor White
Write-Host "  password: 'your_password'" -ForegroundColor White
Write-Host ""

# Restart gateway
Write-Host "========================================"
Write-Host "  Restart OpenClaw Gateway"
Write-Host "========================================"
Write-Host ""
Write-Host "Run this command:" -ForegroundColor Yellow
Write-Host "  openclaw gateway restart" -ForegroundColor White
Write-Host ""

# Completion
Write-Host "========================================"
Write-Host "  Installation Complete!"
Write-Host "========================================"
Write-Host ""
Write-Host "Usage: Send messages containing these keywords:" -ForegroundColor Cyan
Write-Host "  - 联系方式 (contact information)" -ForegroundColor White
Write-Host "  - 投诉内容 (complaint content)" -ForegroundColor White
Write-Host "  - 订单�?(order number)" -ForegroundColor White
Write-Host ""
Write-Host "Example message:" -ForegroundColor Cyan
Write-Host "  用户投诉内容：充�?249 元，网卡的不�? -ForegroundColor White
Write-Host "  用户联系方式�?8876509647" -ForegroundColor White
Write-Host "  订单号：4200003034202603317170467000" -ForegroundColor White
Write-Host ""
Write-Host "Enjoy!" -ForegroundColor Green
Write-Host ""
