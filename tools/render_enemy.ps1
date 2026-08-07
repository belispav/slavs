# VOLYA - render every animation of one enemy, with that enemy's saved settings.
#
#   powershell -ExecutionPolicy Bypass -File tools\render_enemy.ps1 -Name gunman `
#       -Anims "idle=Enemy_gunman_01 Rifle Idle:19-157, walk=Enemy_gunman_01 Rifle Walk, fire=Enemy_gunman_01 Firing Rifle"
#
# Each entry is  <sprite name>=<fbx name without .fbx>  and optionally  :from-to
# to cut a window out of an animation that turns the character away.
#
# The weapon model, its placement, its colours, how much of it is iron and the
# camera angle all come from art\fits\<Name>.json - decided once, applied to
# every animation. Nothing about the enemy is typed twice, so nothing about the
# enemy can drift between its animations.

param(
    [Parameter(Mandatory = $true)][string] $Name,
    [Parameter(Mandatory = $true)][string] $Anims,
    [string] $CharDir = "ref\characters",
    [int]    $Height  = 128,
    [int]    $Step    = 1
)

$ErrorActionPreference = "Continue"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$fitPath = "art\fits\$Name.json"
if (-not (Test-Path $fitPath)) {
    Write-Host "Nenasiel som $fitPath - najprv fitni zbran:" -ForegroundColor Red
    Write-Host "  tools\fit_weapon.ps1 -Model ... -Name $Name" -ForegroundColor Red
    exit 1
}
# Decisions come from <Name>.settings.json, which only ever gets read. The
# placement files are written every time the weapon is nudged, and when the two
# shared a file a re-fit quietly deleted the weapon model - the next render came
# out with an unarmed man and nothing said why.
$setPath = "art\fits\$Name.settings.json"
if (-not (Test-Path $setPath)) {
    Write-Host "Nenasiel som $setPath" -ForegroundColor Red
    Write-Host "Ma obsahovat weapon_model, colours, iron_from, camera_angle." -ForegroundColor Red
    exit 1
}
$set = Get-Content $setPath -Raw | ConvertFrom-Json

$angle     = if ($set.camera_angle)     { [double]$set.camera_angle }     else { 45.0 }
$elevation = if ($set.camera_elevation) { [double]$set.camera_elevation } else { 12.0 }
$wmodel    = if ($set.weapon_model)     { [string]$set.weapon_model }     else { "" }

Write-Host ""
Write-Host "=== VOLYA - $Name ===" -ForegroundColor Cyan
Write-Host "kamera $angle stupnov, zdvih $elevation"
if ($wmodel)     { Write-Host "zbran  $wmodel" }
if ($set.colours) { Write-Host "farby  $($set.colours)" }

$entries = $Anims.Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
$made = 0

foreach ($entry in $entries) {
    if ($entry -notmatch "^([A-Za-z0-9_]+)\s*=\s*(.+?)(?::(\d+)-(\d+))?$") {
        Write-Host "Nerozumiem '$entry' - caka sa  meno=subor  alebo  meno=subor:od-do" -ForegroundColor Red
        continue
    }
    $tag  = $matches[1]
    $file = $matches[2].Trim()
    $from = if ($matches[3]) { [int]$matches[3] } else { 0 }
    $to   = if ($matches[4]) { [int]$matches[4] } else { 0 }

    $model = Join-Path $CharDir "$file.fbx"
    if (-not (Test-Path $model)) {
        Write-Host "Nenasiel som $model" -ForegroundColor Red
        continue
    }

    $spriteName = "${Name}_$tag"
    Write-Host ""
    $window = if ($from -gt 0) { " (snimky $from-$to)" } else { "" }
    Write-Host "[$tag] $file$window" -ForegroundColor Yellow

    # A per-animation placement wins if one exists. Most characters need only
    # the one; this model needed the gun held differently while walking and
    # while firing, and forcing a single placement would have made one of them
    # wrong forever.
    $useFit = $fitPath
    $perAnim = "art\fits\${Name}_$tag.json"
    if (Test-Path $perAnim) {
        $useFit = $perAnim
        Write-Host "  vlastne umiestnenie: $perAnim" -ForegroundColor DarkGray
    }

    $call = @("-ExecutionPolicy", "Bypass", "-File", "tools\render_pixel_test.ps1",
              "-Model", $model, "-Name", $spriteName, "-Height", $Height,
              "-Step", $Step, "-From", $from, "-To", $to,
              "-Angle", $angle, "-Elevation", $elevation,
              "-WFit", $useFit)
    if ($wmodel) { $call += @("-WModel", $wmodel) }

    & powershell @call *> "render\$spriteName`_log.txt"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  zlyhalo -> render\$spriteName`_log.txt" -ForegroundColor Red
    } else {
        $count = @(Get-ChildItem "volya\art\${spriteName}_px" -Filter *.png -ErrorAction SilentlyContinue).Count
        Write-Host "  $count sprajtov -> volya\art\${spriteName}_px" -ForegroundColor Green
        $made++
    }
}

Write-Host ""
Write-Host "Hotovo: $made z $($entries.Count) animacii." -ForegroundColor Green
