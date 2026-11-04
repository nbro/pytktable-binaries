# pytktable-binaries

[![PyPI](https://img.shields.io/pypi/v/pytktable-binaries)](https://pypi.org/project/pytktable-binaries/)
[![Python](https://img.shields.io/pypi/pyversions/pytktable-binaries)](https://pypi.org/project/pytktable-binaries/)
[![OS](https://img.shields.io/badge/os-Linux%20%7C%20macOS%20%7C%20Windows-blue)](#pytktable-binaries)
[![Architectures](https://img.shields.io/badge/arch-x86__64%20%7C%20arm64%20%7C%20x86-blue)](#pytktable-binaries)
[![Build](https://github.com/nbro/pytktable-binaries/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/nbro/pytktable-binaries/actions/workflows/build.yml)
[![Checks](https://github.com/nbro/pytktable-binaries/actions/workflows/checks.yml/badge.svg?branch=main)](https://github.com/nbro/pytktable-binaries/actions/workflows/checks.yml)
[![License](https://img.shields.io/badge/license-BSD%202--Clause-orange.svg)](LICENSE.md)

Prebuilt [Tktable](https://github.com/bohagan1/TkTable), the Tcl/Tk table widget, for
[pytktable](https://github.com/nbro/tktable), so that Python users don't need to install Tktable
with their operating system's package manager.

Each wheel contains Tktable compiled for Tcl/Tk 8.6 and for Tcl/Tk 9.0; Tcl loads the one matching
the Tcl/Tk of the Python that runs it. The libraries don't depend on the Python version, so one
wheel per platform works with every Python 3.

| Platform                         | Wheel tags                                         |
|----------------------------------|----------------------------------------------------|
| Linux with glibc (most distros)  | `manylinux_2_28_x86_64`, `manylinux_2_28_aarch64`  |
| Linux with musl (e.g. Alpine)    | `musllinux_1_2_x86_64`, `musllinux_1_2_aarch64`    |
| macOS 11+, Intel and Apple silicon | `macosx_11_0_universal2`                         |
| Windows                          | `win_amd64`, `win32`, `win_arm64`                  |

### Possible future platforms

- Linux on other CPUs: 32-bit ARM (`armv7l`, older Raspberry Pi OS), `ppc64le`, `s390x`,
  `riscv64`. They would be compiled under emulation, which is slow.
- Linux with glibc older than 2.28 (`manylinux2014`): only end-of-life distributions, e.g. CentOS 7.
- macOS older than 11.
- PyPy: the wheels don't depend on the Python version, so they should already work; it would need
  a test job.

## Usage

`library_dir()` returns the folder to add to Tcl's `auto_path`. For example, with pytktable:

```python
import os

import tktable_binaries

os.environ["TKTABLE_LIBRARY"] = str(tktable_binaries.library_dir())
```

## How it is built

- `tktable-src` is a Git submodule pinned to a Tktable release tag.
- `versions.env` pins the Tcl/Tk sources it is compiled against (only their headers and stub
  libraries are used, so the result works with any Tcl/Tk 8.6.x or 9.0.x).
- `scripts/build-unix.sh` (Linux, macOS) and `scripts/build-windows.ps1` (Windows) compile Tktable
  against Tcl/Tk 8.6 and 9.0, and `scripts/collect.py` puts both in one `Tktable<version>` folder.
- `scripts/make_wheel.py` builds the wheel of one platform from that folder.
- The `Build` workflow (`.github/workflows/build.yml`) does all of this on GitHub Actions: it calls
  `compile-linux.yml`, `compile-macos.yml` and `compile-windows.yml`, builds the wheels, then calls
  `test.yml`, which tests them with pytktable's tests on each platform, and on Debian, Fedora and Alpine
  (`scripts/test-distro.sh`). It also runs on the 1st of every month, to catch breakage from new
  runner images, Python or Tcl/Tk versions early.

To update Tktable, check out another tag in the submodule, and set `version` in `pyproject.toml`
to its version:

```sh
git -C tktable-src fetch --tags
```

```sh
git -C tktable-src checkout <tag>
```

## Versioning

The version is the version of Tktable it contains, plus a fourth number for the releases of this
package with the same Tktable (e.g. a build fix or a new platform):

| Change                                  | Version                  |
|-----------------------------------------|--------------------------|
| First release with Tktable 2.12.2       | `2.12.2`                 |
| A fix of this package, same Tktable     | `2.12.2.1`, `2.12.2.2`   |
| Tktable 2.12.3                          | `2.12.3`                 |

[PEP 440](https://peps.python.org/pep-0440/) allows any number of version components, so
`2.12.2` < `2.12.2.1` < `2.12.3`.

## Development

Install [Poetry](https://python-poetry.org/docs/#installation), then the dev dependencies and the
[pre-commit](https://pre-commit.com/) hooks, which format and lint Python, YAML, shell and
PowerShell files, and scan for secrets, on every `git commit`:

```sh
poetry install
```

```sh
poetry run pre-commit install
```

The PowerShell hook needs [PowerShell 7](https://learn.microsoft.com/powershell/scripting/install/installing-powershell)
(`pwsh`) and PSScriptAnalyzer. Save PSScriptAnalyzer once inside the repository, in `.tools/Modules`
(not in Git), so nothing changes outside the repository:

```powershell
New-Item -ItemType Directory -Force .tools/Modules
```

```powershell
Save-PSResource PSScriptAnalyzer -Path .tools/Modules -TrustRepository
```

To run all hooks on all files, as the `Checks` workflow does:

```sh
poetry run pre-commit run --all-files
```

## Releasing

1. Set `version` in `pyproject.toml` (see [Versioning](#versioning)) and commit it to `main`.
2. Push a tag with the same version, e.g. `2.12.2`.

The `Release` workflow (`.github/workflows/release.yml`) then checks that the tag and the version
are equal, builds and tests the wheels, publishes them to PyPI with
[Trusted Publishing](https://docs.pypi.org/trusted-publishers/) (no API token), and creates a
GitHub release with them.

## AI assistance

This repository was created with the help of [Claude](https://claude.ai) (Anthropic). The
maintainer reviewed the changes, but not always thoroughly. Please report any problem you find.

## License

The build scripts: [BSD 2-Clause](LICENSE.md). Tktable: its own
[license](https://github.com/bohagan1/TkTable/blob/master/license.txt), included in the wheels.
