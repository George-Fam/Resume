param (
    [Parameter(Mandatory = $true)]
    [string]$CoversDir,

    [Parameter(Mandatory = $true)]
    [string]$CvPath,

    [Parameter(Mandatory = $true)]
    [string]$SystemPromptPath,

    [Parameter(Mandatory = $false)]
    [string]$ExamplePath,
    
    [string]$Model = "gpt-5.2"
)

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Script = Join-Path $Root "generateCover.py"

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    throw "Python is not installed or not on PATH"
}

if (-not (Test-Path $Script)) {
    throw "Python script not found: $Script"
}

if (-not (Test-Path $CoversDir)) {
    throw "Covers directory not found: $CoversDir"
}

if (-not (Test-Path $CvPath)) {
    throw "CV file not found: $CvPath"
}

if (-not (Test-Path $SystemPromptPath)) {
    throw "System prompt file not found: $SystemPromptPath"
}

if ($ExamplePath -and -not (Test-Path $ExamplePath)) {
    throw "Example file not found: $ExamplePath"
}

Write-Host "Generating covers..."
Write-Host "CoversDir : $CoversDir"
Write-Host "CV        : $CvPath"
Write-Host "Prompt    : $SystemPromptPath"
if ($ExamplePath) {
    Write-Host "Example        : $ExamplePath"
}
Write-Host "Model     : $Model"
Write-Host ""

$pythonArgs = @(
    "--covers-dir", $CoversDir,
    "--cv-path", $CvPath,
    "--system-prompt-path", $SystemPromptPath,
    "--model", $Model
)

if ($ExamplePath) {
    $pythonArgs += @("--example-path", $ExamplePath)
}

& python $Script @pythonArgs

Write-Host ""
Write-Host "Done."
