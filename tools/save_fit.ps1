# VOLYA - read a hand-placed weapon back out of the .blend into art\fits\<name>.json
#
#   powershell -ExecutionPolicy Bypass -File tools\save_fit.ps1 -Name gunman
#
# The placement is stored against the HAND BONE, so it holds for every
# animation of that character. Fit once, render everything.

param(
    [Parameter(Mandatory = $true)][string] $Name,
    [string] $Blend = ""      # empty = tools\blender\<Name>_fit.blend
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$blender = $env:VOLYA_BLENDER
if (-not $blender) {
    $found = Get-ChildItem "C:\Program Files\Blender Foundation" -Recurse `
             -Filter blender.exe -ErrorAction SilentlyContinue |
             Sort-Object FullName -Descending | Select-Object -First 1
    if ($found) { $blender = $found.FullName }
}
if (-not $blender) { Write-Host "Blender sa nenasiel." -ForegroundColor Red; exit 1 }

if ($Blend -eq "") { $Blend = "tools\blender\$Name`_fit.blend" }
if (-not (Test-Path $Blend)) {
    Write-Host "Nenasiel som $Blend - ulozil si ho v Blenderi?" -ForegroundColor Red
    exit 1
}

& $blender --background --python "tools\save_weapon_fit.py" -- `
    --blend (Join-Path $root $Blend) --name $Name

if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host ""
Write-Host "Odteraz pridaj do kazdeho renderu tejto postavy:" -ForegroundColor Green
Write-Host "  -WFit art\fits\$Name.json" -ForegroundColor Green
