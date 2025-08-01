# Cleanup aux files
function Clean-AuxFiles {
    param (
        [string]$directory
    )

    if (Test-Path $directory) {
        $auxFiles = Get-ChildItem "$directory\*" -Include *.aux, *.log, *.out -ErrorAction SilentlyContinue
        if ($auxFiles) {
            Write-Host "Removing auxiliary files in $directory..."
            $auxFiles | Remove-Item -Force
        }
    }
}

$buildDir = "build"
if (-not (Test-Path $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir | Out-Null
}

# Delete existing PDFs
$existingPdfs = Get-ChildItem "$buildDir\*.pdf"
if ($existingPdfs) {
    Write-Host "Removing old PDFs..."
    $existingPdfs | Remove-Item
}

# Clean aux files BEFORE compilation
Clean-AuxFiles -directory $buildDir

# Get files
$texFiles = gci inputs -Filter *.tex | Where-Object { $_.Name -match '^(english|french).*\.tex$' } 

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
    pdflatex -interaction=nonstopmode -output-format=pdf -output-directory=build $file.FullName.Replace('\','/') | Out-Null
}

# Clean aux files AFTER compilation
Clean-AuxFiles -directory $buildDir
