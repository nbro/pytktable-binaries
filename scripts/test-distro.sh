#!/bin/sh
# Runs pytktable's tests with the wheels in wheels/, inside a container of a Linux distribution,
# with that distribution's own Python and Tk.
#
# Usage, in the container, from this repository's root, with pytktable checked out in pytktable/:
#   sh scripts/test-distro.sh
set -eu

# The Python to use: the distribution's python3, unless it's older than pytktable requires.
PYTHON=python3

# The X server the tests' Tk windows use: "xvfb" (Xvfb, a standalone X server in memory) or
# "xwayland" (Xwayland on a headless Wayland compositor, started by xwfb-run from xwayland-run).
# Tk has no native Wayland support, so on Wayland desktops it always runs through Xwayland.
DISPLAY_SERVER="${DISPLAY_SERVER:-xvfb}"

if command -v dnf > /dev/null && grep -q '^PLATFORM_ID="platform:el10"' /etc/os-release; then
    # RHEL 10 and its rebuilds (e.g. CentOS Stream 10) have no Xvfb, only Xwayland.
    dnf install -y python3 python3-tkinter xwayland-run
    DISPLAY_SERVER=xwayland
elif command -v dnf > /dev/null && grep -q '^PLATFORM_ID="platform:el9"' /etc/os-release; then
    # RHEL 9 and its rebuilds (e.g. Rocky Linux 9): python3 is 3.9, so use their Python 3.12.
    dnf install -y python3.12 python3.12-tkinter xorg-x11-server-Xvfb
    PYTHON=python3.12
elif command -v dnf > /dev/null && [ "$DISPLAY_SERVER" = xwayland ]; then
    dnf install -y python3 python3-tkinter xwayland-run
elif command -v dnf > /dev/null; then
    dnf install -y python3 python3-tkinter xorg-x11-server-Xvfb
elif command -v zypper > /dev/null; then
    zypper --non-interactive install python3 python3-tk xvfb-run dejavu-fonts
elif command -v apk > /dev/null; then
    # Tk needs at least one font.
    apk add --no-cache python3 python3-tkinter xvfb-run font-dejavu
elif command -v apt-get > /dev/null; then
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        python3 python3-tk python3-venv xvfb xauth fonts-dejavu-core
else
    echo "Unsupported distribution: none of dnf, zypper, apk or apt-get found" >&2
    exit 1
fi

"$PYTHON" -m venv /venv
/venv/bin/pip install --no-index --find-links wheels/ pytktable-binaries
/venv/bin/pip install ./pytktable pytest

# From pytktable's checkout: in this repository's root, Python would import the source folder
# tktable_binaries/ (without the compiled Tktable) instead of the installed package.
cd pytktable

TKTABLE_LIBRARY="$(/venv/bin/python -c "import tktable_binaries as t; print(t.library_dir())")"
export TKTABLE_LIBRARY
export TKTABLE_REQUIRED=1

# Runs a command with an X server for Tk's windows.
with_display() {
    if [ "$DISPLAY_SERVER" = xwayland ]; then
        # The Wayland compositor needs a runtime folder, which containers don't have.
        XDG_RUNTIME_DIR="$(mktemp -d)"
        export XDG_RUNTIME_DIR
        xwfb-run -- "$@"
    else
        xvfb-run -a "$@"
    fi
}

with_display /venv/bin/python -m tktable
with_display /venv/bin/python -m pytest -v
