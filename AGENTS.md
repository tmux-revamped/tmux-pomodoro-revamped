# tmux-pomodoro-revamped

Guidance for anyone, human or agent, changing tmux-pomodoro-revamped. What it is and how to use it lives in [README.md](README.md).

[FAMILY.md](FAMILY.md) holds everything this plugin shares with the rest of the tmux-revamped family, and it is the same in every member. This file holds only what is exclusive to tmux-pomodoro-revamped, under the same headings as the agent guide of every member. Read both before changing anything; a rule that would serve the other members goes into [`FAMILY.md`](FAMILY.md) instead of here.

## Layout

| Path | Holds |
|:-----|:------|
| [`pomodoro-revamped.tmux`](pomodoro-revamped.tmux) | The entry point TPM runs |
| [`src/pomodoro.sh`](src/pomodoro.sh) | The script the placeholders, keys and popups call |
| [`src/lib/pomodoro/`](src/lib/pomodoro) | This member's modules |
| [`src/lib/utils/constants.sh`](src/lib/utils/constants.sh) | This member's constants, including its version |
| [`src/lib/utils/`](src/lib/utils), [`src/lib/tmux/`](src/lib/tmux) | The shared library. Every file there except `constants.sh` is owned by the family |
| [`test/`](test) | The bats suite. `helpers.bash` and `tmux_helpers.bash` are owned; this member's own mocks go in the `_local` files |
| [`family/`](family) | The family tooling, owned |

## Names

- Settings are meant to be tmux options named `@pomodoro_revamped_<setting>`; see the gaps for the ones that are not yet.
- Placeholders include `#{pomodoro_status}`.
- Public functions carry `pomodoro_`; private ones start with `_`.
- The version constant is `POMODORO_REVAMPED_VERSION`.
- Its command-line tool, once it exists, is `pomodoro-revamped`.

## Behaviour

- Runs a Pomodoro timer in the status line that keeps all of its state in tmux options, with no temporary files.
- `M-s` starts or stops the timer.
- `#{pomodoro_status}` becomes a `#()` call, so the countdown advances once per `status-interval`. No background process runs.
- Phase changes send a notification through the shared notifier behind `@pomodoro_revamped_notify`, off by default; the older `@pomodoro_revamped_notifications` applies while the new one is unset.

## Domain rules

- The timer stores the epoch second it started and the seconds it spent paused, and each render derives the phase and the seconds left from them.
- Several clients can notice the same phase change, so one conditional tmux command claims it, and only the claiming render counts the work period, runs the hooks and sends the alerts.
- Hooks run through `run-shell -b`, so a slow command never holds the status line.

## Release

- `POMODORO_REVAMPED_VERSION` in [`src/lib/utils/constants.sh`](src/lib/utils/constants.sh) holds the version. It must equal the newest versioned heading in [`CHANGELOG.md`](CHANGELOG.md) and the README's version badge, which the `version` job in `tests.yml` checks.
- A push to `main` whose version has no tag yet makes the `release` job in `tests.yml` tag `vX.Y.Z` and publish a GitHub release with that changelog section.
- Unreleased changes sit under `## [Unreleased]` in [`CHANGELOG.md`](CHANGELOG.md) until a release is cut.

## Gaps against FAMILY.md

As of 2026-11-15:

- Every script is bash, under `#!/usr/bin/env bash`, not POSIX `sh`, so it is untested under `dash`, `zsh` and BusyBox `sh`.
- The code lives in [`src/`](src) and [`src/lib/`](src/lib); there is no `bin/pomodoro-revamped`, `lib/state.sh` or `lib/core.sh`.
- No `pomodoro-revamped` command with `help`, `version` and `doctor` in the family's form, no man page, no completions and no `manifest.json`.
- No gum interface: no `lib/ui.sh`, `lib/table.awk`, themes or `test/bin/gum`.
- No `screens/` and no recordings in the README.
- The README sections are not the family's order of Quick start, Usage, topic sections, Portability, Development and License.
- Coverage is kcov with a 95 percent floor on Linux, not bashcov at 100 percent merged from macOS and Linux.
- CI tests GNU, BSD and uutils tools in `tests.yml`, but not the six toolsets through `.github/scripts/toolset.sh`, and no shell matrix under `sh`, `dash`, `bash` and `zsh`.
- No golden transcripts, `call.sh`, `run-matrix.sh` or `linux-container.sh`.
- The version is written by hand and released by `tests.yml`; there is no semantic-release, `package.json`, `release.yml` with `recover`, `bot-merge.yml` or Renovate.
- CI is `tests.yml`, `family.yml` and `security.yml`, not `ci.yml`, and no job starts with `step-security/harden-runner`.
- No `.editorconfig`, `.yamllint.yml`, `scripts/check-names.sh` or shfmt; the Makefile has `help`, `test`, `test-unit`, `coverage`, `lint` and `clean`, not the family's targets.
- It publishes `@pomodoro_status`, `@pomodoro_phase`, `@pomodoro_remaining`, `@pomodoro_fraction`, `@pomodoro_today` and `@pomodoro_week`, outside the `@pomodoro_revamped_*` pattern.
