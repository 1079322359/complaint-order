# 编码与网络修复
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Clear-Host
Write-Host "=== complaint-order Auto Installer ===" -ForegroundColor Cyan
Write-Host ""

# ==============================================
# 🔥 超强 OpenClaw 目录查找逻辑（增强版）
# ==============================================
function Find-OpenClaw {
    $paths = @(
        # 1. 默认用户目录
        Join-Path $env:USERPROFILE ".openclaw",
        # 2. 所有磁盘根目录
        "D:\.openclaw", "E:\.openclaw", "F:\.openclaw",
        # 3. 常见安装目录
        "C:\Program Files\OpenClaw",
        "C:\OpenClaw",
        $env:OPENCLAW_PATH
    )

    # 遍历查找
    foreach ($p in $paths) {
        $testSkill = Join-Path $p "skills"
        if (Test-Path $testSkill) {
            return $p
        }
    }
    return $null
}

# 开始查找
Write-Host "[1/5] Searching OpenClaw..." -ForegroundColor Yellow
$openClawDir = Find-OpenClaw

if (-not $openClawDir) {
    Write-Host "[ERROR] OpenClaw not found!" -ForegroundColor Red
    exit 1
}

$skillsDir = Join-Path $openClawDir "skills"
$targetDir = Join-Path $skillsDir "complaint-order"

Write-Host "[OK] OpenClaw found at: $openClawDir" -ForegroundColor Green
Write-Host ""

# 备份旧版本
if (Test-Path $targetDir) {
    Write-Host "[2/5] Backing up old version..." -ForegroundColor Yellow
    $backup = "$targetDir-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Move-Item -Path $targetDir -Destination $backup -Force
    Write-Host "[OK] Backup done" -ForegroundColor Green
    Write-Host ""
}

# 创建目录
Write-Host "[3/5] Creating directory..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

# 下载
Write-Host "[4/5] Downloading..." -ForegroundColor Yellow
$zip = Join-Path $env:TEMP "complaint-order.zip"
$url = "https://github.com/duheng-ai/complaint-order/archive/refs/heads/main.zip"

try {
    iwr -useb $url -OutFile $zip -TimeoutSec 20
}
catch {
    Write-Host "[ERROR] Download failed!" -ForegroundColor Red
    exit 1
}

# 解压
Expand-Archive -Path $zip -DestinationPath $env:TEMP -Force
Get-ChildItem "$env:TEMP/complaint-order-main/*" | Copy-Item -Destination $targetDir -Recurse -Force

# 清理
Remove-Item $zip -Force
Remove-Item "$env:TEMP/complaint-order-main" -Recurse -Force
Write-Host "[OK] Download success" -ForegroundColor Green
Write-Host ""

# 配置账号
Write-Host "[5/5] Config account" -ForegroundColor Yellow
$phone = Read-Host "Phone"
$password = Read-Host "Password"

$indexFile = Join-Path $targetDir "index.js"
$content = Get-Content $indexFile -Raw -Encoding UTF8
$content = $content -replace 'phone: ".*?"', "phone: `"$phone`""
$content = $content -replace 'password: ".*?"', "password: `"$password`""
$content | Out-File $indexFile -Encoding UTF8

Write-Host "[OK] Account configured" -ForegroundColor Green
Write-Host ""

# 安装依赖
Write-Host "Installing dependencies..." -ForegroundColor Yellow
Set-Location $targetDir
npm install --silent
if ($LASTEXITCODE -ne 0) {
    Write-Host "[WARN] Please run manually: npm install" -ForegroundColor Yellow
}
else {
    Write-Host "[OK] Dependencies installed" -ForegroundColor Green
}

# 完成
Write-Host "========================================" -ForegroundColor Green
Write-Host "INSTALL SUCCESS!" -ForegroundColor Green
Write-Host "Restart: openclaw gateway restart"
Write-Host "========================================"
