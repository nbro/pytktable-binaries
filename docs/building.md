# How it is built

- `tktable-src` is a Git submodule pinned to a Tktable release tag.
- `versions.env` pins the Tcl/Tk sources it is compiled against (only their headers and stub
  libraries are used, so the result works with any Tcl/Tk 8.6.x or 9.0.x).
- `scripts/build-unix.sh` (Linux, macOS) and `scripts/build-windows.ps1` (Windows) compile Tktable
  against Tcl/Tk 8.6 and 9.0, and `scripts/collect.py` puts both in one `Tktable<version>` folder.
- `scripts/make_wheel.py` builds the wheel of one platform from that folder.
- The `Build` workflow (`.github/workflows/build.yml`) does all of this on GitHub Actions: it calls
  `compile-linux.yml`, `compile-macos.yml` and `compile-windows.yml`, builds the wheels, then calls
  `test.yml`, which tests them with pytktable's tests on each platform, and on several Linux
  distributions (`scripts/test-distro.sh`, see [Testing](testing.md)). It also runs on the 1st of
  every month, to catch breakage from new runner images, Python or Tcl/Tk versions early.

To update Tktable, check out another tag in the submodule, and set `version` in `pyproject.toml`
to its version:

```sh
git -C tktable-src fetch --tags
```

```sh
git -C tktable-src checkout <tag>
```
