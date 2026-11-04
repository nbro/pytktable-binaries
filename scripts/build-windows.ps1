<#
.SYNOPSIS
    Compiles Tktable on Windows, once against Tcl/Tk 8.6 and once against Tcl/Tk 9.0, and puts both
    libraries, with the pkgIndex.tcl that loads the right one, in one folder.

.DESCRIPTION
    Run it in a Visual Studio developer shell for the target architecture (cl and nmake on PATH).

.EXAMPLE
    scripts/build-windows.ps1 out
#>
param([Parameter(Mandatory)][string]$Out)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path "$PSScriptRoot\..").Path
$build = Join-Path $root "build"


function Read-VersionFile {
    $versions = @{}
    Get-Content "$root\versions.env" | Where-Object { $_ -match "^\w+=" } | ForEach-Object {
        $name, $value = $_ -split "=", 2
        $versions[$name] = $value
    }
    return $versions
}


function Invoke-Nmake {
    param([Parameter(Mandatory)][string]$Dir, [Parameter(Mandatory)][string[]]$Arguments)

    Push-Location $Dir
    try {
        # Out-Host: show nmake's output without it becoming the return value of the caller.
        nmake -nologo -f makefile.vc @Arguments | Out-Host
        if ($LASTEXITCODE -ne 0) { throw "nmake $Arguments failed in $Dir" }
    }
    finally {
        Pop-Location
    }
}


# Clones Tcl and Tk at the given tag, and compiles and installs them in build\<tag>\install.
function Build-TclTk {
    param([Parameter(Mandatory)][string]$Tag)

    $dir = Join-Path $build $Tag
    foreach ($name in "tcl", "tk") {
        if (-not (Test-Path "$dir\$name")) {
            git clone --quiet --depth 1 --branch $Tag "https://github.com/tcltk/$name" "$dir\$name"
            if ($LASTEXITCODE -ne 0) { throw "git clone of $name $Tag failed" }
        }
    }

    # Build and install in separate nmake runs: makefile.vc decides what to install (e.g. tclsh)
    # when nmake starts, so in one run with "release install" it skips what isn't built yet.
    $install = "$dir\install"
    Invoke-Nmake "$dir\tcl\win" @("release", "INSTALLDIR=$install")
    Invoke-Nmake "$dir\tcl\win" @("install", "INSTALLDIR=$install")
    Invoke-Nmake "$dir\tk\win" @("release", "INSTALLDIR=$install", "TCLDIR=$dir\tcl")
    Invoke-Nmake "$dir\tk\win" @("install", "INSTALLDIR=$install", "TCLDIR=$dir\tcl")
    return $install
}


# Compiles Tktable against the installed Tcl and Tk, in a copy of its source in build\<tag>\tktable.
function Build-Tktable {
    param([Parameter(Mandatory)][string]$Tag, [Parameter(Mandatory)][string]$Install)

    # nmake builds inside the source folder, so each build needs its own copy.
    $source = Join-Path $build "$Tag\tktable"
    Remove-Item -Recurse -Force $source -ErrorAction SilentlyContinue
    Copy-Item -Recurse "$root\tktable-src" $source

    Invoke-Nmake "$source\win" @("all", "pkgindex", "INSTALLDIR=$Install")
    return "$source\win"
}


# Tktable's Makefile rule that writes manifest.uuid is broken (a stray "@" inside a shell command),
# so write that file ourselves.
$commit = git -C "$root\tktable-src" rev-parse HEAD
Set-Content -NoNewline -Path "$root\tktable-src\manifest.uuid" -Value "git-$commit"

$versions = Read-VersionFile
$results = foreach ($tag in $versions.TCL8_TAG, $versions.TCL9_TAG) {
    $install = Build-TclTk -Tag $tag
    Build-Tktable -Tag $tag -Install $install
}

python "$root\scripts\collect.py" $results[0] $results[1] $Out
if ($LASTEXITCODE -ne 0) { throw "collect.py failed" }
