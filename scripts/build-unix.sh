#!/usr/bin/env bash
# Compiles Tktable on Linux or macOS, once against Tcl/Tk 8.6 and once against Tcl/Tk 9.0, and
# puts both libraries, with the pkgIndex.tcl that loads the right one, in one folder.
#
# Usage: scripts/build-unix.sh <output folder>
# On macOS, set CFLAGS (e.g. "-arch x86_64 -arch arm64") and MACOSX_DEPLOYMENT_TARGET first.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
out="$1"
build="$root/build"
jobs="$(nproc 2> /dev/null || getconf _NPROCESSORS_ONLN)"

# shellcheck source-path=SCRIPTDIR source=../versions.env
source "$root/versions.env"

# Tk 9 packs its scripts into a zip (zipfs) with the zip command, which manylinux lacks; only Tk's
# headers and stub library are needed, so skip it. Tk 8.6 ignores this option.
tk_options=(--disable-zipfs)

# Tk on macOS must use Aqua, the native windowing system, like the Tk of Python and Homebrew.
if [[ "$(uname)" == "Darwin" ]]; then
    tk_options+=(--enable-aqua)
fi

# Clones Tcl and Tk at the given tag, and compiles them in build/<tag>.
build_tcl_tk() {
    local tag="$1"
    local dir="$build/$tag"

    for name in tcl tk; do
        if [[ ! -d "$dir/$name" ]]; then
            git clone --quiet --depth 1 --branch "$tag" \
                "https://github.com/tcltk/$name" "$dir/$name"
        fi
    done

    (cd "$dir/tcl/unix" && ./configure --quiet && make --silent -j "$jobs")

    (cd "$dir/tk/unix" && ./configure --quiet --with-tcl="$dir/tcl/unix" "${tk_options[@]}" &&
        make --silent -j "$jobs")
}

# Compiles Tktable against the Tcl and Tk of the given tag, in build/<tag>/tktable.
build_tktable() {
    local tag="$1"
    local dir="$build/$tag"

    rm -rf "$dir/tktable"
    mkdir -p "$dir/tktable"

    (cd "$dir/tktable" &&
        "$root/tktable-src/configure" --quiet \
            --with-tcl="$dir/tcl/unix" --with-tk="$dir/tk/unix" "${tk_options[@]}" &&
        make --silent -j "$jobs")
}

# Tktable's Makefile rule that writes manifest.uuid is broken (a stray "@" inside a shell command),
# so write that file ourselves.
echo "git-$(git -C "$root/tktable-src" rev-parse HEAD)" > "$root/tktable-src/manifest.uuid"

for tag in "$TCL8_TAG" "$TCL9_TAG"; do
    build_tcl_tk "$tag"
    build_tktable "$tag"
done

python3 "$root/scripts/collect.py" "$build/$TCL8_TAG/tktable" "$build/$TCL9_TAG/tktable" "$out"
