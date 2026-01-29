param (
    [string]$BuildDir = "build",
    [string]$InputsDir = "inputs",
    [string[]]$Targets,
    [switch]$Debug
)

$AuxDir = Join-Path $BuildDir "aux"

if (-not (Test-Path $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir | Out-Null
}

# Get files (Use pattern if no target)
$texFiles = gci $InputsDir -Filter *.tex | Where-Object {
    if ($Targets) {
        $Targets -contains $_.Name
    } else {
        $_.Name -match '^.*\.tex$'
    }
}

# Handle no .tex files
if ($texFiles.Count -eq 0) {
    Write-Warning "No matching .tex files found in '$inputsDir'. Expected filenames like '*.tex'. Exiting."
    exit 1
}

# Progress vars
$total = $texFiles.Count
$index = -1

# Compile 
foreach ($file in $texFiles) {
    $index++
    Write-Progress -Activity "Compiling PDFs" `
        -Status "Processing $($file.Name) ($index of $total)" `
        -PercentComplete ($index / $total * 100)

    # Non stop mode to prevent pdflatex from hanging on error
    if ($Debug) {
        latexmk -pdf -interaction=nonstopmode -outdir="$BuildDir" -auxdir="$AuxDir" $($file.FullName.Replace('\', '/'))
    } else {
        latexmk -pdf -interaction=nonstopmode -outdir="$BuildDir" -auxdir="$AuxDir" $($file.FullName.Replace('\', '/')) | Out-Null
    }

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Done: $($file.Name)"
    } else {
        Write-Host "Failure: $($file.Name)" -ForegroundColor Red
    }
}
