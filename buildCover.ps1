param (
    [string[]]$Targets=@()
)

$Template = "coverTemplate.tex"
$ContentDir = "inputs/covers"
$OutputDir = "build/covers"

# Ensure build folder exists
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# Default Targets (ALL)
if ($Targets.Count -eq 0){
    $Targets = gci -Path $ContentDir -Filter *.tex | % { $_.BaseName }
}

# Progress Vars
$total = $Targets.Count
$index = -1

foreach ($Target in $Targets) {
    #Progress
    $index++
    Write-Progress -Activity "Building Covers" -Status "Processing $Target ($index of $total)" -PercentComplete ($index/$total*100)

    $TexBase = "cover$Target"
    $OutputTex = "$TexBase.tex"
    $ContentFile = "$ContentDir\$Target.tex"

    if (Test-Path $ContentFile) {
        # Concatenate template and content into one .tex file
        Get-Content $Template, $ContentFile | Set-Content $OutputTex -Encoding UTF8

        # Compile the LaTeX file
        pdflatex -interaction=nonstopmode $OutputTex | Out-Null
        
        # Clean aux files
        $AuxFiles = @("$TexBase.aux", "$TexBase.log", "$TexBase.out", $OutputTex)
        Remove-Item $AuxFiles -ErrorAction SilentlyContinue

        # Move PDF to covers
        Move-Item "cover$Target.pdf" -Destination $OutputDir -Force
    } else {
        Write-Warning "Content file '$ContentFile' not found. Skipping."
    }
}
