# VOLYA - deploy na Android z prikazoveho riadku.
#
# Nahradzuje one-click deploy v editore: export -> instalacia -> spustenie
# -> zive logy z telefonu. Trva ~40 sekund.
#
#   powershell -ExecutionPolicy Bypass -File "D:\2026\Slavs figh back\tools\deploy_android.ps1"
#
# Prepinace:
#   -NoLaunch    nainstaluje, ale nespusti hru
#   -NoLogs      nebude streamovat logcat (skript hned skonci)
#
# POZOR: tento subor musi zostat v ciste ASCII. Windows PowerShell 5.1 cita
# .ps1 v ANSI kodovani a UTF-8 znaky (pomlcka, diakritika) rozbiju parsing.

param(
    [switch]$NoLaunch,
    [switch]$NoLogs
)

# --- cesty (uprav podla svojej instalacie) ---
$Godot   = "D:\Tools\Godot\Godot_v4.7.1-stable_win64.exe"
$Adb     = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"
$Project = "D:\2026\Slavs figh back\volya"
$Preset  = "Android"
$Package = "sk.pavel.volya"

$ErrorActionPreference = "Stop"

$BuildDir = Join-Path $Project "build"
$Apk = Join-Path $BuildDir "volya-debug.apk"
New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null

foreach ($path in @($Godot, $Adb)) {
    if (-not (Test-Path $path)) {
        Write-Host "CHYBA: neexistuje cesta $path" -ForegroundColor Red
        Write-Host "Uprav cesty na zaciatku tohto skriptu." -ForegroundColor Yellow
        exit 1
    }
}

Write-Host "1/4  Kontrola zariadenia..." -ForegroundColor Cyan
$devices = & $Adb devices | Where-Object { $_ -match "^\S+\s+device\s*$" }
if (-not $devices) {
    Write-Host "CHYBA: ziadne autorizovane zariadenie." -ForegroundColor Red
    & $Adb devices
    exit 1
}
Write-Host ("      OK: " + ($devices[0] -replace "\s+", "  "))

Write-Host "2/4  Export APK..." -ForegroundColor Cyan
$sw = [System.Diagnostics.Stopwatch]::StartNew()
& $Godot --headless --path $Project --export-debug $Preset $Apk
if ($LASTEXITCODE -ne 0 -or -not (Test-Path $Apk)) {
    Write-Host "CHYBA: export zlyhal. Skontroluj nazov presetu '$Preset'." -ForegroundColor Red
    exit 1
}
$size = [math]::Round((Get-Item $Apk).Length / 1MB, 1)
Write-Host ("      OK: $size MB za " + [math]::Round($sw.Elapsed.TotalSeconds, 1) + " s")

Write-Host "3/4  Instalacia..." -ForegroundColor Cyan
# Ukonci bezianu instanciu, inak by sa po instalacii len prepol na stary proces.
& $Adb shell am force-stop $Package 2>$null | Out-Null
& $Adb install -r $Apk
if ($LASTEXITCODE -ne 0) {
    Write-Host "CHYBA: instalacia zlyhala." -ForegroundColor Red
    exit 1
}

if ($NoLaunch) {
    Write-Host ""
    Write-Host "HOTOVO. Spusti VOLYA rucne v telefone." -ForegroundColor Green
    exit 0
}

Write-Host "4/4  Spustam hru v telefone..." -ForegroundColor Cyan
& $Adb logcat -c
& $Adb shell monkey -p $Package -c android.intent.category.LAUNCHER 1 | Out-Null

if ($NoLogs) {
    Write-Host ""
    Write-Host "HOTOVO." -ForegroundColor Green
    exit 0
}

Write-Host ""
Write-Host "=== ZIVE LOGY Z TELEFONU (Ctrl+C ukonci) ===" -ForegroundColor Green
Write-Host "Vsetko, co v hre vypise print(), sa objavi tu." -ForegroundColor DarkGray
Write-Host ""
& $Adb logcat -s godot:V GodotEngine:V AndroidRuntime:E
