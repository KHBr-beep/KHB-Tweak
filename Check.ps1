# ==========================================
# KHB Tweak - Full Check
# ==========================================

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "        KHB Tweak - Full Check            " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$activity = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -ErrorAction SilentlyContinue
if ($activity -eq 0) { Write-Host "[OK] Activity History" -ForegroundColor Green } else { Write-Host "[X] Activity History" -ForegroundColor Red }

$consumer = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -ErrorAction SilentlyContinue
if ($consumer -eq 1) { Write-Host "[OK] Consumer Features" -ForegroundColor Green } else { Write-Host "[X] Consumer Features" -ForegroundColor Red }

$delivery = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -ErrorAction SilentlyContinue
if ($delivery -eq 0) { Write-Host "[OK] Delivery Optimization" -ForegroundColor Green } else { Write-Host "[X] Delivery Optimization" -ForegroundColor Red }

$background = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -ErrorAction SilentlyContinue
if ($null -ne $background -and $background.PSObject.Properties.Name -contains "GlobalUserDisabled" -and $background.GlobalUserDisabled -eq 1) { Write-Host "[OK] Background Apps" -ForegroundColor Green } else { Write-Host "[X] Background Apps" -ForegroundColor Red }

$location = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -ErrorAction SilentlyContinue
if ($location -eq "Deny") { Write-Host "[OK] Location" -ForegroundColor Green } else { Write-Host "[X] Location" -ForegroundColor Red }

$advertising = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -ErrorAction SilentlyContinue
if ($advertising -eq 0) { Write-Host "[OK] Advertising ID" -ForegroundColor Green } else { Write-Host "[X] Advertising ID" -ForegroundColor Red }

$tailored = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -ErrorAction SilentlyContinue
if ($tailored -eq 0) { Write-Host "[OK] Tailored Experiences" -ForegroundColor Green } else { Write-Host "[X] Tailored Experiences" -ForegroundColor Red }

$mouse = Get-ItemProperty -Path "HKCU:\Control Panel\Mouse" -ErrorAction SilentlyContinue
if ($null -ne $mouse -and $mouse.MouseSpeed -eq "0" -and $mouse.MouseThreshold1 -eq "0" -and $mouse.MouseThreshold2 -eq "0") { Write-Host "[OK] Mouse Acceleration" -ForegroundColor Green } else { Write-Host "[X] Mouse Acceleration" -ForegroundColor Red }

$endTask = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" -Name "TaskbarEndTask" -ErrorAction SilentlyContinue
if ($endTask -eq 1) { Write-Host "[OK] Taskbar End Task" -ForegroundColor Green } else { Write-Host "[X] Taskbar End Task" -ForegroundColor Red }

$hibernate = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HibernateEnabled" -ErrorAction SilentlyContinue
if ($hibernate -eq 0) { Write-Host "[OK] Hibernate Disabled" -ForegroundColor Green } else { Write-Host "[X] Hibernate Enabled" -ForegroundColor Red }

$notifications = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -ErrorAction SilentlyContinue
if ($notifications -eq 0) { Write-Host "[OK] Notifications" -ForegroundColor Green } else { Write-Host "[X] Notifications" -ForegroundColor Red }

Write-Host "[--] Widgets - Skipped" -ForegroundColor Yellow

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "             Check Complete               " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Read-Host "Press Enter to exit"
