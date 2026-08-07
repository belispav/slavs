# VOLYA - render the same frame in several colour schemes, to pick one by eye.
#
#   powershell -ExecutionPolicy Bypass -File tools\colour_test.ps1 `
#       -Model "ref\characters\Enemy_gunman_01 Rifle Idle.fbx" `
#       -WModel "ref\objects\arkebuza_cgtrader.blend" -WFit art\fits\gunman.json `
#       -Frame 65 -Angle 45 -Elevation 12 `
#       -Variants "wood=2A1B10,steel=555C66; wood=3F2A17,steel=6E7580; wood=53381F,steel=8A929E"
#
# Variants are separated by ";", each one is a normal -MatColours string.
# Renders one frame per variant into render\<Name>_vNN_px, so they can be laid
# out side by side and compared. Choosing from pictures takes one round;
# describing a colour in words takes as many rounds as there are adjectives.

param(
    [Parameter(Mandatory = $true)][string] $Model,
    [Parameter(Mandatory = $true)][string] $Variants,
    [string] $Name      = "farby",
    [int]    $Height    = 128,
    # 0 = take preview_frame from the fit file, which best_frame.ps1 measured.
    # Choosing the frame by hand is how three colour tests in a row came out
    # showing a weapon hidden behind a body.
    [int]    $Frame     = 0,
    [double] $Angle     = 45.0,
    [double] $Elevation = 12.0,
    [string] $Weapon    = "",
    [string] $WModel    = "",
    [string] $WFit      = ""
)

# Deliberately NOT "Stop". Blender writes warnings to stderr, PowerShell reads
# stderr from a native command as a terminating error, and the whole loop dies
# after the first variant. Success is judged by the exit code instead.
$ErrorActionPreference = "Continue"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$setGuess = ""
if ($WFit -ne "") {
    $stem = [System.IO.Path]::GetFileNameWithoutExtension($WFit).Split("_")[0]
    $setGuess = Join-Path ([System.IO.Path]::GetDirectoryName($WFit)) "$stem.settings.json"
}
if ($Frame -le 0 -and $setGuess -ne "" -and (Test-Path $setGuess)) {
    $fit = Get-Content $setGuess -Raw | ConvertFrom-Json
    if ($fit.preview_frame) {
        $Frame = [int]$fit.preview_frame
        Write-Host "Snimka $Frame (zmerana, zbran je na nej najviac vidiet)" -ForegroundColor Green
    }
}
if ($Frame -le 0) {
    Write-Host "Neviem, ktoru snimku pouzit. Spusti najprv:" -ForegroundColor Red
    Write-Host "  tools\best_frame.ps1 -Model ... -WFit $WFit" -ForegroundColor Red
    exit 1
}

$sets = $Variants.Split(";") | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
# The labels go to a file so the grid can print what each variant actually was.
$sets | Set-Content -Encoding UTF8 "render\$Name`_variants.txt"
Write-Host ""
Write-Host "=== VOLYA - skuska farieb: $($sets.Count) variantov ===" -ForegroundColor Cyan

for ($i = 0; $i -lt $sets.Count; $i++) {
    $tag = "{0}_v{1:d2}" -f $Name, $i
    Write-Host ""
    Write-Host "[$($i+1)/$($sets.Count)] $($sets[$i])" -ForegroundColor Yellow

    # A variant may carry "iron=0.35" alongside the colours. It is not a
    # colour, it is how far along the weapon the wood gives way to iron, so it
    # is pulled out and passed separately. Sweeping shape and colour together
    # is the point: on this model they cannot be judged apart.
    $iron = 0.0
    $pairs = @()
    foreach ($bit in $sets[$i].Split(",")) {
        $bit = $bit.Trim()
        if ($bit -match "^iron\s*=\s*([0-9.]+)$") {
            $iron = [double]::Parse($matches[1], [System.Globalization.CultureInfo]::InvariantCulture)
        } elseif ($bit -ne "") { $pairs += $bit }
    }
    $colours = $pairs -join ","

    $call = @("-ExecutionPolicy", "Bypass", "-File", "tools\render_pixel_test.ps1",
              "-Model", $Model, "-Name", $tag, "-Height", $Height,
              "-From", $Frame, "-To", $Frame,
              "-Angle", $Angle, "-Elevation", $Elevation,
              "-MatColours", $colours,
              "-IronFrom", $iron)
    if ($Weapon -ne "") { $call += @("-Weapon", $Weapon) }
    if ($WModel -ne "") { $call += @("-WModel", $WModel) }
    if ($WFit   -ne "") { $call += @("-WFit",   $WFit) }

    & powershell @call *> "render\$tag`_log.txt"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  zlyhalo, pozri render\$tag`_log.txt" -ForegroundColor Red
    } else {
        Write-Host "  ok -> volya\art\${tag}_px" -ForegroundColor DarkGray
    }
}

# Build the comparison sheet here rather than leaving it as homework. Every
# one of these runs ends by looking at the variants side by side, so the run
# should end by producing that picture.
$python = $null
foreach ($cand in @("python", "py", "python3")) {
    if (Get-Command $cand -ErrorAction SilentlyContinue) { $python = $cand; break }
}
if ($python) {
    & $python "tools\make_grid.py" --name $Name --labels "render\$Name`_variants.txt"
    $sheet = "render\_look\$Name.png"
    if (Test-Path $sheet) { Invoke-Item $sheet }
} else {
    Write-Host "Python sa nenasiel, mriezku som nezlozil." -ForegroundColor Red
}

Write-Host ""
Write-Host "Hotovo. Sprajty su vo volya\art\${Name}_vNN_px" -ForegroundColor Green
