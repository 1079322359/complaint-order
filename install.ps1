<#
  浼樺寲鐗堬細complaint-order 鎶€鑳借嚜鍔ㄥ畨瑁呰剼鏈?  鏀寔缁堢杈撳叆璐﹀彿瀵嗙爜 + 鑷姩閰嶇疆 + 鑷姩瑁呬緷璧?#>

# 寮哄埗缂栫爜 UTF-8锛屽交搴曡В鍐充贡鐮?$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Clear-Host
Write-Host "=== complaint-order 鎶€鑳?鑷姩瀹夎 ===" -ForegroundColor Cyan
Write-Host ""

# 璺緞瀹氫箟
$home = $env:USERPROFILE
$openClawDir = Join-Path $home ".openclaw"
$skillsDir = Join-Path $openClawDir "skills"
$targetDir = Join-Path $skillsDir "complaint-order"

# 妫€鏌ユ槸鍚﹀畨瑁?OpenClaw
Write-Host "[1/5] 妫€鏌?OpenClaw..." -ForegroundColor Yellow
if (-not (Test-Path $skillsDir)) {
    Write-Host "閿欒锛氭湭鎵惧埌 OpenClaw锛岃鍏堝畨瑁呬富绋嬪簭锛? -ForegroundColor Red
    exit 1
}
Write-Host "[OK]" -ForegroundColor Green
Write-Host ""

# 澶囦唤鏃х増鏈?if (Test-Path $targetDir) {
    Write-Host "[2/5] 澶囦唤鏃х増鏈?.." -ForegroundColor Yellow
    $backup = "$targetDir-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Move-Item -Path $targetDir -Destination $backup -Force
    Write-Host "[OK] $backup" -ForegroundColor Green
    Write-Host ""
}

# 鍒涘缓鐩綍
Write-Host "[3/5] 鍒涘缓鐩綍涓?.." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

# 涓嬭浇
Write-Host "[4/5] 涓嬭浇鎶€鑳戒腑..." -ForegroundColor Yellow
$zip = Join-Path $env:TEMP "complaint-order.zip"
Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/duheng-ai/complaint-order/archive/refs/heads/main.zip" -OutFile $zip

# 瑙ｅ帇
Expand-Archive -Path $zip -DestinationPath $env:TEMP -Force
Get-ChildItem "$env:TEMP/complaint-order-main/*" | Copy-Item -Destination $targetDir -Recurse -Force

# 娓呯悊涓存椂鏂囦欢
Remove-Item $zip -Force
Remove-Item "$env:TEMP/complaint-order-main" -Recurse -Force
Write-Host "[OK]" -ForegroundColor Green
Write-Host ""

# ======================
# 浼樺寲鐐癸細缁堢杈撳叆璐﹀彿瀵嗙爜
# ======================
Write-Host "[5/5] 閰嶇疆璐﹀彿瀵嗙爜" -ForegroundColor Yellow
Write-Host ""
$phone = Read-Host "璇疯緭鍏ョ櫥褰曟墜鏈哄彿"
$password = Read-Host "璇疯緭鍏ョ櫥褰曞瘑鐮?
Write-Host ""

# 璇诲彇 index.js
$indexFile = Join-Path $targetDir "index.js"
$indexContent = Get-Content $indexFile -Raw -Encoding UTF8

# 鏇挎崲璐﹀彿瀵嗙爜锛堜繚鐣欏叾浠栭厤缃級
$indexContent = $indexContent -replace 'phone: ".*?"', "phone: `"$phone`""
$indexContent = $indexContent -replace 'password: ".*?"', "password: `"$password`""

# 鍐欏叆 index.js
$indexContent | Out-File $indexFile -Encoding UTF8

Write-Host "鉁?璐﹀彿宸茶嚜鍔ㄩ厤缃畬鎴? -ForegroundColor Green
Write-Host ""

# ======================
# 浼樺寲鐐癸細鑷姩瀹夎渚濊禆
# ======================
Write-Host "姝ｅ湪瀹夎 npm 渚濊禆..." -ForegroundColor Yellow
Set-Location $targetDir
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "鈿狅笍  npm install 澶辫触锛岃鎵嬪姩鎵ц锛歝d '$targetDir' && npm install" -ForegroundColor Yellow
} else {
    Write-Host "[OK]" -ForegroundColor Green
}
Write-Host ""

# 瀹屾垚
Write-Host "========================================" -ForegroundColor Green
Write-Host "  瀹夎瀹屾垚锛? -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "馃搧 璺緞锛?targetDir" -ForegroundColor Cyan
Write-Host "馃摫 鎵嬫満鍙凤細$phone" -ForegroundColor Cyan
Write-Host ""
Write-Host "璇烽噸鍚?OpenClaw 缃戝叧锛? -ForegroundColor Yellow
Write-Host "  openclaw gateway restart" -ForegroundColor White
Write-Host ""
