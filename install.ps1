<#
  优化版：complaint-order 技能自动安装脚本
  支持终端输入账号密码 + 自动配置 + 自动装依赖
#>

# 强制编码 UTF-8，彻底解决乱码
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Clear-Host
Write-Host "=== complaint-order 技能 自动安装 ===" -ForegroundColor Cyan

# 路径定义
$home = $env:USERPROFILE
$openClawDir = Join-Path $home ".openclaw"
$skillsDir = Join-Path $openClawDir "skills"
$targetDir = Join-Path $skillsDir "complaint-order"

# 检查是否安装 OpenClaw
if (-not (Test-Path $skillsDir)) {
    Write-Host "错误：未找到 OpenClaw，请先安装主程序！" -ForegroundColor Red
    exit 1
}

# 创建目录
Write-Host "[1/4] 创建目录中..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

# 下载
Write-Host "[2/4] 下载技能中..." -ForegroundColor Yellow
$zip = Join-Path $env:TEMP "complaint-order.zip"
Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/duheng-ai/complaint-order/archive/refs/heads/main.zip" -OutFile $zip

# 解压
Expand-Archive -Path $zip -DestinationPath $env:TEMP -Force
Get-ChildItem "$env:TEMP/complaint-order-main/*" | Copy-Item -Destination $targetDir -Recurse -Force

# 清理临时文件
Remove-Item $zip -Force
Remove-Item "$env:TEMP/complaint-order-main" -Recurse -Force

# ======================
# 优化点：终端输入账号密码
# ======================
Write-Host "[3/4] 配置账号密码" -ForegroundColor Yellow
$phone = Read-Host "请输入登录手机号"
$password = Read-Host "请输入登录密码"

# 生成配置文件
$config = @"
module.exports = {
  LOGIN: {
    phone: "$phone",
    password: "$password"
  }
};
"@

# 写入 config.js
$configFile = Join-Path $targetDir "config.js"
$config | Out-File $configFile -Encoding UTF8

Write-Host "✅ 账号已自动配置完成" -ForegroundColor Green

# ======================
# 优化点：自动安装依赖
# ======================
Write-Host "[4/4] 自动安装 npm 依赖..." -ForegroundColor Yellow
Set-Location $targetDir
npm install --silent

Write-Host "`n🎉 安装全部完成！" -ForegroundColor Green
Write-Host "📁 路径：$targetDir`n" -ForegroundColor Cyan
Write-Host "请重启 OpenClaw 网关即可使用！`n" -ForegroundColor Cyan
