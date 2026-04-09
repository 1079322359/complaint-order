# complaint-order Installer
# Run: powershell -Command "iwr -useb https://raw.githubusercontent.com/duheng-ai/complaint-order/main/install.ps1 | iex"

$SkillName = "complaint-order"
$RepoUrl = "https://github.com/duheng-ai/complaint-order.git"
$SkillsDir = "$env:USERPROFILE\.openclaw\workspace\skills"
$TempDir = "$env:TEMP\$SkillName"

# Set UTF-8 output for Chinese display
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Chinese messages
$M1 = "正在安装 complaint-order 技能"
$M2 = "检查 OpenClaw..."
$M3 = "错误：未找到 OpenClaw"
$M4 = "备份旧版本..."
$M5 = "克隆仓库..."
$M6 = "克隆失败"
$M7 = "安装技能..."
$M8 = "安装依赖..."
$M9 = "配置账号"
$M10 = "编辑"
$M11 = "修改 CONFIG 中的 phone 和 password"
$M12 = "重启网关"
$M13 = "运行：openclaw gateway restart"
$M14 = "安装完成"
$M15 = "使用方法：发送包含 联系方式、投诉内容、订单号 的消息"

Write-Host "=== $M1 ===" -ForegroundColor Green
Write-Host "[1/5] $M2" -ForegroundColor Cyan
if (-not (Test-Path $SkillsDir)) { Write-Host $M3 -ForegroundColor Red; exit 1 }
Write-Host "[OK]" -ForegroundColor Green

$TargetDir = Join-Path $SkillsDir $SkillName
if (Test-Path $TargetDir) {
    Write-Host "[2/5] $M4" -ForegroundColor Yellow
    Move-Item $TargetDir "$TargetDir-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')" -Force
}

Write-Host "[3/5] $M5" -ForegroundColor Cyan
if (Test-Path $TempDir) { Remove-Item $TempDir -Recurse -Force }
git clone $RepoUrl $TempDir
if ($LASTEXITCODE -ne 0) { Write-Host $M6 -ForegroundColor Red; exit 1 }

Write-Host "[4/5] $M7" -ForegroundColor Cyan
Move-Item $TempDir $TargetDir -Force

Write-Host "[5/5] $M8" -ForegroundColor Cyan
Set-Location $TargetDir; npm install

Write-Host "`n=== $M9 ===" -ForegroundColor Cyan
Write-Host "$M10`: $TargetDir\index.js" -ForegroundColor Yellow
Write-Host $M11 -ForegroundColor White

Write-Host "`n=== $M12 ===" -ForegroundColor Cyan
Write-Host $M13 -ForegroundColor White

Write-Host "`n=== $M14 ===" -ForegroundColor Green
Write-Host $M15 -ForegroundColor Cyan
Write-Host ""