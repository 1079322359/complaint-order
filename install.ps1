<#
  终极修复版：complaint-order 自动安装脚本
  兼容 PowerShell 5.1 | 修复只读变量HOME | 解决乱码/网络问题
#>

# 强制编码 UTF-8 根治乱码
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# 强制启用 TLS1.2 解决GitHub连接失败
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Clear-Host
Write-Host "=== complaint-order 功能 自动安装 ===" -ForegroundColor Cyan
Write-Host ""

# ======================
# 核心修复：$home 改为 $userHome（避开系统只读变量）
# ======================
$userHome = $env:USERPROFILE
$openClawDir = Join-Path $userHome ".openclaw"
$skillsDir = Join-Path $openClawDir "skills"
$targetDir = Join-Path $skillsDir "complaint-order"

# 检查OpenClaw
Write-Host "[1/5] 检查 OpenClaw..." -ForegroundColor Yellow
if (-not (Test-Path $skillsDir)) {
    Write-Host "错误：未找到 OpenClaw，请先安装主程序！" -ForegroundColor Red
    exit 1
}
Write-Host "[OK]" -ForegroundColor Green
Write-Host ""

# 备份旧版本
if (Test-Path $targetDir) {
    Write-Host "[2/5] 备份旧版本..." -ForegroundColor Yellow
    $backup = "$targetDir-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Move-Item -Path $targetDir -Destination $backup -Force
    Write-Host "[OK] 备份完成" -ForegroundColor Green
    Write-Host ""
}

# 创建目录
Write-Host "[3/5] 创建目录中..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

# 下载源码
Write-Host "[4/5] 下载功能中..." -ForegroundColor Yellow
$zip = Join-Path $env:TEMP "complaint-order.zip"
$downloadUrl = "https://github.com/duheng-ai/complaint-order/archive/refs/heads/main.zip"

try {
    Invoke-WebRequest -UseBasicParsing -Uri $downloadUrl -OutFile $zip -TimeoutSec 20
}
catch {
    Write-Host "下载失败，请检查网络！" -ForegroundColor Red
    exit 1
}

# 解压
Expand-Archive -Path $zip -DestinationPath $env:TEMP -Force
Get-ChildItem "$env:TEMP/complaint-order-main/*" | Copy-Item -Destination $targetDir -Recurse -Force

# 清理临时文件
Remove-Item $zip -Force
Remove-Item "$env:TEMP/complaint-order-main" -Recurse -Force
Write-Host "[OK]" -ForegroundColor Green
Write-Host ""

# 配置账号密码
Write-Host "[5/5] 配置账号密码" -ForegroundColor Yellow
$phone = Read-Host "请输入登录手机号"
$password = Read-Host "请输入登录密码"

# 修改配置文件
$indexFile = Join-Path $targetDir "index.js"
$indexContent = Get-Content $indexFile -Raw -Encoding UTF8
$indexContent = $indexContent -replace 'phone: ".*?"', "phone: `"$phone`""
$indexContent = $indexContent -replace 'password: ".*?"', "password: `"$password`""
$indexContent | Out-File $indexFile -Encoding UTF8

Write-Host "✅ 账号配置完成！" -ForegroundColor Green
Write-Host ""

# 安装依赖
Write-Host "正在安装 npm 依赖..." -ForegroundColor Yellow
Set-Location $targetDir
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ npm install 失败，请手动执行" -ForegroundColor Yellow
}
else {
    Write-Host "[OK] 依赖安装完成" -ForegroundColor Green
}

# 完成提示
Write-Host "========================================" -ForegroundColor Green
Write-Host "安装全部完成！" -ForegroundColor Green
Write-Host "请重启网关：openclaw gateway restart"
Write-Host "========================================"
