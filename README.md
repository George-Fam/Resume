# LaTeX CV & Cover Letter Automation

This project automates the generation of multilingual CVs and cover letters written in LaTeX using PowerShell scripts. It supports batch compilation, selective document builds and digital signature embedding.

I use this system to manage my own resume and cover letters. The repository includes both **English** and **French** versions of my CV, tracked and versioned to reflect updates over time.

## Requirements
- PowerShell 7+
- TeX Live or MikTeX or other including pdflatex

## Usage
### Build All CVs
```powershell
./scripts/build.ps1
```

### Build All Cover Letters
```powershell
./scripts/buildCovers.ps1
```

### Build Specific Covers
```powershell
./scripts/buildCovers.ps1 Company1 Company2
```

### Signature Embedding
To embed a digital signature image at the bottom of each document:

- Place your signature image in `inputs/signature.png`
- The script inserts `\includegraphics` into the final LaTeX before compilation

## Acknowledgements
The CV template and style files are adapted from **[MTeck’s Resume](https://www.overleaf.com/latex/templates/mtecks-resume/fzgztpkgngjc)** by Michael Lustfield, used under the [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) license.
