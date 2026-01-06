param (
    [string]$BuildDir = "build",
    [string]$InputsDir = "inputs",
    [string[]]$Targets,
    [switch]$Debug
)

# Extension sets
$AUX_EXTENSIONS = @("*.aux", "*.log", "*.out")
$PDF_EXTENSIONS = @("*.pdf")

# Cleanup files (aux and old PDFs)
function Clean-Files {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Directory,
        [string[]]$Extensions
    )

    if (Test-Path $Directory) {
        $files = Get-ChildItem -Path $Directory/* -Include $Extensions -File -ErrorAction SilentlyContinue
        if ($files) {
            Write-Host "Removing files ($($Extensions -join ', ')) in '$Directory'..."
            $files | Remove-Item -Force
        }
    } else {
        Write-Warning "Directory '$Directory' does not exist."
    }
}

if (-not (Test-Path $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir | Out-Null
}

# Delete existing PDFs
Clean-Files -directory $buildDir -Extensions $PDF_EXTENSIONS

# Clean aux files BEFORE compilation
Clean-Files -directory $buildDir -Extensions $AUX_EXTENSIONS

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
        pdflatex -interaction=nonstopmode -output-format=pdf -output-directory="$BuildDir" $($file.FullName.Replace('\','/'))
    } else {
        pdflatex -interaction=nonstopmode -output-format=pdf -output-directory="$BuildDir" $($file.FullName.Replace('\','/')) | Out-Null
    }

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Done: $($file.Name)"
    } else {
        Write-Host "Failure: $($file.Name)" -ForegroundColor Red
    }
}

# Clean aux files AFTER compilation
Clean-Files -directory $buildDir -Extensions $AUX_EXTENSIONS
