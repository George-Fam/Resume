param (
    [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
    [string[]]$Targets
)

$Template = "coverTemplate.tex"
$ContentFolder = "inputs/covers"
$BuildFolder = "covers"

# Ensure build folder exists
if (-not (Test-Path $BuildFolder)) {
    New-Item -ItemType Directory -Path $BuildFolder | Out-Null
}

foreach ($Target in $Targets) {
    $OutputTex = "$BuildFolder\cover_$Target.tex"
    $ContentFile = "$ContentFolder\$Target.tex"

    if (Test-Path $ContentFile) {
        # Concatenate template and content into one .tex file
        Get-Content $Template, $ContentFile | Set-Content $OutputTex -Encoding UTF8

        # Compile the LaTeX file
        pdflatex -interaction=nonstopmode -output-directory $BuildFolder $OutputTex | Out-Null
    } else {
        Write-Warning "Content file '$ContentFile' not found. Skipping."
    }
}
