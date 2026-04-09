[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ProgressPreference = "SilentlyContinue"

$SkillName = "complaint-order"
$RepoUrl = "https://github.com/duheng-ai/complaint-order.git"
$SkillsDir = "$env:USERPROFILE\.openclaw\workspace\skills"
$TempDir = "$env:TEMP\$SkillName"

Write-Host "=== 正在安装 complaint-order 技能 ===" -ForegroundColor Green
Write-Host "[1/5] 检查 OpenClaw..." -ForegroundColor Cyan
if (-not (Test-Path $SkillsDir)) { Write-Host "错误：未找到 OpenClaw" -ForegroundColor Red; exit 1 }
Write-Host "[OK]" -ForegroundColor Green

$TargetDir = Join-Path $SkillsDir $SkillName
if (Test-Path $TargetDir) {
    Write-Host "[2/5] 备份旧版本..." -ForegroundColor Yellow
    Move-Item $TargetDir "$TargetDir-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')" -Force
}

Write-Host "[3/5] 克隆仓库..." -ForegroundColor Cyan
if (Test-Path $TempDir) { Remove-Item $TempDir -Recurse -Force }
git clone $RepoUrl $TempDir
if ($LASTEXITCODE -ne 0) { Write-Host "克隆失败" -ForegroundColor Red; exit 1 }

Write-Host "[4/5] 安装技能..." -ForegroundColor Cyan
Move-Item $TempDir $TargetDir -Force

Write-Host "[5/5] 安装依赖..." -ForegroundColor Cyan
Set-Location $TargetDir; npm install

Write-Host "`n=== 配置账号 ===" -ForegroundColor Cyan
Write-Host "编辑：$TargetDir\index.js" -ForegroundColor Yellow
Write-Host "修改 CONFIG 中的 phone 和 password`n" -ForegroundColor White

Write-Host "=== 重启网关 ===" -ForegroundColor Cyan
Write-Host "运行：openclaw gateway restart`n" -ForegroundColor White

Write-Host "=== 安装完成 ===" -ForegroundColor Green
Write-Host "使用方法：发送包含 联系方式、投诉内容、订单号 的消息`n" -ForegroundColor Cyan