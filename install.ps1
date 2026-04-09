# UTF-8 BOM marker - complaint-order Installer
$SkillName = "complaint-order"
$RepoUrl = "https://github.com/duheng-ai/complaint-order.git"
$OpenClawSkillsDir = "$env:USERPROFILE\.openclaw\workspace\skills"
$TempDir = "$env:TEMP\$SkillName-install"

Write-Host "=== Installing $SkillName ===" -ForegroundColor Green

# Check OpenClaw
Write-Host "`n[1/6] Checking OpenClaw..." -ForegroundColor Cyan
if (-not (Test-Path $OpenClawSkillsDir)) {
    Write-Host "ERROR: OpenClaw not found at $OpenClawSkillsDir" -ForegroundColor Red
    Write-Host "Please install OpenClaw first" -ForegroundColor Yellow
    exit 1
}

# Backup old
$SkillDir = Join-Path $OpenClawSkillsDir $SkillName
if (Test-Path $SkillDir) {
    Write-Host "`n[2/6] Backing up old version..." -ForegroundColor Yellow
    $BackupDir = "$SkillDir-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Move-Item -Path $SkillDir -Destination $BackupDir -Force
}

# Clone
Write-Host "`n[3/6] Cloning repository..." -ForegroundColor Cyan
if (Test-Path $TempDir) { Remove-Item -Path $TempDir -Recurse -Force }
git clone $RepoUrl $TempDir
if ($LASTEXITCODE -ne 0) { Write-Host "Clone failed" -ForegroundColor Red; exit 1 }

# Install
Write-Host "`n[4/6] Installing to skills directory..." -ForegroundColor Cyan
Move-Item -Path $TempDir -Destination $SkillDir -Force

# Dependencies
Write-Host "`n[5/6] Installing npm dependencies..." -ForegroundColor Cyan
Set-Location $SkillDir
npm install
if ($LASTEXITCODE -ne 0) { Write-Host "Warning: npm install failed" -ForegroundColor Yellow }

# Cleanup
Write-Host "`n[6/6] Cleaning up..." -ForegroundColor Cyan
if (Test-Path $TempDir) { Remove-Item -Path $TempDir -Recurse -Force }

# Config
Write-Host "`n=== Configuration Required ===" -ForegroundColor Cyan
Write-Host "Edit this file: $SkillDir\index.js" -ForegroundColor Yellow
Write-Host "Modify CONFIG section:" -ForegroundColor Yellow
Write-Host "  phone = `"your_phone`"" -ForegroundColor White
Write-Host "  password = `"your_password`"" -ForegroundColor White

# Restart
Write-Host "`n=== Restart Gateway ===" -ForegroundColor Cyan
Write-Host "Run: openclaw gateway restart" -ForegroundColor White

# Done
Write-Host "`n=== Installation Complete ===" -ForegroundColor Green
Write-Host "Send messages with: 鑱旂郴鏂瑰紡锛屾姇璇夊唴瀹癸紝璁㈠崟鍙? -ForegroundColor Cyan
Write-Host "Example:" -ForegroundColor Cyan
Write-Host "  鐢ㄦ埛鎶曡瘔鍐呭锛氬厖鍊?249 鍏? -ForegroundColor White
Write-Host "  鐢ㄦ埛鑱旂郴鏂瑰紡锛?8876509647" -ForegroundColor White
Write-Host "  璁㈠崟鍙凤細4200003034202603317170467000" -ForegroundColor White
