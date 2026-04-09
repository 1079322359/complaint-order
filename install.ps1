# complaint-order Installer
# Run: powershell -Command "iwr -useb https://raw.githubusercontent.com/duheng-ai/complaint-order/main/install.ps1 | iex"

# Set console encoding to UTF-8 for Chinese display
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ProgressPreference = "SilentlyContinue"

$SkillName = "complaint-order"
$RepoUrl = "https://github.com/duheng-ai/complaint-order.git"
$SkillsDir = "$env:USERPROFILE\.openclaw\workspace\skills"
$TempDir = "$env:TEMP\$SkillName"

Write-Host "========================================" -ForegroundColor Green
Write-Host "  正在安装 complaint-order 技能" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "[1/5] 检查 OpenClaw..." -ForegroundColor Cyan
if (-not (Test-Path $SkillsDir)) {
    Write-Host "错误：未找到 OpenClaw" -ForegroundColor Red
    exit 1
}
Write-Host "[OK]" -ForegroundColor Green
Write-Host ""

$TargetDir = Join-Path $SkillsDir $SkillName
if (Test-Path $TargetDir) {
    Write-Host "[2/5] 备份旧版本..." -ForegroundColor Yellow
    $Backup = "$TargetDir-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Move-Item $TargetDir $Backup -Force
    Write-Host "[OK] $Backup" -ForegroundColor Green
    Write-Host ""
}

Write-Host "[3/5] 克隆仓库..." -ForegroundColor Cyan
if (Test-Path $TempDir) { Remove-Item $TempDir -Recurse -Force }
git clone $RepoUrl $TempDir
if ($LASTEXITCODE -ne 0) { 
    Write-Host "克隆失败，请检查网络" -ForegroundColor Red
    exit 1 
}
Write-Host "[OK]" -ForegroundColor Green
Write-Host ""

Write-Host "[4/5] 安装技能..." -ForegroundColor Cyan
Move-Item $TempDir $TargetDir -Force
Write-Host "[OK] $TargetDir" -ForegroundColor Green
Write-Host ""

Write-Host "[5/5] 安装依赖..." -ForegroundColor Cyan
Set-Location $TargetDir
npm install
Write-Host "[OK]" -ForegroundColor Green
Write-Host ""

if (Test-Path $TempDir) { Remove-Item $TempDir -Recurse -Force }

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  配置账号" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "编辑：$TargetDir\index.js" -ForegroundColor Yellow
Write-Host "修改 CONFIG 中的 phone 和 password" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  重启网关" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "运行：openclaw gateway restart" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "  安装完成" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "使用方法：发送包含 联系方式、投诉内容、订单号 的消息" -ForegroundColor Cyan
Write-Host ""
