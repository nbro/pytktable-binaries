"""Collects the two Tktable builds (Tcl 8.6 and 9.0) into one Tktable<version> folder.

Usage: python scripts/collect.py <Tcl 8 build folder> <Tcl 9 build folder> <output folder>

Both builds generate the same pkgIndex.tcl, which loads the library of the running Tcl's major
version, so both libraries can share one folder.
"""

import re
import shutil
import sys
from pathlib import Path

LIBRARY_SUFFIXES = (".so", ".dylib", ".dll")


def find_library(build: Path) -> Path:
    """The Tktable library in a build folder (e.g. libtcl9Tktable2.12.2.so, tktable2122.dll)."""
    found = [
        path
        for path in build.rglob("*")
        if path.suffix in LIBRARY_SUFFIXES and "tktable" in path.name.lower()
    ]
    if len(found) != 1:
        sys.exit(f"Expected one Tktable library in {build}, found: {found}")
    return found[0]


def find_pkg_index(build: Path) -> Path:
    """The pkgIndex.tcl in a build folder."""
    found = list(build.rglob("pkgIndex.tcl"))
    if len(found) != 1:
        sys.exit(f"Expected one pkgIndex.tcl in {build}, found: {found}")
    return found[0]


def tktable_version(pkg_index: str) -> str:
    """The Tktable version declared by pkgIndex.tcl."""
    match = re.search(r"package ifneeded Tktable (\S+)", pkg_index)
    if not match:
        sys.exit("No 'package ifneeded Tktable <version>' in pkgIndex.tcl")
    return match.group(1)


def main() -> None:
    tcl8_build, tcl9_build, out = (Path(arg) for arg in sys.argv[1:4])
    source = Path(__file__).resolve().parent.parent / "tktable-src"

    pkg_index = find_pkg_index(tcl8_build).read_text(encoding="utf-8")
    if pkg_index != find_pkg_index(tcl9_build).read_text(encoding="utf-8"):
        sys.exit("The pkgIndex.tcl of the Tcl 8 and Tcl 9 builds differ")

    folder = out / f"Tktable{tktable_version(pkg_index)}"
    shutil.rmtree(folder, ignore_errors=True)
    folder.mkdir(parents=True)

    for build in (tcl8_build, tcl9_build):
        shutil.copy2(find_library(build), folder)
    (folder / "pkgIndex.tcl").write_text(pkg_index, encoding="utf-8")
    shutil.copy2(source / "library" / "tkTable.tcl", folder)
    shutil.copy2(source / "license.txt", folder)

    for path in sorted(folder.iterdir()):
        print(path)


if __name__ == "__main__":
    main()
