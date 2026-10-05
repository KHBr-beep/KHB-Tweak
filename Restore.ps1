# ==========================================
# KHB Tweak - Restore
# ==========================================

$principal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)

if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host ""
    Write-Host "KHB Restore must be run as Administrator." -ForegroundColor Red
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "          KHB RESTORE                    " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$BackupPath = Join-Path $PSScriptRoot "BACKUP"
if (-not (Test-Path $BackupPath)) {
    Write-Host "[X] BACKUP folder not found" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "[..] Restoring Registry Backup..." -ForegroundColor Yellow

$BackupFiles = @(
    "BackgroundApps.reg",
    "Mouse.reg",
    "Notifications.reg",
    "ExplorerAdvanced.reg",
    "AdvertisingInfo.reg",
    "Privacy.reg"
)

foreach ($File in $BackupFiles) {
    $FullPath = Join-Path $BackupPath $File
    if (Test-Path $FullPath) {
        reg import "$FullPath" 2>$null | Out-Null
        Write-Host "[OK] Restored $File" -ForegroundColor Green
    } else {
        Write-Host "[--] Missing $File" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "[..] Removing KHB Policy Tweaks..." -ForegroundColor Yellow

Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -ErrorAction SilentlyContinue
Write-Host "[OK] Activity History" -ForegroundColor Green

Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -ErrorAction SilentlyContinue
Write-Host "[OK] Consumer Features" -ForegroundColor Green

Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -ErrorAction SilentlyContinue
Write-Host "[OK] Delivery Optimization" -ForegroundColor Green

Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -ErrorAction SilentlyContinue
Write-Host "[OK] Location" -ForegroundColor Green

powercfg /hibernate on
if ($LASTEXITCODE -eq 0) { Write-Host "[OK] Hibernate Enabled" -ForegroundColor Green }
else { Write-Host "[X] Hibernate" -ForegroundColor Red }

Write-Host ""
Write-Host "[..] Restarting Windows Explorer..." -ForegroundColor Yellow
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Process explorer.exe

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "          KHB RESTORE COMPLETE            " -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "A Windows restart is recommended." -ForegroundColor Yellow
Write-Host ""
Read-Host "Press Enter to exit"
