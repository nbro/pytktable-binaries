# Versioning

The version is the version of Tktable it contains, plus a fourth number for the releases of this
package with the same Tktable (e.g. a build fix or a new platform):

| Change                                  | Version                  |
|-----------------------------------------|--------------------------|
| First release with Tktable 2.12.2       | `2.12.2`                 |
| A fix of this package, same Tktable     | `2.12.2.1`, `2.12.2.2`   |
| Tktable 2.12.3                          | `2.12.3`                 |

[PEP 440](https://peps.python.org/pep-0440/) allows any number of version components, so
`2.12.2` < `2.12.2.1` < `2.12.3`.
