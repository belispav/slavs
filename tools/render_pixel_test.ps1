# VOLYA - pixel-art pipeline test, one command.
#
#   1. renders the .blend with flat cel-banded materials and no anti-aliasing
#   2. runs the pixel-art pass (palette, despeckle, outline)
#   3. opens a magnified contact sheet so the result can be judged
#
# Usage, from the project root:
#
#   powershell -ExecutionPolicy Bypass -File tools\render_pixel_test.ps1
#
# Everything has a default. To try other settings:
#
#   ... -Bands 4 -Colours 24 -Height 128

param(
    [string] $Blend   = "tools\blender\hero_run.blend",
    [string] $Name    = "run",
    [int]    $Height  = 96,   # sprite height in pixels
    [int]    $Bands   = 3,    # hard steps of light on a surface
    [int]    $Colours = 16,   # palette size for the whole animation
    [int]    $Step    = 1,    # 1 = every frame, needed to measure pixel crawl
    [double] $Shadow  = 0.38  # how dark the darkest band is
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

Write-Host ""
Write-Host "=== VOLYA pixel-art test ===" -ForegroundColor Cyan

# ---------------------------------------------------------------- Blender ----

$blender = $null
$candidates = @(
    "C:\Program Files\Blender Foundation\Blender 4.5\blender.exe",
    "C:\Program Files\Blender Foundation\Blender 4.4\blender.exe",
    "C:\Program Files\Blender Foundation\Blender 4.3\blender.exe",
    "C:\Program Files\Blender Foundation\Blender 4.2\blender.exe"
)
foreach ($c in $candidates) { if (Test-Path $c) { $blender = $c; break } }
if (-not $blender) {
    $found = Get-ChildItem "C:\Program Files\Blender Foundation" -Recurse `
             -Filter blender.exe -ErrorAction SilentlyContinue |
             Select-Object -First 1
    if ($found) { $blender = $found.FullName }
}
if (-not $blender) {
    Write-Host "Blender sa nenasiel. Najdi blender.exe a spusti skript znova s:" -ForegroundColor Red
    Write-Host '  $env:VOLYA_BLENDER = "C:\cesta\k\blender.exe"' -ForegroundColor Red
    exit 1
}
if ($env:VOLYA_BLENDER) { $blender = $env:VOLYA_BLENDER }
Write-Host "Blender:  $blender"

if (-not (Test-Path $Blend)) {
    Write-Host "Nenasiel som $Blend" -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------------------ render ---

$rawDir = "volya\art\${Name}_raw"
$pxDir  = "volya\art\${Name}_px"
$sheet  = "volya\art\${Name}_sheet.png"
$gif    = "volya\art\${Name}_anim.gif"

if (Test-Path $rawDir) { Remove-Item $rawDir -Recurse -Force }

Write-Host ""
Write-Host "[1/3] Renderujem (toon, $Bands pasma, bez antialiasingu)..." -ForegroundColor Yellow

& $blender $Blend --background --python "tools\blender_render_sprites.py" -- `
    --out (Join-Path $root $rawDir) `
    --name $Name `
    --height $Height `
    --step $Step `
    --toon 1 `
    --pixel 1 `
    --bands $Bands `
    --shadow $Shadow

if ($LASTEXITCODE -ne 0) {
    Write-Host "Render zlyhal." -ForegroundColor Red
    exit 1
}

$rendered = @(Get-ChildItem $rawDir -Filter *.png -ErrorAction SilentlyContinue)
if ($rendered.Count -eq 0) {
    Write-Host "Render nevyprodukoval ziadne PNG. Pozri vypis vyssie." -ForegroundColor Red
    exit 1
}
Write-Host "      $($rendered.Count) snimok" -ForegroundColor Green

# ------------------------------------------------------------------ python ---

# Pillow is not part of Blender's bundled Python, and a normal Python install
# is not guaranteed either. Try a system Python first, then fall back to
# Blender's own and install Pillow into it once.

function Test-Python($exe) {
    try   { & $exe -c "import PIL, numpy" 2>$null; return ($LASTEXITCODE -eq 0) }
    catch { return $false }
}

$python = $null
foreach ($cand in @("python", "py", "python3")) {
    if (Get-Command $cand -ErrorAction SilentlyContinue) {
        if (Test-Python $cand) { $python = $cand; break }
    }
}

if (-not $python) {
    $blenderDir = Split-Path -Parent $blender
    $bpy = Get-ChildItem $blenderDir -Recurse -Filter python.exe -ErrorAction SilentlyContinue |
           Select-Object -First 1
    if ($bpy) {
        Write-Host "      systemovy Python nema Pillow, pouzivam ten z Blenderu" -ForegroundColor DarkGray
        & $bpy.FullName -m pip install --quiet pillow numpy 2>&1 | Out-Null
        if (Test-Python $bpy.FullName) { $python = $bpy.FullName }
    }
}

if (-not $python) {
    Write-Host ""
    Write-Host "Python s kniznicami Pillow a numpy sa nenasiel." -ForegroundColor Red
    Write-Host "Surove snimky su v $rawDir - posli mi ich a dorobim to ja." -ForegroundColor Red
    exit 1
}

# -------------------------------------------------------------- pixel pass ---

Write-Host ""
Write-Host "[2/3] Pixel-art prechod ($Colours farieb)..." -ForegroundColor Yellow

& $python "tools\pixelize_sprites.py" `
    --in $rawDir --out $pxDir --colours $Colours --sheet $sheet --gif $gif

if ($LASTEXITCODE -ne 0) {
    Write-Host "Pixel prechod zlyhal." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[3/3] Otvaram vysledok..." -ForegroundColor Yellow
# ChangeExtension($path, $null) leaves a trailing dot, which produced
# run_anim._10fps.gif and quietly failed to open the file Python had written.
$slowGif = $gif -replace '\.gif$', '_10fps.gif'
foreach ($f in @($sheet, $gif, $slowGif)) {
    if (Test-Path $f) { Start-Process (Resolve-Path $f) }
}

Write-Host ""
Write-Host "Hotovo." -ForegroundColor Green
Write-Host "  surove    $rawDir"
Write-Host "  sprajty   $pxDir"
Write-Host "  prehlad   $sheet"
Write-Host "  animacia  $gif"
Write-Host "  animacia  $slowGif  (herna rychlost 10 fps)"
Write-Host ""
