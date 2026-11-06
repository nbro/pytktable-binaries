# Tktable

## Where Tktable comes from

Tktable was created by Roland King in 1994, and then developed and maintained for many years by
Jeffrey Hobbs, with its releases on [SourceForge](https://sourceforge.net/projects/tktable/), the
last one being 2.10, from 2008. The wheels are built from a release tag of
[bohagan1/TkTable](https://github.com/bohagan1/TkTable), by Brian O'Hagan, which continues it and
seems to be the only version that is still maintained. Other, more recent versions than
SourceForge's are listed below, as of November 2026. They're developed independently, so a fix in
one isn't necessarily in the others.

| Repository | Latest version | Last commit | Notes |
|---|---|---|---|
| [bohagan1/TkTable](https://github.com/bohagan1/TkTable) | 2.12.2 (tag `tktable-2-12-2`) | 2026 | Used for these wheels, and by Magicsplat Tcl/Tk (Tktable 2.12.1 in its releases 1.18.0 and 2.0.7) |
| [chpock/tktable](https://github.com/chpock/tktable) | 2.11.1 (tag `v2.11.1`) | 2024 | |
| [wjoye/tktable](https://github.com/wjoye/tktable) | 2.10.8 (tag `v2.10.8`) | 2023 | |
| [apnadkarni/tktable](https://github.com/apnadkarni/tktable) | 2.11 (tag `magicsplat-1.8.0`) | 2017 | Obsolete: [Magicsplat Tcl/Tk](https://magicsplat.com/tcl-installer) used it, but [switched to bohagan1/TkTable](https://github.com/bohagan1/TkTable/issues/17#issuecomment-6676401009) |

Because of these differences, Tktable from other sources (e.g. Linux distributions, MacPorts,
older Magicsplat releases) can behave slightly differently from the one in these wheels, e.g. in the default
colors of the title rows.

## Why a separate package

Python packages are distributed as wheels, i.e. zip files that `pip` installs. pytktable is pure
Python, so it needs a single wheel that works everywhere, while compiled code needs one wheel per
operating system and architecture. Keeping the compiled part in this separate package, built in
this separate repo, doesn't clutter pytktable's repo, and `pip install "pytktable[binary]"`
installs both.
psycopg 3 also ships its compiled part as a separate package, `psycopg-binary`, which its `binary`
extra installs (see its
[pyproject.toml](https://github.com/psycopg/psycopg/blob/master/psycopg/pyproject.toml)), but it
builds it in the same repo as the rest of psycopg.
