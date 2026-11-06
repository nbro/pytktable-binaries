# Maintenance

## What is checked automatically

The `Build` workflow builds and tests the wheels on every push and pull request to `main`, and on
the 1st of every month. The tests run pytktable's tests with `TKTABLE_REQUIRED=1`, so they fail if
Tktable cannot be loaded, with:

- Python 3.11 and 3.14, which use Tcl/Tk 8.6 and 9.0 with the python.org installers for Windows;
- `3.x`, the latest stable Python, so a new Python (and the Tcl/Tk it comes with) is tested as soon
  as it's released;
- the own Python and Tcl/Tk of several Linux distributions (see [Testing](testing.md)).

GitHub notifies the person who created the schedule when the monthly run fails. In public repos,
GitHub disables scheduled workflows after 60 days without activity: if that happens, enable the
`Build` workflow again in the Actions tab.


## When to change what

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

## When GitHub retires a runner or the PyPA retires a build image

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

## What is not done

- No source package (sdist): building Tktable needs a C compiler and Tcl/Tk sources, so on a
  platform without a wheel, `pip install pytktable-binaries` (and `pip install "pytktable[binary]"`)
  fails with "No matching distribution found". There, use `pip install pytktable` and install
  Tktable separately.
- No wheels for FreeBSD and the other BSDs: as far as we know, PyPI doesn't accept them.
- No wheels for the platforms in
  [Possible future platforms](platforms.md#possible-future-platforms), e.g. 32-bit ARM Linux, which could be built under emulation if needed.
- No tests with PyPy.
