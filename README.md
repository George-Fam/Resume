# LaTeX CV & Cover Letter Automation

## Summary
A reproducible document generation pipeline built with **PowerShell, Python, LaTeX, and GitHub Actions** to automate multilingual CV and cover letter production. This system eliminates tedious manual formatting by generating, compiling, validating, and versioning tailored LaTeX documents from structured inputs.

It also supports batch compilation, selective document builds and digital signature embedding.

P.S. I use this system to manage my own resume and cover letters. The repository includes my CV, tracked and versioned to reflect updates over time.

## Architecture
The project consists of:

- **PowerShell build scripts** for controlled LaTeX compilation
- **Python + OpenAI API integration** for automated cover letter generation
- **CI/CD pipelines (GitHub Actions)** for automated builds and artifact validation
- **Template-based LaTeX structure** with strict formatting validation
- **Batch and targeted build support**
- **Digital signature embedding**

## Core Features

### Automated CV Compilation
- Batch compilation of multiple `.tex` CV variants
- Selective target builds
- Debug mode for compilation tracing
- Output + auxiliary directory separation
- Non-blocking LaTeX error handling

### AI-Generated Cover Letters
- Uses OpenAI API to generate tailored LaTeX cover letters
- Injects CV + job posting + system prompt
- Validates LaTeX output before writing
- Automatically backs up previous versions
- Enforces compile-safe LaTeX formatting

### CI/CD Integration
- GitHub Actions pipeline for:
  - Automated builds
  - Artifact versioning
  - Reproducible PDF generation
- Ensures consistent output across environments

### Digital Signature Injection
- Automatically embeds signature image into generated cover letters
- Centralized asset management

## Requirements
- PowerShell 7+
- Python 3.10+
- OpenAI API Key
- TeX Live / MikTeX

## Usage
### Build All CVs
```powershell
./build.ps1
```

### Build Specific CVs
```powershell
./build.ps1 -Targets english.tex,french.tex
```

### Debug Mode (shows pdflatex output)
```powershell
./build.ps1 -Debug
```

### Build All Cover Letters
```powershell
./buildCovers.ps1
```

### Build Specific Covers
```powershell
./buildCovers.ps1 Company1 Company2
```

### Signature Embedding
To embed a digital signature image at the bottom of each cover letter:

- Place your signature image in `inputs/signature.png`
- The script inserts `\includegraphics` into the final LaTeX before compilation

## Acknowledgements
The CV template and style files are adapted from **[MTeck’s Resume](https://www.overleaf.com/latex/templates/mtecks-resume/fzgztpkgngjc)** by Michael Lustfield, used under the [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) license.
