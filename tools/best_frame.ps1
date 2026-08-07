# VOLYA - work out which frame of an animation shows the weapon best, and
# remember it.
#
#   powershell -ExecutionPolicy Bypass -File tools\best_frame.ps1 `
#       -Model "ref\characters\Enemy_gunman_01 Rifle Idle.fbx" `
#       -WModel "ref\objects\arkebuza_cgtrader.blend" -WFit art\fits\gunman.json
#
# Renders the weapon ALONE across the animation, counts how many pixels of it
# are visible in each frame, and writes the winner into the fit file. Every
# later preview then uses that frame automatically.
#
# This exists because the frame was picked by guess three times running, and
# three times the body hid the weapon - a frame with 64 visible pixels was used
# to judge a weapon that reaches 137 in a better one.

param(
    [Parameter(Mandatory = $true)][string] $Model,
    [Parameter(Mandatory = $true)][string] $WFit,
    [string] $Name      = "",
    [string] $Weapon    = "",
    [string] $WModel    = "",
    [int]    $Height    = 128,
    [int]    $Step      = 2,
    [double] $Angle     = 45.0,
    [double] $Elevation = 12.0
)

$ErrorActionPreference = "Continue"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

if ($Name -eq "") {
    $Name = [System.IO.Path]::GetFileNameWithoutExtension($WFit) + "_pick"
}

Write-Host ""
Write-Host "=== VOLYA - hladam snimku, kde je zbran najlepsie vidiet ===" -ForegroundColor Cyan

$call = @("-ExecutionPolicy", "Bypass", "-File", "tools\render_pixel_test.ps1",
          "-Model", $Model, "-Name", $Name, "-Height", $Height, "-Step", $Step,
          "-Angle", $Angle, "-Elevation", $Elevation,
          "-WFit", $WFit, "-WOnly", 1, "-WDebug", 1)
if ($Weapon -ne "") { $call += @("-Weapon", $Weapon) }
if ($WModel -ne "") { $call += @("-WModel", $WModel) }

& powershell @call *> "render\$Name`_log.txt"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Render zlyhal, pozri render\$Name`_log.txt" -ForegroundColor Red
    exit 1
}

$python = $null
foreach ($cand in @("python", "py", "python3")) {
    if (Get-Command $cand -ErrorAction SilentlyContinue) { $python = $cand; break }
}
if (-not $python) { Write-Host "Python sa nenasiel." -ForegroundColor Red; exit 1 }

& $python "tools\count_weapon.py" --dir "render\${Name}_raw" --fit $WFit
