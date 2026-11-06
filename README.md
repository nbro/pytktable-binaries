# pytktable-binaries

[![PyPI](https://img.shields.io/pypi/v/pytktable-binaries)](https://pypi.org/project/pytktable-binaries/)
[![Python](https://img.shields.io/pypi/pyversions/pytktable-binaries)](https://pypi.org/project/pytktable-binaries/)
[![OS](https://img.shields.io/badge/os-Linux%20%7C%20macOS%20%7C%20Windows-blue)](#pytktable-binaries)
[![Architectures](https://img.shields.io/badge/arch-x86__64%20%7C%20arm64%20%7C%20x86-blue)](#pytktable-binaries)
[![Build](https://github.com/nbro/pytktable-binaries/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/nbro/pytktable-binaries/actions/workflows/build.yml)
[![Checks](https://github.com/nbro/pytktable-binaries/actions/workflows/checks.yml/badge.svg?branch=main)](https://github.com/nbro/pytktable-binaries/actions/workflows/checks.yml)
[![License](https://img.shields.io/badge/license-BSD%202--Clause-orange.svg)](https://github.com/nbro/pytktable-binaries/blob/main/LICENSE.md)

Prebuilt [Tktable](https://github.com/bohagan1/TkTable), the Tcl/Tk table widget, for
[pytktable](https://github.com/nbro/tktable), so that Python users don't need to install Tktable
with their operating system's package manager.
For the story behind it, see [this blog post](https://nbro.gitlab.io/python/2026/11/04/pytktable-a-spreadsheet-like-table-widget-for-tkinter-wrapping-the-tcl-tk-tktable-extension/).

Each wheel contains Tktable compiled for Tcl/Tk 8.6 and for Tcl/Tk 9.0, for Linux (glibc and musl,
x86_64 and ARM64), macOS 11+ (Intel and Apple silicon) and Windows (x64, x86 and ARM64). Install it
with pytktable:

```sh
pip install "pytktable[binary]"
```

## Usage

`library_dir()` returns the folder to add to Tcl's `auto_path`. For example, with pytktable:

```python
import os

import tktable_binaries

os.environ["TKTABLE_LIBRARY"] = str(tktable_binaries.library_dir())
```

## Documentation

- [Platforms](https://github.com/nbro/pytktable-binaries/blob/main/docs/platforms.md): supported platforms, where they are tested, Python and Tcl/Tk
  versions, and possible future platforms.
- [Tktable](https://github.com/nbro/pytktable-binaries/blob/main/docs/tktable.md): where Tktable comes from, its forks, and why this is a separate
  package.
- [Building](https://github.com/nbro/pytktable-binaries/blob/main/docs/building.md): how the wheels are built, and how to update Tktable.
- [Testing](https://github.com/nbro/pytktable-binaries/blob/main/docs/testing.md): how the wheels are tested, the X servers Tk needs on Linux, and flaky
  tests.
- [Development](https://github.com/nbro/pytktable-binaries/blob/main/docs/development.md): tools and checks.
- [Maintenance](https://github.com/nbro/pytktable-binaries/blob/main/docs/maintenance.md): what is checked automatically, and when to change what.
- [Versioning and releasing](https://github.com/nbro/pytktable-binaries/blob/main/docs/releasing.md): version numbers, and how to publish a release.

## AI assistance

This repository was created with the help of [Claude](https://claude.ai) (Anthropic). The
maintainer reviewed the changes, but not always thoroughly. Please report any problem you find.

## License

The build scripts: [BSD 2-Clause](https://github.com/nbro/pytktable-binaries/blob/main/LICENSE.md). Tktable: its own
[license](https://github.com/bohagan1/TkTable/blob/master/license.txt), included in the wheels.
