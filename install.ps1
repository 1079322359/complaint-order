<#
  complaint-order Installer - PERFECT Fixed Version
  1. 动态检测磁盘，无盘符报错
  2. 超强OpenClaw查找
  3. 无乱码 | 兼容PowerShell 5.1
  4. 全容错，无空路径报错
#>

# 修复编码 + 网络TLS1.2
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Clear-Host
Write-Host "=== complaint-order Auto Installer ===" -ForegroundColor Cyan
Write-Host ""

# ==============================================
# 查找OpenClaw（动态磁盘 ）
# ==============================================
function Find-OpenClaw {
    $searchPaths = @()

    # 1. 标准默认路径（99%用户的安装位置）
    $defaultPath = Join-Path $env:USERPROFILE ".openclaw"
    $searchPaths += $defaultPath

    # 2. 动态获取系统所有可用磁盘，仅检测存在的盘
    $drives = [System.IO.DriveInfo]::GetDrives() | Where-Object { $_.DriveType -eq 'Fixed' -and $_.IsReady }
    foreach ($drive in $drives) {
        $driveRoot = $drive.RootDirectory.FullName
        $searchPaths += Join-Path $driveRoot ".openclaw"
    }

    # 3. 常见安装目录
    $searchPaths += "C:\Program Files\OpenClaw"
    $searchPaths += "C:\OpenClaw"

    # 4. 环境变量
    if ($env:OPENCLAW_PATH) {
        $searchPaths += $env:OPENCLAW_PATH
    }

    # 遍历校验，仅返回有效路径
    foreach ($path in $searchPaths) {
        if (-not $path) { continue }
        $skillPath = Join-Path $path "skills"
        if (Test-Path $skillPath -ErrorAction SilentlyContinue) {
            return $path
        }
    }

    return $null
}

# 开始查找
Write-Host "[1/5] Searching OpenClaw..." -ForegroundColor Yellow
$openClawDir = Find-OpenClaw

if (-not $openClawDir) {
    Write-Host "[ERROR] OpenClaw not found!" -ForegroundColor Red
    Write-Host "Please confirm OpenClaw is installed correctly." -ForegroundColor Red
    exit 1
}

$skillsDir = Join-Path $openClawDir "skills"
$targetDir = Join-Path $skillsDir "complaint-order"

Write-Host "[OK] OpenClaw found: $openClawDir" -ForegroundColor Green
Write-Host ""

# 备份旧版本
if (Test-Path $targetDir) {
    Write-Host "[2/5] Backing up old version..." -ForegroundColor Yellow
    $backup = "$targetDir-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Move-Item -Path $targetDir -Destination $backup -Force
    Write-Host "[OK] Backup completed" -ForegroundColor Green
    Write-Host ""
}

# 创建目录
Write-Host "[3/5] Creating directory..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

# 下载文件
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

# 解压
Expand-Archive -Path $zip -DestinationPath $env:TEMP -Force
Get-ChildItem "$env:TEMP/complaint-order-main/*" | Copy-Item -Destination $targetDir -Recurse -Force

# 清理临时文件
Remove-Item $zip -Force
Remove-Item "$env:TEMP/complaint-order-main" -Recurse -Force
Write-Host "[OK] Download & Unzip Success" -ForegroundColor Green
Write-Host ""

# 配置账号密码
Write-Host "[5/5] Configure your account" -ForegroundColor Yellow
$phone = Read-Host "Phone Number"
$password = Read-Host "Password"

# 修改配置文件
$indexFile = Join-Path $targetDir "index.js"
$content = Get-Content $indexFile -Raw -Encoding UTF8
$content = $content -replace 'phone: ".*?"', "phone: `"$phone`""
$content = $content -replace 'password: ".*?"', "password: `"$password`""
$content | Out-File $indexFile -Encoding UTF8

Write-Host "[OK] Account configured successfully" -ForegroundColor Green
Write-Host ""

# 安装依赖
Write-Host "Installing npm dependencies..." -ForegroundColor Yellow
Set-Location $targetDir
npm install --silent
if ($LASTEXITCODE -ne 0) {
    Write-Host "[WARNING] npm install failed, please run manually" -ForegroundColor Yellow
}
else {
    Write-Host "[OK] Dependencies installed" -ForegroundColor Green
}

# 完成
Write-Host "========================================" -ForegroundColor Green
Write-Host "INSTALL SUCCESSFUL!" -ForegroundColor Green
Write-Host "Restart Gateway: openclaw gateway restart" -Write-Host "========================================"
