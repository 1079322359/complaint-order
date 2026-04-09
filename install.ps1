<#
  优化版：complaint-order 功能自动安装脚本  支持终端输入账号密码 + 自动配置 + 自动安装依赖
#>

# 强制编码 UTF-8，解决中文乱码
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Clear-Host
Write-Host "=== complaint-order 功能 自动安装 ===" -ForegroundColor Cyan
Write-Host ""

# 路径定义
$home = $env:USERPROFILE
$openClawDir = Join-Path $home ".openclaw"
$skillsDir = Join-Path $openClawDir "skills"
$targetDir = Join-Path $skillsDir "complaint-order"

# 检查是否安装 OpenClaw
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
    Write-Host "[OK] $backup" -ForegroundColor Green
    Write-Host ""
}

# 创建目录
Write-Host "[3/5] 创建目录中..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

# 下载
Write-Host "[4/5] 下载功能中..." -ForegroundColor Yellow
$zip = Join-Path $env:TEMP "complaint-order.zip"
Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/duheng-ai/complaint-order/archive/refs/heads/main.zip" -OutFile $zip

# 解压
Expand-Archive -Path $zip -DestinationPath $env:TEMP -Force
Get-ChildItem "$env:TEMP/complaint-order-main/*" | Copy-Item -Destination $targetDir -Recurse -Force

# 清理临时文件
Remove-Item $zip -Force
Remove-Item "$env:TEMP/complaint-order-main" -Recurse -Force
Write-Host "[OK]" -ForegroundColor Green
Write-Host ""

# ======================
# 优化点：终端输入账号密码
# ======================
Write-Host "[5/5] 配置账号密码" -ForegroundColor Yellow
Write-Host ""
$phone = Read-Host "请输入登录手机号"
$password = Read-Host "请输入登录密码"
Write-Host ""

# 读取 index.js
$indexFile = Join-Path $targetDir "index.js"
$indexContent = Get-Content $indexFile -Raw -Encoding UTF8

# 替换账号密码（保留其他配置）
$indexContent = $indexContent -replace 'phone: ".*?"', "phone: `"$phone`""
$indexContent = $indexContent -replace 'password: ".*?"', "password: `"$password`""

# 写入 index.js
$indexContent | Out-File $indexFile -Encoding UTF8

Write-Host "✅ 账号已自动配置完成！" -ForegroundColor Green
Write-Host ""

# ======================
# 优化点：自动安装依赖
# ======================
Write-Host "正在安装 npm 依赖..." -ForegroundColor Yellow
Set-Location $targetDir
npm install
# 替换 && 为 PowerShell 兼容的 if 判断
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  npm install 失败，请手动执行：cd '$targetDir'; npm install" -ForegroundColor Yellow
} else {
    Write-Host "[OK]" -ForegroundColor Green
}
Write-Host ""

# 完成
Write-Host "========================================" -ForegroundColor Green
Write-Host "  安装完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "📁 路径：$targetDir" -ForegroundColor Cyan
Write-Host "📱 手机号：$phone" -ForegroundColor Cyan
Write-Host ""
Write-Host "请重启 OpenClaw 网关：" -ForegroundColor Yellow
Write-Host "  openclaw gateway restart" -ForegroundColor White
Write-Host ""
