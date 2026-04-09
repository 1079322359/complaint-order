@echo off
chcp >nul 2>&1 | find "936" >nul
if %errorlevel% equ 0 (
    powershell -ExecutionPolicy Bypass -File "%~dp0install-gbk.ps1"
) else (
    powershell -ExecutionPolicy Bypass -File "%~dp0install.ps1"
)
