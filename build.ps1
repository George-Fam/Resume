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

# Compile 
gci *.tex | foreach {
	pdflatex -output-format=pdf -output-directory=build $_.Name  | Out-Null
	Write-Host "Done: $_.Name"
}

# Clean aux files AFTER compilation
Clean-AuxFiles -directory $buildDir
