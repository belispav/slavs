# VOLYA - deploy na Android z prikazoveho riadku.
#
# Oznaci build casovou znackou, vyexportuje, nainstaluje, spusti a streamuje
# logy z telefonu. Trva ~40 sekund.
#
#   powershell -ExecutionPolicy Bypass -File "D:\2026\Slavs figh back\tools\deploy_android.ps1"
#
# Prepinace:
#   -Clean       najprv odinstaluje appku z telefonu (uplne cisty stav)
#   -NoLaunch    nainstaluje, ale nespusti hru
#   -NoLogs      nebude streamovat logcat
#
# POZOR: tento subor musi zostat v ciste ASCII. Windows PowerShell 5.1 cita
# .ps1 v ANSI kodovani a UTF-8 znaky (pomlcka, diakritika) rozbiju parsing.

param(
    [switch]$Clean,
    [switch]$NoLaunch,
    [switch]$NoLogs
)

# --- cesty (uprav podla svojej instalacie) ---
$Godot   = "D:\Tools\Godot\Godot_v4.7.1-stable_win64.exe"
$Adb     = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"
$Project = "D:\2026\Slavs figh back\volya"
$Repo    = "D:\2026\Slavs figh back"
$Preset  = "Android"
$Package = "sk.pavel.volya"

# Continue, nie Stop: nativne programy (adb, godot, java) pisu bezne veci na
# stderr a pri "Stop" by to skript zhodilo. Kontrolujeme exit kody explicitne.
$ErrorActionPreference = "Continue"

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

# ---------------------------------------------------------------- 1. znacka --
Write-Host "1/5  Znacka buildu..." -ForegroundColor Cyan

$stampTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$gitHash = ""
try {
    Push-Location $Repo
    $gitHash = (git rev-parse --short HEAD 2>$null)
    Pop-Location
} catch { }
if ([string]::IsNullOrWhiteSpace($gitHash)) { $Stamp = $stampTime }
else { $Stamp = "$stampTime  $gitHash" }

$stampFile = Join-Path $Project "scripts\build_stamp.gd"
$stampBody = @"
extends RefCounted

## Tento subor prepisuje tools/deploy_android.ps1 pri kazdom builde.
## Zobrazuje sa vlavo hore v hre ako prvy riadok.
##
## ZAMERNE tu NIE JE class_name: globalne nazvy tried su v cache, ktoru
## headless export neobnovuje, a export by na tom padol.
const STAMP := "$Stamp"
"@
[System.IO.File]::WriteAllText($stampFile, $stampBody, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "      $Stamp" -ForegroundColor Yellow

# --------------------------------------------------------------- 2. zariadenie
Write-Host "2/5  Kontrola zariadenia..." -ForegroundColor Cyan
$adbList = & $Adb devices
$devices = $adbList | Where-Object { $_ -match "^\S+\s+device\s*$" }
if (-not $devices) {
    $unauth = $adbList | Where-Object { $_ -match "unauthorized" }
    if ($unauth) {
        Write-Host "TELEFON JE 'unauthorized' - caka na tvoje potvrdenie." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  1. ODOMKNI telefon a nechaj ho odomknuty" -ForegroundColor Yellow
        Write-Host "  2. Odpoj a znova zapoj kabel" -ForegroundColor Yellow
        Write-Host "  3. V telefone potvrd 'Povolit ladenie cez USB'" -ForegroundColor Yellow
        Write-Host "     a zaskrtni 'Vzdy povolit z tohto pocitaca'" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Stalo sa to preto, lebo sa restartoval adb demon." -ForegroundColor DarkGray
    } else {
        Write-Host "CHYBA: ziadne zariadenie. Zapoj telefon." -ForegroundColor Red
    }
    $adbList
    exit 1
}
Write-Host ("      OK: " + ($devices[0] -replace "\s+", "  "))

# ------------------------------------------------------------------ 3. export
Write-Host "3/5  Export APK..." -ForegroundColor Cyan
$sw = [System.Diagnostics.Stopwatch]::StartNew()
if (Test-Path $Apk) { Remove-Item $Apk -Force }

# Obnov import cache. Bez tohto sa novy subor v projekte nemusi dostat
# do exportu a export skonci parse chybou.
& $Godot --headless --path $Project --import 2>&1 | Out-Null

$exportLog = Join-Path $BuildDir "export.log"
& $Godot --headless --path $Project --export-debug $Preset $Apk 2>&1 |
    Tee-Object -FilePath $exportLog
$exportCode = $LASTEXITCODE

if ($exportCode -ne 0 -or -not (Test-Path $Apk)) {
    Write-Host ""
    Write-Host "CHYBA: export zlyhal (exit $exportCode)." -ForegroundColor Red
    Write-Host "Posledne riadky z exportu:" -ForegroundColor Yellow
    if (Test-Path $exportLog) { Get-Content $exportLog -Tail 30 }
    Write-Host ""
    Write-Host "Cely vypis: $exportLog" -ForegroundColor DarkGray
    exit 1
}
$size = [math]::Round((Get-Item $Apk).Length / 1MB, 1)
Write-Host ("      OK: $size MB za " + [math]::Round($sw.Elapsed.TotalSeconds, 1) + " s")

# ------------------------------------------------------------- 4. instalacia
Write-Host "4/5  Instalacia..." -ForegroundColor Cyan
& $Adb shell am force-stop $Package 2>$null | Out-Null
if ($Clean) {
    Write-Host "      Odinstalovavam staru verziu (-Clean)..."
    & $Adb uninstall $Package 2>$null | Out-Null
}
& $Adb install -r $Apk
if ($LASTEXITCODE -ne 0) {
    Write-Host "CHYBA: instalacia zlyhala. Skus to iste s prepinacom -Clean." -ForegroundColor Red
    exit 1
}

if ($NoLaunch) {
    Write-Host ""
    Write-Host "HOTOVO. Spusti VOLYA rucne v telefone." -ForegroundColor Green
    Write-Host "V hre vlavo hore musi byt: $Stamp" -ForegroundColor Yellow
    exit 0
}

# --------------------------------------------------------------- 5. spustenie
Write-Host "5/5  Spustam hru..." -ForegroundColor Cyan
& $Adb logcat -c
& $Adb shell monkey -p $Package -c android.intent.category.LAUNCHER 1 | Out-Null

Write-Host ""
Write-Host "SKONTROLUJ: vlavo hore v hre musi byt presne toto:" -ForegroundColor Green
Write-Host "   BUILD: $Stamp" -ForegroundColor Yellow
Write-Host "Ak je tam ine cislo, telefon bezi na starom builde." -ForegroundColor DarkGray

if ($NoLogs) { exit 0 }

Write-Host ""
Write-Host "=== ZIVE LOGY (Ctrl+C ukonci) ===" -ForegroundColor Green
Write-Host ""
& $Adb logcat -s godot:V GodotEngine:V AndroidRuntime:E
