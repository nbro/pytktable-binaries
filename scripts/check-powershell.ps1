<#
.SYNOPSIS
    Formats PowerShell scripts in place and lints them, with PSScriptAnalyzer.

.DESCRIPTION
    Used by the pre-commit hook "powershell" (.pre-commit-config.yaml), which passes the files to
    check. Uses the PSScriptAnalyzer saved in .tools/Modules (see "Development" in README.md).
    Exits with 1 if it is not there, or if a script has warnings or errors.

.EXAMPLE
    pwsh -NoProfile -File scripts/check-powershell.ps1 scripts/build-windows.ps1
#>
param([Parameter(ValueFromRemainingArguments)][string[]]$Path)

$ErrorActionPreference = "Stop"

# PSScriptAnalyzer is saved inside the repository, in .tools/Modules (not in Git), so installing it
# changes nothing outside the repository. Add that folder to the module path only for this run.
$modules = Join-Path (Resolve-Path "$PSScriptRoot\..").Path ".tools\Modules"
$env:PSModulePath = $modules + [IO.Path]::PathSeparator + $env:PSModulePath

if (-not (Get-Module -ListAvailable PSScriptAnalyzer)) {
    "PSScriptAnalyzer is not in .tools/Modules. Install it once, from the repository root:"
    "  New-Item -ItemType Directory -Force .tools/Modules"
    "  Save-PSResource PSScriptAnalyzer -Path .tools/Modules -TrustRepository"
    exit 1
}

$failed = $false
foreach ($file in $Path) {
    # Format in place; pre-commit reports the file as changed, so the commit stops for a review.
    $script = Get-Content -Raw $file
    $formatted = Invoke-Formatter -ScriptDefinition $script
    if ($formatted -ne $script) {
        Set-Content -NoNewline -Path $file -Value $formatted
    }

    $results = Invoke-ScriptAnalyzer -Path $file -Severity Warning, Error
    foreach ($result in $results) {
        "${file}:$($result.Line): $($result.RuleName): $($result.Message)"
        $failed = $true
    }
}

if ($failed) { exit 1 }
