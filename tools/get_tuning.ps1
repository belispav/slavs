# VOLYA - vytiahne z telefonu posledny vypis hodnot ovladania.
#
# V hre stlac tlacidlo VYPIS DO LOGU, potom spusti tento skript.
# Funguje aj ked ti uz nebezi logcat.
#
#   powershell -ExecutionPolicy Bypass -File "D:\2026\Slavs figh back\tools\get_tuning.ps1"
#
# POZOR: ciste ASCII, Windows PowerShell cita .ps1 v ANSI kodovani.

$Adb     = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"
$Package = "sk.pavel.volya"
$OutFile = "D:\2026\Slavs figh back\volya\build\tuning.txt"

$ErrorActionPreference = "Continue"

if (-not (Test-Path $Adb)) {
    Write-Host "CHYBA: neexistuje $Adb" -ForegroundColor Red
    exit 1
}

$text = & $Adb exec-out run-as $Package cat files/tuning.txt 2>&1

if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($text)) {
    Write-Host "Nepodarilo sa nacitat hodnoty." -ForegroundColor Red
    Write-Host ""
    Write-Host "Skontroluj:" -ForegroundColor Yellow
    Write-Host "  1. Bezi hra v telefone a stlacil si VYPIS DO LOGU?"
    Write-Host "  2. Je to debug build z deploy_android.ps1? (release sa citat neda)"
    Write-Host "  3. adb devices ukazuje 'device'?"
    Write-Host ""
    Write-Host "Vystup prikazu:" -ForegroundColor DarkGray
    $text
    exit 1
}

New-Item -ItemType Directory -Force -Path (Split-Path $OutFile) | Out-Null
[System.IO.File]::WriteAllText($OutFile, ($text -join "`n"), (New-Object System.Text.UTF8Encoding($false)))

Write-Host ""
$text
Write-Host ""
Write-Host "Ulozene do: $OutFile" -ForegroundColor Green
