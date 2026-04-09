# complaint-order Installer for OpenClaw
# Run: powershell -ExecutionPolicy Bypass -File install.ps1

$SkillName = "complaint-order"
$RepoUrl = "https://github.com/duheng-ai/complaint-order.git"
$SkillsDir = "$env:USERPROFILE\.openclaw\workspace\skills"
$TempDir = "$env:TEMP\$SkillName"

Write-Host "=== Installing $SkillName ===" -ForegroundColor Green
Write-Host ""

# Check OpenClaw
Write-Host "Checking OpenClaw..." -ForegroundColor Cyan
if (-not (Test-Path $SkillsDir)) {
    Write-Host "ERROR: OpenClaw not found" -ForegroundColor Red
    exit 1
}

# Backup old
$TargetDir = Join-Path $SkillsDir $SkillName
if (Test-Path $TargetDir) {
    Write-Host "Backing up old version..." -ForegroundColor Yellow
    $Backup = "$TargetDir-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Move-Item $TargetDir $Backup -Force
}

# Clone
Write-Host "Cloning repository..." -ForegroundColor Cyan
if (Test-Path $TempDir) { Remove-Item $TempDir -Recurse -Force }
git clone $RepoUrl $TempDir
if ($LASTEXITCODE -ne 0) { Write-Host "Clone failed" -ForegroundColor Red; exit 1 }

# Install
Write-Host "Installing skill..." -ForegroundColor Cyan
Move-Item $TempDir $TargetDir -Force

# Dependencies
Write-Host "Installing dependencies..." -ForegroundColor Cyan
Set-Location $TargetDir
npm install

# Cleanup
if (Test-Path $TempDir) { Remove-Item $TempDir -Recurse -Force }

# Config
Write-Host ""
Write-Host "=== Configuration ===" -ForegroundColor Cyan
Write-Host "Edit: $TargetDir\index.js" -ForegroundColor Yellow
Write-Host "Set phone and password in CONFIG" -ForegroundColor White

# Restart
Write-Host ""
Write-Host "=== Restart Gateway ===" -ForegroundColor Cyan
Write-Host "Run: openclaw gateway restart" -ForegroundColor White

# Done
Write-Host ""
Write-Host "=== Complete ===" -ForegroundColor Green
Write-Host "Send: LianXiFangShi, TouSuNeiRong, DingDanHao" -ForegroundColor Cyan
