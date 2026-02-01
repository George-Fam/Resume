param (
    [string[]]$Targets = @(),
    [string]$ContentDir = "inputs/covers",
    [string]$BuildDir = "build/covers",
    [switch]$Debug
)

$Template = "coverTemplate.tex"
$AuxDir = Join-Path $BuildDir "auxDirectory"

# Ensure directories exist
$BuildDir, $AuxDir | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ | Out-Null
    }
}

# Default Targets (ALL)
if ($Targets.Count -eq 0) {
    $Targets = gci $ContentDir -Filter *.tex | % { $_.BaseName }
}

# Progress Vars
$total = $Targets.Count
$index = -1

foreach ($Target in $Targets) {
    #Progress
    $index++
    Write-Progress -Activity "Building Covers" -Status "Processing $Target ($index of $total)" -PercentComplete ($index / $total * 100)
    
    $ContentFile = Join-Path $ContentDir "$Target.tex"
    $CombinedTex = Join-Path $AuxDir "cover$Target.tex"

    if (Test-Path $ContentFile) {
        Get-Content $Template, $ContentFile | Set-Content $CombinedTex -Encoding UTF8

        if ($Debug) {
            latexmk -pdf -interaction=nonstopmode -outdir="$BuildDir" -auxdir="$AuxDir" $CombinedTex
        } else {
            latexmk -pdf -interaction=nonstopmode -outdir="$BuildDir" -auxdir="$AuxDir" $CombinedTex | Out-Null
        }

        if ($LASTEXITCODE -eq 0) {
            Write-Host "Done: $ContentFile"
        } else {
            Write-Host "Failure: $ContentFile" -ForegroundColor Red
        }
    } else {
        Write-Warning "Content file '$ContentFile' not found. Skipping."
    }
}
