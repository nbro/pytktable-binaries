#!/bin/sh
# Runs pytktable's tests with the wheels in wheels/, inside a container of a Linux distribution,
# with that distribution's own Python and Tk.
#
# Usage, in the container, from this repository's root, with pytktable checked out in pytktable/:
#   sh scripts/test-distro.sh
set -eu

if command -v dnf > /dev/null; then
    dnf install -y python3 python3-tkinter xorg-x11-server-Xvfb
elif command -v apk > /dev/null; then
    # Tk needs at least one font.
    apk add --no-cache python3 python3-tkinter xvfb-run font-dejavu
else
    echo "Unsupported distribution: neither dnf nor apk found" >&2
    exit 1
fi

python3 -m venv /venv
/venv/bin/pip install --no-index --find-links wheels/ pytktable-binaries
/venv/bin/pip install ./pytktable pytest

# From pytktable's checkout: in this repository's root, Python would import the source folder
# tktable_binaries/ (without the compiled Tktable) instead of the installed package.
cd pytktable

TKTABLE_LIBRARY="$(/venv/bin/python -c "import tktable_binaries as t; print(t.library_dir())")"
export TKTABLE_LIBRARY
export TKTABLE_REQUIRED=1

xvfb-run -a /venv/bin/python -m tktable
xvfb-run -a /venv/bin/python -m pytest -v
