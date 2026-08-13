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
    # A .blend, or a model file straight from Mixamo (.fbx / .glb / .obj).
    [string] $Model   = "tools\blender\hero_run.blend",
    [string] $Blend   = "",   # old name for -Model, still accepted
    [string] $Name    = "run",
    [int]    $Height  = 96,   # sprite height in pixels
    [int]    $Bands   = 3,    # hard steps of light on a surface
    [int]    $Colours = 16,   # palette size for the whole animation
    [int]    $Step    = 1,    # 1 = every frame, needed to measure pixel crawl
    # Cut a window out of the animation. 0 = whole thing.
    [int]    $From    = 0,
    [int]    $To      = 0,
    [double] $Shadow  = 0.38, # how dark the darkest band is
    # Colour map to use instead of the model's own. Mixamo returns a rigged
    # mesh with no texture; this is how the generator's texture gets back on.
    [string] $Texture = "",
    # Flat colours by material name, for models that arrived without textures:
    #   -MatColours "Wood=3F2A17,Metal=858C99"
    [string] $MatColours = "",
    # Camera. Yaw turns towards the character's front (0 = strict profile),
    # elevation lifts it above eye level so the ground reads.
    # -Angle sets the camera azimuth outright, in degrees, and overrides the
    # automatic side-view guess. -1 = work it out from the model.
    [double] $Angle     = -1.0,
    [double] $Yaw       = 0.0,
    [double] $Elevation = 0.0,
    # Sweep: render several angles, one frame each, to pick the yaw by eye.
    #   -Angles 7 -AngleStep 15 -Yaw -45 -Step 999
    # gives seven frames from yaw -45 to +45; a00 is the lowest yaw.
    [int]    $Angles    = 1,
    [double] $AngleStep = 0.0,
    # Weapon built in Blender and hung on the hand bone: arquebus, club,
    # spear, sword, bow. Empty = empty hands. The shifts are in metres and are
    # meant to be corrected from the render, never guessed.
    [string] $Weapon  = "",
    [string] $Hand    = "right",
    [double] $WScale  = 1.0,
    [double] $WShiftX = 0.0,
    [double] $WShiftY = 0.0,
    [double] $WShiftZ = 0.0,
    [double] $WTurn   = 0.0,
    [int]    $WAim    = 1,
    [int]    $WDebug  = 0,
    [int]    $WOnly   = 0,
    # Turn the weapon about the vertical axis, and sweep that turn.
    [double] $WSpin      = 0.0,
    [int]    $WSweep     = 0,
    [double] $WSweepStep = 0.0,
    # A downloaded weapon mesh, and a placement fitted by hand in Blender.
    [string] $WModel = "",
    [string] $WFit   = "",
    # 0..1 along the weapon; past this point the faces become iron instead of
    # wood. For a model whose wooden fore-end hides the barrel.
    [double] $IronFrom = 0.0,
    # Skip the 1 px outline in the pixel pass. Needed at S = 2: the sprite is
    # drawn at scale 0.5, so a 1 px outline is half a world unit and is thrown
    # away by the minification anyway - it only adds crawl.
    # See DIZAJN_pozadie_a_rozlisenie.md KROK 4 step 5.
    [switch] $NoOutline
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

if ($Blend -ne "") { $Model = $Blend }
if (-not (Test-Path $Model)) {
    Write-Host "Nenasiel som $Model" -ForegroundColor Red
    exit 1
}
$isBlend = $Model.ToLower().EndsWith(".blend")

# ------------------------------------------------------------------ render ---

# Only the finished sprites belong inside the Godot project. Raw renders and
# preview animations live outside it, or Godot imports them and they end up in
# the APK - several megabytes of intermediate files shipped to players.
$rawDir = "render\${Name}_raw"
$pxDir  = "volya\art\${Name}_px"
$sheet  = "render\${Name}_sheet.png"
$gif    = "render\${Name}_anim.gif"

New-Item -ItemType Directory -Force -Path "render" | Out-Null
if (Test-Path $rawDir) { Remove-Item $rawDir -Recurse -Force }
# The sprite folder has to go too. A shorter run leaves the tail of the longer
# one behind, and stale frames from a previous experiment sitting next to fresh
# ones is worse than no frames at all - the game plays them and the comparison
# lies about what changed.
if (Test-Path $pxDir) { Remove-Item $pxDir -Recurse -Force }

# Earlier versions of this script wrote the intermediates into volya\art.
foreach ($stale in @("volya\art\${Name}_raw", "volya\art\${Name}_sheet.png",
                     "volya\art\${Name}_anim.gif",
                     "volya\art\${Name}_anim_10fps.gif",
                     "volya\art\${Name}_anim_15fps.gif",
                     "volya\art\${Name}_anim_porovnanie.gif")) {
    if (Test-Path $stale) {
        Remove-Item $stale -Recurse -Force
        Write-Host "      upratane: $stale" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "[1/3] Renderujem (toon, $Bands pasma, bez antialiasingu)..." -ForegroundColor Yellow

# A .blend is opened by Blender itself; anything else is imported by the script
# into an empty scene, so a rigged FBX from Mixamo needs no manual step at all.
$blenderArgs = @()
if ($isBlend) { $blenderArgs += $Model }
$blenderArgs += @("--background", "--python", "tools\blender_render_sprites.py", "--")
if (-not $isBlend) { $blenderArgs += @("--import", (Join-Path $root $Model)) }
$blenderArgs += @(
    "--out",    (Join-Path $root $rawDir),
    "--name",   $Name,
    "--height", $Height,
    "--step",   $Step,
    "--frame_start", $From,
    "--frame_end",   $To,
    "--toon",   1,
    "--pixel",  1,
    "--angles",     $Angles,
    "--angle_step", $AngleStep.ToString([System.Globalization.CultureInfo]::InvariantCulture),
    "--start_angle", $Angle.ToString([System.Globalization.CultureInfo]::InvariantCulture),
    "--yaw",       $Yaw.ToString([System.Globalization.CultureInfo]::InvariantCulture),
    "--elevation", $Elevation.ToString([System.Globalization.CultureInfo]::InvariantCulture),
    "--bands",  $Bands,
    "--shadow", $Shadow.ToString([System.Globalization.CultureInfo]::InvariantCulture)
)
if ($Texture -ne "") {
    if (-not (Test-Path $Texture)) {
        Write-Host "Nenasiel som texturu $Texture" -ForegroundColor Red
        exit 1
    }
    $blenderArgs += @("--texture", (Join-Path $root $Texture))
}
# Never pass an empty string as an argument value. PowerShell drops it from the
# array, so "--material_colours" then swallows whatever switch came next and
# the colours were silently ignored while the log blamed the model.
if ($MatColours -ne "") { $blenderArgs += @("--material_colours", $MatColours) }
# A downloaded model IS a weapon, so -WModel on its own has to be enough.
# Requiring -Weapon as well meant a fitted, downloaded arquebus rendered as a
# man with empty hands, and the only clue was "toon shading na 1 materialoch".
if ($Weapon -ne "" -or $WModel -ne "") {
    if ($Weapon -eq "") { $Weapon = "model" }
    # Numbers go to Python, so they must use a dot. On a Slovak Windows the
    # default double-to-string gives "0,05" and float() on the other side
    # throws - a failure that reads like a Blender problem and is not one.
    $inv = [System.Globalization.CultureInfo]::InvariantCulture
    $blenderArgs += @(
        "--weapon",         $Weapon,
        "--weapon_hand",    $Hand,
        "--weapon_scale",   $WScale.ToString($inv),
        "--weapon_shift_x", $WShiftX.ToString($inv),
        "--weapon_shift_y", $WShiftY.ToString($inv),
        "--weapon_shift_z", $WShiftZ.ToString($inv),
        "--weapon_turn",    $WTurn.ToString($inv),
        "--weapon_aim",     $WAim,
        "--weapon_debug",   $WDebug,
        "--weapon_only",    $WOnly,
        "--weapon_spin",       $WSpin.ToString($inv),
        "--weapon_sweep",      $WSweep,
        "--weapon_sweep_step", $WSweepStep.ToString($inv)
    )
    if ($WModel -ne "") { $blenderArgs += @("--weapon_model", (Join-Path $root $WModel)) }
    if ($WFit   -ne "") { $blenderArgs += @("--weapon_fit",   (Join-Path $root $WFit)) }
    $blenderArgs += @("--weapon_iron_from", $IronFrom.ToString($inv))
    Write-Host "Zbran:    $Weapon ($Hand ruka)"
}

& $blender @blenderArgs

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

$pixelArgs = @("--in", $rawDir, "--out", $pxDir, "--colours", $Colours,
               "--sheet", $sheet, "--gif", $gif)
if ($NoOutline) { $pixelArgs += "--no-outline" }

& $python "tools\pixelize_sprites.py" @pixelArgs

if ($LASTEXITCODE -ne 0) {
    Write-Host "Pixel prechod zlyhal." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[3/3] Otvaram vysledok..." -ForegroundColor Yellow

# Only two windows are opened. Opening one per frame rate meant Windows merged
# them and only the first was ever actually seen.
$compare = $gif -replace '\.gif$', '_porovnanie.gif'
foreach ($f in @($sheet, $compare)) {
    if (Test-Path $f) { Start-Process (Resolve-Path $f) }
}

Write-Host ""
Write-Host "Hotovo." -ForegroundColor Green
Write-Host "  surove      $rawDir"
Write-Host "  sprajty     $pxDir"
Write-Host "  prehlad     $sheet"
Write-Host "  porovnanie  $compare   <- 30 / 15 / 10 fps vedla seba"
foreach ($rate in @(30, 15, 10)) {
    $f = if ($rate -eq 30) { $gif } else { $gif -replace '\.gif$', "_${rate}fps.gif" }
    if (Test-Path $f) { Write-Host "  $rate fps      $f" }
}
Write-Host ""
