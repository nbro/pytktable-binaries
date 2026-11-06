# Versioning and releasing

## Versioning

The version is the version of Tktable it contains, plus a fourth number for the releases of this
package with the same Tktable (e.g. a build fix or a new platform):

| Change                                  | Version                  |
|-----------------------------------------|--------------------------|
| First release with Tktable 2.12.2       | `2.12.2`                 |
| A fix of this package, same Tktable     | `2.12.2.1`, `2.12.2.2`   |
| Tktable 2.12.3                          | `2.12.3`                 |

[PEP 440](https://peps.python.org/pep-0440/) allows any number of version components, so
`2.12.2` < `2.12.2.1` < `2.12.3`.

## Releasing

1. Set `version` in `pyproject.toml` (see [Versioning](#versioning)) and commit it to `main`.
2. Push a tag with the same version, e.g. `2.12.2`.

The `Release` workflow (`.github/workflows/release.yml`) then checks that the tag and the version
are equal, builds and tests the wheels, publishes them to PyPI with
[Trusted Publishing](https://docs.pypi.org/trusted-publishers/) (no API token), and creates a
GitHub release with them.
