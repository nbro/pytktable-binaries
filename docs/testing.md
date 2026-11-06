# Testing

The `Test` workflow (`.github/workflows/test.yml`) installs the built wheels and runs pytktable's
tests with `TKTABLE_REQUIRED=1`, so they fail if Tktable can't be loaded:

- on GitHub's Linux, macOS and Windows runners, with the python.org builds of Python 3.11, 3.14
  and `3.x` (the latest stable Python);
- in Docker containers of Linux distributions, with their own Python and Tcl/Tk
  (`scripts/test-distro.sh`):

| Distribution | Architectures | X server |
|---|---|---|
| Debian | x86_64, ARM64 | Xvfb |
| Fedora | x86_64 | Xvfb, Xwayland |
| CentOS Stream 10 | x86_64 | Xwayland |
| Rocky Linux 9 | x86_64 | Xvfb |
| openSUSE Tumbleweed | x86_64 | Xvfb |
| Kali Linux | x86_64 | Xvfb |
| Alpine (musl) | x86_64, ARM64 | Xvfb |

## X servers on Linux

On Linux, Tk draws its windows with X11, so the tests need an X server, even without a screen:

- **X11** is the older display system: an X server owns the screen, and apps, like Tk, are its
  clients.
- **Wayland** replaces it: one program, the *compositor* (e.g. GNOME's Mutter, KDE's KWin or
  Weston), draws the windows and controls the screen and input. Ubuntu, Fedora and RHEL use it
  by default.
- **Xwayland** is an X server that runs on a Wayland compositor, for X11 apps. It can't run on its
  own.

Tk has no native Wayland support yet: on Wayland desktops, Tk apps run through Xwayland. Work on
it has started in a `wayland` branch of Tk, likely for Tk 9.2
([Tk ticket 3f58c0871c](https://core.tcl-lang.org/tk/tktview/3f58c0871c0be6b457cb)), and
Python's developers recommend Xwayland until then
([discussion](https://discuss.python.org/t/feature-request-wayland-support-for-tkinter/75198)).
If Tk gets native Wayland support, check that Tktable works with it too, as it may use X11
directly.

So `scripts/test-distro.sh` runs the tests with one of these, set by `DISPLAY_SERVER`:

- `xvfb` (default): [Xvfb](https://www.x.org/releases/current/doc/man/man1/Xvfb.1.xhtml), a
  standalone X server that draws into memory, started by `xvfb-run`;
- `xwayland`: Xwayland on a headless Wayland compositor, started by `xwfb-run`, from
  [xwayland-run](https://www.mankier.com/1/xwfb-run). It's what Tk uses on Wayland desktops.

RHEL 10 and its rebuilds, e.g. CentOS Stream 10, have no Xvfb anymore, and Red Hat won't add it
back, even to EPEL
([Red Hat bug 2325923](https://bugzilla.redhat.com/show_bug.cgi?id=2325923)), so they're tested
with Xwayland only. Fedora is tested with both. The other distributions use Xvfb: Tk speaks the
same X11 protocol to both, so testing both everywhere would mostly repeat the same tests.

## Flaky tests on Windows

Sometimes a Windows test job fails because Tktable cannot be loaded right after it was installed,
most likely while the antivirus of GitHub's runner is still scanning the new files. The error is
then one of:

- `couldn't read file ...\pkgIndex.tcl: no such file or directory`;
- `attempt to provide package Tktable ... failed: no version of package Tktable provided`.

pytktable's tests already try to load Tktable 3 times. When it still fails, they print a
`Tktable load report` at the end of the test output: the error of every try, Tcl's stack trace,
what Tcl knows about Tktable and which files are in `TKTABLE_LIBRARY`. The same report is printed
when Tktable is loaded only after a failed try, so flakes are visible even in passing jobs.

If the same job passes in other runs, it's a flake: rerun only the failed jobs, either from the
run's page in the Actions tab (`Re-run jobs` > `Re-run failed jobs`) or with:

```shell
gh run rerun <run-id> --failed
```

A run can be rerun up to 30 days after it started. If a job fails the same way again and again,
it's not a flake: read the report.
