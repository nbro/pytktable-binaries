# Guidelines for contributors and AI agents

These apply to everyone changing this repository, people and AI coding agents alike.

Read [README.md](README.md) first: it explains what this repository is, how the wheels are built
and tested, the versioning, when to change what ("Maintenance"), and how to release.

## Rules for the build

- Build Tktable only from a release tag of `tktable-src`, never from a branch, so builds are
  reproducible. Pin Tcl/Tk sources by tag in `versions.env`.
- Every platform gets two builds, against Tcl/Tk 8.6 and 9.0, in one `Tktable<version>` folder
  (`scripts/collect.py`). Keep both working.
- Don't commit build outputs (`build/`, `out/`, `dist/`, `tktable_binaries/Tktable*/`) or logs.
- Don't modify `tktable-src`. Work around its bugs in the scripts, with a comment that says why,
  and report them upstream (https://github.com/bohagan1/TkTable).
- A change to the build must keep the `Test` workflow green on every platform: it runs pytktable's
  tests with `TKTABLE_REQUIRED=1` against the built wheels.

## Releases

Only the maintainer tags, pushes tags, and publishes releases ([Releasing](README.md#releasing)).
AI agents must not.

## Readability first

- Separate logical steps with blank lines: inside functions, between workflow steps, between
  sections of a config file.
- Write small functions that each do one thing, with clear names, without abstractions that don't
  pay for themselves.
- Keep lines at most 100 characters (120 in YAML).
- Put comments on their own line above the code they explain, and explain *why*, not *what*.
- Don't put long scripts inline in GitHub workflows: move them to `scripts/`.
- One reusable workflow per step (`compile-*.yml`, `test.yml`), called by `build.yml`.

## Tools

- Use reliable, stable tools. No betas, and no new tool when an existing one does the job.
- Use LF line endings for every file (`.gitattributes`).
- Run `poetry run pre-commit run --all-files` before pushing (see "Development" in `README.md`).

## Commits

- Start the subject with an imperative verb, as if completing "This commit will ...": "Fix ...",
  "Add ...", not "Fixed ..." or "Fixes ...".
- Keep the subject at most 72 characters, without a final period. Explain *why* in the body if it
  isn't obvious.

## AI agents

- `.claude/settings.json` lets Claude Code read files without asking, asks before every other
  action (commands, edits, web access), and forbids destructive or publishing commands.
- Don't push, force-push, delete branches, tags, releases or workflow runs, or change repository
  settings: ask the maintainer to do it.
