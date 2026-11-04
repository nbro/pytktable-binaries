"""Builds the wheel of one platform from a compiled Tktable folder (see scripts/build-*).

Usage: python scripts/make_wheel.py <folder with Tktable<version>> <platform tag>

Example: python scripts/make_wheel.py out manylinux_2_28_x86_64

The libraries don't depend on the Python version, so the wheel is tagged py3-none-<platform>:
one wheel per platform works with every Python 3.
"""

import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PACKAGE = ROOT / "tktable_binaries"
DIST = ROOT / "dist"


def copy_into_package(compiled: Path) -> None:
    """Replace the Tktable folder in the package with the compiled one."""
    for old in PACKAGE.glob("Tktable*"):
        shutil.rmtree(old)

    folders = list(compiled.glob("Tktable*"))
    if len(folders) != 1:
        sys.exit(f"Expected one Tktable<version> folder in {compiled}, found: {folders}")
    shutil.copytree(folders[0], PACKAGE / folders[0].name)


def build_wheel() -> Path:
    """Build the wheel with Poetry, into a clean dist/<temporary> folder."""
    out = DIST / "tmp"
    shutil.rmtree(out, ignore_errors=True)
    subprocess.run(["poetry", "build", "--format", "wheel", "--output", out], cwd=ROOT, check=True)
    return next(out.glob("*.whl"))


def retag(wheel: Path, platform: str) -> None:
    """Mark the wheel as platform-specific, for one platform, into dist/.

    Poetry builds a pure-Python wheel (py3-none-any), so unpack it, rewrite its WHEEL file, and
    pack it again: the new file name comes from the new tag.
    """
    unpacked = wheel.parent / "unpacked"
    subprocess.run([sys.executable, "-m", "wheel", "unpack", "--dest", unpacked, wheel], check=True)

    wheel_file = next(unpacked.glob("*/*.dist-info/WHEEL"))
    lines = [
        line
        for line in wheel_file.read_text(encoding="utf-8").splitlines()
        if not line.startswith(("Tag:", "Root-Is-Purelib:"))
    ]
    lines += ["Root-Is-Purelib: false", f"Tag: py3-none-{platform}"]
    wheel_file.write_text("\n".join(lines) + "\n", encoding="utf-8")

    subprocess.run(
        [sys.executable, "-m", "wheel", "pack", "--dest-dir", DIST, next(unpacked.iterdir())],
        check=True,
    )
    shutil.rmtree(wheel.parent)


def main() -> None:
    compiled, platform = Path(sys.argv[1]), sys.argv[2]
    copy_into_package(compiled)
    retag(build_wheel(), platform)


if __name__ == "__main__":
    main()
