# Platforms

Each wheel contains Tktable compiled for Tcl/Tk 8.6 and for Tcl/Tk 9.0; Tcl loads the one matching
the Tcl/Tk of the Python that runs it. The libraries don't depend on the Python version, so one
wheel per platform works with every Python 3.

| Platform                           | Wheel tags                                        | Tested on (CI)                         |
|------------------------------------|---------------------------------------------------|----------------------------------------|
| Linux with glibc (most distros)    | `manylinux_2_28_x86_64`, `manylinux_2_28_aarch64` | Ubuntu 24.04, Debian (x86_64, ARM64), Fedora, CentOS Stream 10, Rocky Linux 9, openSUSE Tumbleweed, Kali Linux (x86_64) |
| Linux with musl (e.g. Alpine)      | `musllinux_1_2_x86_64`, `musllinux_1_2_aarch64`   | Alpine (x86_64, ARM64)                 |
| macOS 11+, Intel and Apple silicon | `macosx_11_0_universal2`                          | macOS 15 (Intel, Apple silicon)        |
| Windows                            | `win_amd64`, `win32`, `win_arm64`                 | Windows Server 2025 (x64, x86), Windows 11 (ARM64) |

## Python and Tcl/Tk versions

Which Tcl/Tk a Python uses depends on how it was installed, and the wheels work with both 8.6 and
9.0, so you don't need to care about it. For example:

| Python                             | Tcl/Tk                                            |
|------------------------------------|---------------------------------------------------|
| 3.11 to 3.13, python.org installers for Windows | 8.6                                  |
| 3.14 and newer, python.org installers for Windows | 9.0                                |
| Linux distributions                | the distribution's, e.g. 8.6 on Ubuntu 24.04 and 9.0 on Fedora |

## Possible future platforms

- Linux on other CPUs: 32-bit ARM (`armv7l`, older Raspberry Pi OS), `ppc64le`, `s390x`,
  `riscv64`. They would be compiled under emulation, which is slow.
- Linux with glibc older than 2.28 (`manylinux2014`): only end-of-life distributions, e.g. CentOS 7
  (glibc 2.17). RHEL, CentOS Stream, Rocky Linux and AlmaLinux 8 and newer have glibc 2.28 or
  newer, so they already use the `manylinux_2_28` wheels.
- macOS older than 11.
- PyPy: the wheels don't depend on the Python version, so they should already work; it would need
  a test job.
