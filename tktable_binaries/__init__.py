"""Prebuilt Tktable, the Tcl/Tk table widget, for pytktable.

This package contains no Python API apart from :func:`library_dir`: it ships Tktable compiled for
Tcl/Tk 8.6 and 9.0, in a ``Tktable<version>`` folder that Tcl finds through its ``auto_path``.
"""

from pathlib import Path


def library_dir() -> Path:
    """Return the folder to add to Tcl's ``auto_path`` so that Tcl can find Tktable.

    Tcl also searches the subfolders of each ``auto_path`` folder, where the ``pkgIndex.tcl``
    of Tktable is.
    """
    return Path(__file__).parent
