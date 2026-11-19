# tmux-pomodoro-revamped

Guidance for anyone, human or agent, changing tmux-pomodoro-revamped. What it is and how to use it lives in [README.md](README.md).

[FAMILY.md](FAMILY.md) holds everything this plugin shares with the rest of the tmux-revamped family, and it is the same in every member. This file holds only what is exclusive to tmux-pomodoro-revamped, under the same headings as the agent guide of every member. Read both before changing anything; a rule that would serve the other members goes into [`FAMILY.md`](FAMILY.md) instead of here.

## Layout

| Path | Holds |
|:-----|:------|
| [`pomodoro-revamped.tmux`](pomodoro-revamped.tmux) | The entry point TPM runs: it runs `bin/pomodoro-revamped apply` |
| [`bin/pomodoro-revamped`](bin/pomodoro-revamped) | The command: `apply`, `list`, `toggle`, `skip`, `restart`, `cancel`, `status`, `doctor`, `version`, `help` and the menu. `apply`, `status` and the actions run without loading the interface modules |
| [`lib/pomodoro.sh`](lib/pomodoro.sh) | Reading the settings and the timer's state, the phase arithmetic, the segment, the phase change with its hooks and alerts, the bindings and the actions |
| [`lib/state.sh`](lib/state.sh) | Every global, including `POMODORO_REVAMPED_SETTINGS`, the table of setting names and defaults, and `POMODORO_REVAMPED_LIVE`, the names of the state options |
| [`lib/core.sh`](lib/core.sh) | The version |
| [`lib/`](lib) | Every other file is the shared library, identical in every member |
| [`test/pomodoro.bats`](test/pomodoro.bats), [`test/plan.bats`](test/plan.bats), [`test/commands.bats`](test/commands.bats) | The library, the bindings and every command, against a stand-in tmux from [`test/pomodoro_helpers.bash`](test/pomodoro_helpers.bash) that keeps options in a file, applies each `set-option` it receives and answers the phase claim, with a stand-in `date` for the clock |
| [`test/entrypoint.bats`](test/entrypoint.bats), [`test/keys.bats`](test/keys.bats) | The plugin on a private tmux server, with every key, each menu item and the help popup pressed through a second tmux attached to it; both share [`test/server_helpers.bash`](test/server_helpers.bash) |
| [`screens/`](screens) | The tapes and the recording's tmux config, which sets the keys the tapes press |

## Names

- Settings are the tmux options `@pomodoro_revamped_<setting>` listed in `POMODORO_REVAMPED_SETTINGS`, the long options with dashes, such as `--show-progress`, and the environment variables `POMODORO_REVAMPED_<SETTING>`.
- The timer's state is `@pomodoro_revamped_state`, `_start`, `_paused_total`, `_paused_at`, `_last_phase`, `_warned`, `_week_counts`, `_week_day` and `_transition_claim`. `status` also publishes `@pomodoro_revamped_status`, `_phase`, `_remaining`, `_fraction`, `_week` and `_today`. None of them is a setting.
- The placeholder is `#{pomodoro_status}`.
- The version constant is `POMODORO_REVAMPED_VERSION`.
- An internal number of seconds is named `POMODORO_REVAMPED_WORK_SECONDS`, `_BREAK_SECONDS` or `_LONG_SECONDS`: `POMODORO_REVAMPED_WORK` and its siblings are the settings' environment names, and the state file assigns every global outright.
- The command's own functions and the library's never share a name, because the command is sourced after the library and would replace it.

## Behaviour

- `apply` reads every setting and every state option with one `tmux display-message` call and one `env` read, reads the prefix table once, and sends every binding and the replaced status strings in one tmux call. When that call fails, it sends each command alone, so one invalid key leaves the others bound and `apply` exits 1.
- `#{pomodoro_status}` in `status-left` or `status-right` becomes `#(<tool> status)`, with the tool's path quoted for a shell and every `#` and `%` doubled, since tmux reads the status line both as a format and as a time format. A string without the placeholder is not written, so loading twice changes nothing. No background process runs: the countdown advances once per `status-interval`.
- `status` makes one tmux read and one chained write per refresh. An idle timer writes nothing, except once to clear what the last run published.
- A key set to `off` binds nothing. Only the default toggle key, `M-s`, is skipped when someone else holds it, and `doctor` names it; a key the person names is bound whoever holds it. Two actions set to one key bind it for the first and the clash is named.
- The menu key is bound to `display-menu` itself, so opening the menu starts no process; each item runs the tool with its action. The help key opens the help page in `less`, in a popup; where `less` is not installed the popup prints the page and waits for Enter, since a popup whose command ends closes at once.
- A setting `apply` got from the command line or the environment rides, as an option, on every binding and on the status call; `POMODORO_REVAMPED_CARRIED` lists the ones that ride.
- The entry point clears every inherited `REVAMPED_` variable except the test switches, and every `POMODORO_REVAMPED_*_LOADED` guard; every other global is assigned outright in the state file.

## Domain rules

- The timer stores the epoch second it started and the seconds it spent paused. Each refresh subtracts both from the clock and walks the round of work periods, short breaks and the long break to find the phase and the seconds left. Skip moves the start back by the seconds left; restart moves it forward by the seconds spent.
- Several clients refresh the status line, so several refreshes can notice the same phase change. One conditional command, `if-shell -F` on the last phase seen, claims it, and only the claiming refresh counts the work period, runs the hooks and sends the alerts.
- A finished work period is added to a ring of seven counts, Sunday first, and the days gone by since the last one are emptied first. A gap of a week or a clock that went back empties the whole ring.
- Hooks run through `run-shell -b`, so a slow command never holds the status line. Quiet hours keep the bell and the notifications back; hooks still run.
- The arithmetic runs in the shell with no fork. A number read from an option has its leading zeros dropped, since the shell would read `08` as octal, and junk takes the default.
- Rounds are capped at 100 and the progress bar at 200 cells, so a setting cannot make a refresh loop without bound.
- An argument that ends in `;` is sent as `\;`: tmux reads a bare trailing semicolon in an argument as a command separator, which would split a hook such as `notify-send done;` out of its command.
- The command list keeps an empty argument, which `set-option` needs to clear an option and `display-menu` needs for an item with no key, as the marker in `POMODORO_REVAMPED_EMPTY`; only an empty line ends a command.

## Release

- `POMODORO_REVAMPED_VERSION` in [`lib/core.sh`](lib/core.sh) holds the version. Nobody edits it by hand.
- After a green `ci` run on `main`, [`release.yml`](.github/workflows/release.yml) runs semantic-release: a `feat` or `fix` since the last tag publishes a release, [`set-version.sh`](.github/scripts/set-version.sh) stamps the constant, and the notes go into [`CHANGELOG.md`](CHANGELOG.md).

## Gaps against FAMILY.md

As of 2026-11-17, none.
