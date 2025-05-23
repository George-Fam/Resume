param (
    [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
    [string[]]$Targets
)

$Template = "coverTemplate.tex"
$ContentDir = "inputs/covers"
$OutputDir = "covers"

# Ensure build folder exists
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

foreach ($Target in $Targets) {
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
