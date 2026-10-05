# ==========================================
# KHB Tweak - Gaming / Performance
# ==========================================

$principal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)

if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host ""
    Write-Host "KHB Tweak must be run as Administrator." -ForegroundColor Red
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "          KHB TWEAK - APPLY               " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# ==========================================
# BACKUP
# ==========================================

$BackupPath = Join-Path $PSScriptRoot "BACKUP"
if (-not (Test-Path $BackupPath)) {
    New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
}

Write-Host "[..] Creating Registry Backup..." -ForegroundColor Yellow

$BackupItems = @(
    @{ Key = "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"; File = "BackgroundApps.reg" },
    @{ Key = "HKCU\Control Panel\Mouse"; File = "Mouse.reg" },
    @{ Key = "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications"; File = "Notifications.reg" },
    @{ Key = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; File = "ExplorerAdvanced.reg" },
    @{ Key = "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"; File = "AdvertisingInfo.reg" },
    @{ Key = "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy"; File = "Privacy.reg" }
)

foreach ($Item in $BackupItems) {
    reg export $Item.Key (Join-Path $BackupPath $Item.File) /y 2>$null | Out-Null
}

Write-Host "[OK] Backup created" -ForegroundColor Green
Write-Host ""

function Set-RegDword($Path, $Name, [int]$Value) {
    New-Item -Path $Path -Force | Out-Null
    New-ItemProperty -Path $Path -Name $Name -PropertyType DWord -Value $Value -Force -ErrorAction Stop | Out-Null
}

function Set-RegString($Path, $Name, $Value) {
    New-Item -Path $Path -Force | Out-Null
    New-ItemProperty -Path $Path -Name $Name -PropertyType String -Value $Value -Force -ErrorAction Stop | Out-Null
}

# 1. Activity History
try {
    $Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    Set-RegDword $Path "EnableActivityFeed" 0
    Set-RegDword $Path "PublishUserActivities" 0
    Set-RegDword $Path "UploadUserActivities" 0
    Write-Host "[OK] Activity History" -ForegroundColor Green
} catch { Write-Host "[X] Activity History" -ForegroundColor Red }

# 2. Consumer Features
try {
    Set-RegDword "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" 1
    Write-Host "[OK] Consumer Features" -ForegroundColor Green
} catch { Write-Host "[X] Consumer Features" -ForegroundColor Red }

# 3. Delivery Optimization
try {
    Set-RegDword "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" "DODownloadMode" 0
    Write-Host "[OK] Delivery Optimization" -ForegroundColor Green
} catch { Write-Host "[X] Delivery Optimization" -ForegroundColor Red }

# 4. Background Apps
try {
    Set-RegDword "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "GlobalUserDisabled" 1
    Write-Host "[OK] Background Apps" -ForegroundColor Green
} catch { Write-Host "[X] Background Apps" -ForegroundColor Red }

# 5. Location
try {
    Set-RegString "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" "Value" "Deny"
    Write-Host "[OK] Location" -ForegroundColor Green
} catch { Write-Host "[X] Location" -ForegroundColor Red }

# 6. Advertising ID
try {
    Set-RegDword "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" 0
    Write-Host "[OK] Advertising ID" -ForegroundColor Green
} catch { Write-Host "[X] Advertising ID" -ForegroundColor Red }

# 7. Tailored Experiences
try {
    Set-RegDword "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" "TailoredExperiencesWithDiagnosticDataEnabled" 0
    Write-Host "[OK] Tailored Experiences" -ForegroundColor Green
} catch { Write-Host "[X] Tailored Experiences" -ForegroundColor Red }

# 8. Mouse Acceleration
try {
    $Path = "HKCU:\Control Panel\Mouse"
    Set-RegString $Path "MouseSpeed" "0"
    Set-RegString $Path "MouseThreshold1" "0"
    Set-RegString $Path "MouseThreshold2" "0"
    Write-Host "[OK] Mouse Acceleration" -ForegroundColor Green
} catch { Write-Host "[X] Mouse Acceleration" -ForegroundColor Red }

# 9. Taskbar End Task
try {
    $Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings"
    Set-RegDword $Path "TaskbarEndTask" 1
    Write-Host "[OK] Taskbar End Task" -ForegroundColor Green
} catch { Write-Host "[--] Taskbar End Task - Skipped" -ForegroundColor Yellow }

# 10. Disable Hibernate
powercfg /hibernate off
if ($LASTEXITCODE -eq 0) { Write-Host "[OK] Hibernate Disabled" -ForegroundColor Green }
else { Write-Host "[X] Hibernate" -ForegroundColor Red }

# 11. Temporary Files
Write-Host "[..] Cleaning Temporary Files..." -ForegroundColor Yellow
@("$env:TEMP\*", "$env:WINDIR\Temp\*") | ForEach-Object {
    Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue
}
Write-Host "[OK] Temporary Files" -ForegroundColor Green

# 12. Notifications
try {
    $Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications"
    if (Test-Path $Path) {
        New-ItemProperty -Path $Path -Name "ToastEnabled" -PropertyType DWord -Value 0 -Force -ErrorAction Stop | Out-Null
        Write-Host "[OK] Notifications" -ForegroundColor Green
    } else {
        Write-Host "[--] Notifications - Path Not Found" -ForegroundColor Yellow
    }
} catch { Write-Host "[X] Notifications" -ForegroundColor Red }

# 13. Widgets
Write-Host "[--] Widgets - Skipped" -ForegroundColor Yellow

# Refresh Explorer
Write-Host ""
Write-Host "[..] Restarting Windows Explorer..." -ForegroundColor Yellow
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Process explorer.exe

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "        KHB TWEAK APPLIED SUCCESSFULLY   " -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Backup: $BackupPath" -ForegroundColor Cyan
Write-Host "A Windows restart is recommended." -ForegroundColor Yellow
Write-Host ""
Read-Host "Press Enter to exit"
