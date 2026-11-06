# Development

Install [Poetry](https://python-poetry.org/docs/#installation), then the dev dependencies and the
[pre-commit](https://pre-commit.com/) hooks, which format and lint Python, YAML, shell and
PowerShell files, and scan for secrets, on every `git commit`:

```sh
poetry install
```

```sh
poetry run pre-commit install
```

The PowerShell hook needs [PowerShell 7](https://learn.microsoft.com/powershell/scripting/install/installing-powershell)
(`pwsh`) and PSScriptAnalyzer. Save PSScriptAnalyzer once inside the repository, in `.tools/Modules`
(not in Git), so nothing changes outside the repository:

```powershell
New-Item -ItemType Directory -Force .tools/Modules
```

```powershell
Save-PSResource PSScriptAnalyzer -Path .tools/Modules -TrustRepository
```

To run all hooks on all files, as the `Checks` workflow does:

```sh
poetry run pre-commit run --all-files
```
