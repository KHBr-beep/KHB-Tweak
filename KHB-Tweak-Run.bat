@echo off
setlocal
cd /d "%~dp0"
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process PowerShell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \'%~dp0ApplyTweaks.ps1\''"
    exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0ApplyTweaks.ps1"
