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
For the story behind it, see [this blog post](https://nbro.gitlab.io/python/2026/11/04/pytktable-a-spreadsheet-like-table-widget-for-tkinter-wrapping-the-tcl-tk-tktable-extension/).

Each wheel contains Tktable compiled for Tcl/Tk 8.6 and for Tcl/Tk 9.0; Tcl loads the one matching
the Tcl/Tk of the Python that runs it. The libraries don't depend on the Python version, so one
wheel per platform works with every Python 3.

| Platform                           | Wheel tags                                        | Tested on (CI)                         |
|------------------------------------|---------------------------------------------------|----------------------------------------|
| Linux with glibc (most distros)    | `manylinux_2_28_x86_64`, `manylinux_2_28_aarch64` | Ubuntu 24.04, Debian (x86_64, ARM64), Fedora, CentOS Stream 10, Rocky Linux 9, openSUSE Tumbleweed, Kali Linux (x86_64) |
| Linux with musl (e.g. Alpine)      | `musllinux_1_2_x86_64`, `musllinux_1_2_aarch64`   | Alpine (x86_64, ARM64)                 |
| macOS 11+, Intel and Apple silicon | `macosx_11_0_universal2`                          | macOS 15 (Intel, Apple silicon)        |
| Windows                            | `win_amd64`, `win32`, `win_arm64`                 | Windows Server 2025 (x64, x86), Windows 11 (ARM64) |

### Python and Tcl/Tk versions

Which Tcl/Tk a Python uses depends on how it was installed, and the wheels work with both 8.6 and
9.0, so you don't need to care about it. For example:

| Python                             | Tcl/Tk                                            |
|------------------------------------|---------------------------------------------------|
| 3.11 to 3.13, python.org installers for Windows | 8.6                                  |
| 3.14 and newer, python.org installers for Windows | 9.0                                |
| Linux distributions                | the distribution's, e.g. 8.6 on Ubuntu 24.04 and 9.0 on Fedora |

### Where Tktable comes from

Tktable was created by Roland King in 1994, and then developed and maintained for many years by
Jeffrey Hobbs, with its releases on [SourceForge](https://sourceforge.net/projects/tktable/), the
last one being 2.10, from 2008. The wheels are built from a release tag of
[bohagan1/TkTable](https://github.com/bohagan1/TkTable), by Brian O'Hagan, which continues it and
seems to be the only version that is still maintained. Other, more recent versions than
SourceForge's are listed below, as of November 2026. They're developed independently, so a fix in
one isn't necessarily in the others.

| Repository | Latest version | Last commit | Notes |
|---|---|---|---|
| [bohagan1/TkTable](https://github.com/bohagan1/TkTable) | 2.12.2 (tag `tktable-2-12-2`) | 2026 | Used for these wheels |
| [chpock/tktable](https://github.com/chpock/tktable) | 2.11.1 (tag `v2.11.1`) | 2024 | |
| [wjoye/tktable](https://github.com/wjoye/tktable) | 2.10.8 (tag `v2.10.8`) | 2023 | |
| [apnadkarni/tktable](https://github.com/apnadkarni/tktable) | 2.11 (tag `magicsplat-1.8.0`) | 2017 | Snapshot used for [Magicsplat Tcl/Tk](https://magicsplat.com/tcl-installer) |

Because of these differences, Tktable from other sources (e.g. Linux distributions, MacPorts,
Magicsplat) can behave slightly differently from the one in these wheels, e.g. in the default
colors of the title rows.

### Why a separate package

Python packages are distributed as wheels, i.e. zip files that `pip` installs. pytktable is pure
Python, so it needs a single wheel that works everywhere, while compiled code needs one wheel per
operating system and architecture. Keeping the compiled part in this separate package, built in
this separate repo, doesn't clutter pytktable's repo, and `pip install "pytktable[binary]"`
installs both.
psycopg 3 also ships its compiled part as a separate package, `psycopg-binary`, which its `binary`
extra installs (see its
[pyproject.toml](https://github.com/psycopg/psycopg/blob/master/psycopg/pyproject.toml)), but it
builds it in the same repo as the rest of psycopg.

### Possible future platforms

- Linux on other CPUs: 32-bit ARM (`armv7l`, older Raspberry Pi OS), `ppc64le`, `s390x`,
  `riscv64`. They would be compiled under emulation, which is slow.
- Linux with glibc older than 2.28 (`manylinux2014`): only end-of-life distributions, e.g. CentOS 7
  (glibc 2.17). RHEL, CentOS Stream, Rocky Linux and AlmaLinux 8 and newer have glibc 2.28 or
  newer, so they already use the `manylinux_2_28` wheels.
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
  `test.yml`, which tests them with pytktable's tests on each platform, and on Debian, Fedora and
  Alpine (`scripts/test-distro.sh`). It also runs on the 1st of every month, to catch breakage from
  new runner images, Python or Tcl/Tk versions early.

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

## Maintenance

### What is checked automatically

The `Build` workflow builds and tests the wheels on every push and pull request to `main`, and on
the 1st of every month. The tests run pytktable's tests with `TKTABLE_REQUIRED=1`, so they fail if
Tktable cannot be loaded, with:

- Python 3.11 and 3.14, which use Tcl/Tk 8.6 and 9.0 with the python.org installers for Windows;
- `3.x`, the latest stable Python, so a new Python (and the Tcl/Tk it comes with) is tested as soon
  as it's released;
- the own Python and Tcl/Tk of Debian, Fedora and Alpine.

GitHub notifies the person who created the schedule when the monthly run fails. In public repos,
GitHub disables scheduled workflows after 60 days without activity: if that happens, enable the
`Build` workflow again in the Actions tab.

### Flaky tests on Windows

Sometimes a Windows test job fails because Tktable cannot be loaded right after it was installed,
most likely while the antivirus of GitHub's runner is still scanning the new files. The error is
then one of:

- `couldn't read file ...\pkgIndex.tcl: no such file or directory`;
- `attempt to provide package Tktable ... failed: no version of package Tktable provided`.

pytktable's tests already try to load Tktable 3 times. When it still fails, they print a
`Tktable load report` at the end of the test output: the error of every try, Tcl's stack trace,
what Tcl knows about Tktable and which files are in `TKTABLE_LIBRARY`. The same report is printed
when Tktable is loaded only after a failed try, so flakes are visible even in passing jobs.

If the same job passes in other runs, it's a flake: rerun only the failed jobs, either from the
run's page in the Actions tab (`Re-run jobs` > `Re-run failed jobs`) or with:

```shell
gh run rerun <run-id> --failed
```

A run can be rerun up to 30 days after it started. If a job fails the same way again and again,
it's not a flake: read the report.

### When to change what

| What happens | What to do | Where |
|---|---|---|
| Tktable (bohagan1/TkTable) releases a new version | Check out its tag in the submodule, set `version` in `pyproject.toml` to its version, and release | `tktable-src`, `pyproject.toml` |
| This package needs a fix or a new platform, with the same Tktable | Fix it, and release with a fourth version number, e.g. `2.12.2.1` | Depends on the fix |
| A new Tcl/Tk patch or minor version, e.g. 8.6.19 or 9.1 | Nothing: the libraries use Tcl's stubs, so they work with any 8.6.x and 9.x. Optionally update the tags the builds use | `versions.env` |
| A Python (or a Linux distribution) switches from Tcl/Tk 8.6 to 9 | Nothing: each wheel contains both builds, and `pkgIndex.tcl` loads the one matching the running Tcl | - |
| A Python ships a new Tcl/Tk major version, e.g. Tcl 10 (the monthly run fails) | Tktable must support it upstream: its C code, and its `pkgIndex.tcl.in`, which only knows Tcl 8 and 9. Then add a third build, pin that Python in the test matrix, and release | `versions.env`, `scripts/build-*`, `scripts/collect.py`, `.github/workflows/test.yml` |
| Tk changes how it works, e.g. native Wayland instead of X11 | Tktable must support it upstream; then update the submodule and release | `tktable-src` |

`pkgIndex.tcl` is not ours: Tktable's build generates it from Tktable's `pkgIndex.tcl.in`, and
`scripts/collect.py` checks that the Tcl 8 and Tcl 9 builds generated the same one.

### When GitHub retires a runner or the PyPA retires a build image

The published wheels keep working: they don't depend on the machines that built them. Only new
builds or tests can fail, until the workflows use the replacement.

- Linux: the wheels are built in the PyPA's manylinux and musllinux containers, not on the runner's
  own system, so a new Ubuntu runner changes nothing. If the PyPA retires an image (e.g.
  `manylinux_2_28`), switch to its successor in `compile-linux.yml`; the new wheels then need a
  newer glibc or musl.
- macOS: the universal2 libraries (Intel and Apple silicon) are built on an Apple silicon runner, so
  when the Intel runner (`macos-15-intel`) goes away, only the tests on Intel are lost, not the
  Intel part of the wheel. macOS can't be emulated on GitHub's Linux or Windows runners.
- Windows: the 32-bit build already runs on the x64 runner, with the 32-bit compiler. If a runner
  type disappears, the other builds can be cross-compiled in the same way.

In every case, replace the runner or image name in `compile-*.yml` and `test.yml`.

### What is not done

- No source package (sdist): building Tktable needs a C compiler and Tcl/Tk sources, so on a
  platform without a wheel, `pip install pytktable-binaries` (and `pip install "pytktable[binary]"`)
  fails with "No matching distribution found". There, use `pip install pytktable` and install
  Tktable separately.
- No wheels for FreeBSD and the other BSDs: as far as we know, PyPI doesn't accept them.
- No wheels for the platforms in [Possible future platforms](#possible-future-platforms), e.g.
  32-bit ARM Linux, which could be built under emulation if needed.
- No tests with PyPy.

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
