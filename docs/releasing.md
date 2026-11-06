# Releasing

1. Set `version` in `pyproject.toml` (see [Versioning](versioning.md)) and commit it to `main`.
2. Push a tag with the same version, e.g. `2.12.2`.

The `Release` workflow (`.github/workflows/release.yml`) then checks that the tag and the version
are equal, builds and tests the wheels, publishes them to PyPI with
[Trusted Publishing](https://docs.pypi.org/trusted-publishers/) (no API token), and creates a
GitHub release with them.
