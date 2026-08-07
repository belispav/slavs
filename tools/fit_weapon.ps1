# VOLYA - place a weapon in a character's hand by mouse, in two steps and one
# command.
#
#   powershell -ExecutionPolicy Bypass -File tools\fit_weapon.ps1 `
#       -Model "ref\characters\Enemy_gunman_01 Rifle Idle.fbx" `
#       -Weapon arquebus -Name gunman
#
# Step 1 builds the scene headless (import, weapon on the hand bone, game
# camera, right frame) and saves a .blend. Step 2 just opens it. The split is
# not tidiness: importing an FBX from a startup script inside a Blender WINDOW
# fails, every time, because the importer needs a window context it does not
# have yet. Headless it is flawless.
#
# Move the weapon with G, turn it with R, resize with S, then Ctrl+S.
# Do not unparent it. Afterwards:
#
#   powershell -ExecutionPolicy Bypass -File tools\save_fit.ps1 -Name gunman

param(
    [Parameter(Mandatory = $true)][string] $Model,
    [string] $Weapon    = "arquebus",
    [string] $WModel    = "",     # a downloaded weapon mesh instead of ours
    [string] $Hand      = "right",
    [double] $Angle     = 45.0,   # the camera angle chosen for the game
    [double] $Elevation = 12.0,
    [int]    $Frame     = 0,      # 0 = middle of the animation
    [string] $Name      = "",     # what to call the .blend; empty = from Model
    # Start from a placement already fitted. Use this to CHECK the other
    # animations of a character: the weapon appears exactly where it was put,
    # and if it looks wrong in a walk or a shot, the correction applies to all
    # of them - the placement is against the hand bone, not against a clip.
    [string] $Fit       = ""
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root
$inv = [System.Globalization.CultureInfo]::InvariantCulture

$blender = $env:VOLYA_BLENDER
if (-not $blender) {
    $found = Get-ChildItem "C:\Program Files\Blender Foundation" -Recurse `
             -Filter blender.exe -ErrorAction SilentlyContinue |
             Sort-Object FullName -Descending | Select-Object -First 1
    if ($found) { $blender = $found.FullName }
}
if (-not $blender) {
    Write-Host "Blender sa nenasiel. Spusti znova s:" -ForegroundColor Red
    Write-Host '  $env:VOLYA_BLENDER = "C:\cesta\k\blender.exe"' -ForegroundColor Red
    exit 1
}
if (-not (Test-Path $Model)) {
    Write-Host "Nenasiel som $Model" -ForegroundColor Red
    exit 1
}

if ($Name -eq "") { $Name = [System.IO.Path]::GetFileNameWithoutExtension($Model) }
$blend = Join-Path $root "tools\blender\$Name`_fit.blend"

Write-Host ""
Write-Host "=== VOLYA - fitovanie zbrane ===" -ForegroundColor Cyan
Write-Host "Blender:  $blender"
Write-Host "Postava:  $Model"
Write-Host "Zbran:    $Weapon"
Write-Host ""
Write-Host "[1/2] Stavam scenu v pozadi..." -ForegroundColor Yellow

$args1 = @("--background", "--python", "tools\blender_fit_weapon.py", "--",
           "--import",    (Join-Path $root $Model),
           "--weapon",    $Weapon,
           "--hand",      $Hand,
           "--angle",     $Angle.ToString($inv),
           "--elevation", $Elevation.ToString($inv),
           "--frame",     $Frame,
           "--out",       $blend)
if ($WModel -ne "") { $args1 += @("--model", (Join-Path $root $WModel)) }
if ($Fit    -ne "") { $args1 += @("--fit",   (Join-Path $root $Fit)) }

& $blender @args1
if ($LASTEXITCODE -ne 0 -or -not (Test-Path $blend)) {
    Write-Host "Priprava zlyhala, pozri vypis vyssie." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[2/2] Otvaram Blender." -ForegroundColor Yellow
Write-Host ""
Write-Host "  G = posun     R = otocenie     S = velkost" -ForegroundColor Green
Write-Host "  G X / G Z ... zamkne os" -ForegroundColor Green
Write-Host "  Ctrl+S        ulozi (nechaj rovnaky subor)" -ForegroundColor Green
Write-Host ""
Write-Host "  Zbran NEODPAJAJ od kosti, len ju hyb." -ForegroundColor DarkYellow
Write-Host ""
Write-Host "  Ked skoncis:" -ForegroundColor Green
Write-Host "  powershell -ExecutionPolicy Bypass -File tools\save_fit.ps1 -Name $Name" -ForegroundColor Green
Write-Host ""

& $blender $blend
