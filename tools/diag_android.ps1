# VOLYA - diagnostika one-click deploy.
# Spusti a posli Claudovi cely vypis.
#
#   powershell -ExecutionPolicy Bypass -File "D:\2026\Slavs figh back\tools\diag_android.ps1"
#
# POZOR: tento subor musi zostat v ciste ASCII. Windows PowerShell 5.1 cita
# .ps1 v ANSI kodovani a UTF-8 znaky (pomlcka, diakritika) rozbiju parsing.

$ErrorActionPreference = "Continue"

function Head($t) {
    Write-Host ""
    Write-Host "=== $t ===" -ForegroundColor Cyan
}

Head "1. Godot editor settings - Android"
$settings = Get-ChildItem (Join-Path $env:APPDATA "Godot\editor_settings-*.tres") -ErrorAction SilentlyContinue
if (-not $settings) {
    Write-Host "NENAJDENE: $env:APPDATA\Godot\editor_settings-*.tres" -ForegroundColor Red
    Write-Host "Obsah priecinka Godot:"
    Get-ChildItem (Join-Path $env:APPDATA "Godot") -ErrorAction SilentlyContinue | Select-Object Name
} else {
    foreach ($f in $settings) {
        Write-Host ("--- " + $f.FullName)
        $hits = Select-String -Path $f.FullName -Pattern "android","java" -SimpleMatch
        if ($hits) { $hits | ForEach-Object { Write-Host $_.Line } }
        else { Write-Host "ZIADNY riadok s 'android' ani 'java' - cesty nie su ulozene." -ForegroundColor Red }
    }
}

Head "2. Bezi este nejaky Godot proces?"
$procs = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -like "*odot*" }
if ($procs) { $procs | Select-Object Id, ProcessName, MainWindowTitle | Format-Table -AutoSize }
else { Write-Host "Ziadny Godot proces nebezi." }

Head "3. Export sablony"
$tplRoot = Join-Path $env:APPDATA "Godot\export_templates"
$tpl = Get-ChildItem $tplRoot -Directory -ErrorAction SilentlyContinue
if (-not $tpl) {
    Write-Host "ZIADNE SABLONY v $tplRoot" -ForegroundColor Red
} else {
    foreach ($d in $tpl) {
        Write-Host ("--- " + $d.Name)
        $files = Get-ChildItem $d.FullName -Filter "android*" -ErrorAction SilentlyContinue
        if ($files) {
            $files | Select-Object Name, @{n="MB";e={[math]::Round($_.Length/1MB,1)}} | Format-Table -AutoSize
        } else {
            Write-Host "  ZIADNE android* subory v tejto verzii sablon!" -ForegroundColor Red
        }
    }
}

Head "4. Android SDK a adb"
$sdk = Join-Path $env:LOCALAPPDATA "Android\Sdk"
Write-Host "Ocakavana SDK cesta: $sdk"
Write-Host ("Existuje SDK:         " + (Test-Path $sdk))
$adb = Join-Path $sdk "platform-tools\adb.exe"
Write-Host ("Existuje adb.exe:     " + (Test-Path $adb))
Write-Host "  ($adb)"
if (Test-Path $adb) {
    Write-Host "--- adb version"
    & $adb version
    Write-Host "--- adb devices"
    & $adb devices -l
} else {
    Write-Host "Hladam adb.exe inde na disku C (moze trvat chvilu)..."
    Get-ChildItem "C:\" -Filter "adb.exe" -Recurse -ErrorAction SilentlyContinue -Force |
        Select-Object -First 5 -ExpandProperty FullName
}

Head "5. JDK"
$jdkRoots = @(
    "C:\Program Files\Eclipse Adoptium",
    "C:\Program Files\Microsoft",
    "C:\Program Files\Java",
    "C:\Program Files\Android\Android Studio\jbr"
)
foreach ($r in $jdkRoots) {
    if (Test-Path $r) { Get-ChildItem $r -Directory -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName }
}
Write-Host "--- java -version"
java -version 2>&1

Head "HOTOVO - skopiruj cely vypis"
