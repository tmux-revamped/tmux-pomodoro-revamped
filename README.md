<div align="center">

<h1>tmux-pomodoro-revamped</h1>

**A Pomodoro timer in your tmux status bar, with zero temp files: all state lives in tmux options.**

[![Tests](https://github.com/tmux-revamped/tmux-pomodoro-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/tmux-revamped/tmux-pomodoro-revamped/actions/workflows/tests.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE) [![Version](https://img.shields.io/badge/version-1.2.0-blue.svg)](CHANGELOG.md)

</div>

**work + breaks** · **no temp files** · **tmux 1.9 to 3.5** · **94** tests · **95%+** coverage

A Pomodoro timer that counts down work and break intervals in the status bar. The whole timeline is computed from a single start epoch, so there is **no temp file** anywhere (the original keeps seven in `/tmp`), nothing to clean up, and no `/tmp` collision between users. State lives entirely in tmux server options, and the phase is computed on demand, so the render never spawns a background process.

Built from [tmux-plugin-template](https://github.com/tmux-revamped/tmux-plugin-template).

<table>
<tr>
<td><strong>No temp files</strong><br>The timeline is pure math over a start epoch. State is in tmux options, nothing on disk.</td>
<td><strong>Full cycle</strong><br>Work, short breaks, and a long break after every N intervals, then it repeats.</td>
</tr>
<tr>
<td><strong>Pause and resume</strong><br>Paused time is tracked exactly, so the countdown is correct after any number of pauses.</td>
<td><strong>Notifications</strong><br>A desktop notification on each phase change, via osascript on macOS or notify-send on Linux.</td>
</tr>
</table>

## Status placeholder

Put `#{pomodoro_status}` in your status line:

```tmux
set -g status-right '#{pomodoro_status} | %H:%M'
```

It renders the phase color, the `MM:SS` countdown, and `[interval/total]`, for example `23:20 [1/4]`. It is empty when no timer is running.

Each render also writes the same segment to the `@pomodoro_status` tmux option, so a theme or another plugin can read the current value with `#{@pomodoro_status}` without invoking the script.

Each render also publishes machine-readable options for sibling plugins and themes: `@pomodoro_phase` (work, break, or long_break), `@pomodoro_remaining` (seconds left), `@pomodoro_fraction` (percent elapsed), `@pomodoro_week` (a glyph-free weekly focus sparkline), and `@pomodoro_today` (work periods completed today). The weekly tally is a bounded 7-slot ring kept in tmux options, so there is still no temp file.

## Controls

| Key | Action |
|-----|--------|
| `prefix + p` | start, or pause/resume a running timer |
| `prefix + P` | cancel the timer |
| `prefix + _` | skip to the next phase |
| `prefix + R` | restart the current phase |
| `prefix + o` | open the control menu |
| `prefix + ?` | open the help popup |

All keys are configurable.

## Install

With [TPM](https://github.com/tmux-plugins/tpm), add to `~/.tmux.conf`:

```tmux
set -g @plugin 'tmux-revamped/tmux-pomodoro-revamped'
```

Then press `prefix + I`, and add `#{pomodoro_status}` to your status line.

## Configuration

| Option | Default | Meaning |
|--------|---------|---------|
| `@pomodoro_revamped_work` | `25` | work minutes |
| `@pomodoro_revamped_break` | `5` | short break minutes |
| `@pomodoro_revamped_long_break` | `15` | long break minutes |
| `@pomodoro_revamped_intervals` | `4` | work periods before a long break |
| `@pomodoro_revamped_show_interval` | `1` | set to `0` to hide the `[n/N]` counter |
| `@pomodoro_revamped_notifications` | `1` | set to `0` to disable desktop notifications |
| `@pomodoro_revamped_on_work` | unset | shell command run when a work phase begins |
| `@pomodoro_revamped_on_break` | unset | shell command run when a short break begins |
| `@pomodoro_revamped_on_long_break` | unset | shell command run when a long break begins |
| `@pomodoro_revamped_show_progress` | `0` | set to `1` to prepend an ASCII progress bar |
| `@pomodoro_revamped_progress_width` | `8` | progress bar width in cells |
| `@pomodoro_revamped_bar_filled` | `#` | filled progress-bar glyph |
| `@pomodoro_revamped_bar_empty` | `-` | empty progress-bar glyph |
| `@pomodoro_revamped_show_finish` | `0` | set to `1` to append `ends HH:MM` |
| `@pomodoro_revamped_show_goal` | `0` | set to `1` to append the daily `done/goal` counter |
| `@pomodoro_revamped_goal` | `6` | daily focus-session goal |
| `@pomodoro_revamped_warn_seconds` | `0` | seconds before a phase ends to warn once; `0` disables |
| `@pomodoro_revamped_quiet_hours` | unset | window like `22:00-07:00` that suppresses alerts |
| `@pomodoro_revamped_bell` | `0` | set to `1` to ring the terminal bell on a phase change |
| `@pomodoro_revamped_on_cycle` | unset | shell command run when a long break (cycle) begins |
| `@pomodoro_revamped_on_warn` | unset | shell command run at the end-of-phase warning |
| `@pomodoro_revamped_restart_key` | `R` | restart-phase key |
| `@pomodoro_revamped_menu_key` | `o` | control-menu key |
| `@pomodoro_revamped_help_key` | `?` | help-popup key |
| `@pomodoro_revamped_toggle_key` | `p` | start / pause / resume key |
| `@pomodoro_revamped_cancel_key` | `P` | cancel key |
| `@pomodoro_revamped_skip_key` | `_` | skip-phase key |
| `@pomodoro_revamped_{work,break,long_break}_color` | red, green, blue | per-phase color |
| `@pomodoro_revamped_{work,break,long_break}_icon` | empty | per-phase glyph, for example a Nerd Font tomato or coffee cup |
| `@pomodoro_revamped_pause_text` | ` paused` | text appended while paused |

## Compatibility

Works on every tmux version TPM supports, 1.9 and up, on Linux (x86_64 and arm64) and macOS (Intel and Apple Silicon). Notifications use `osascript` on macOS and `notify-send` on Linux when present; the timer itself needs neither.

## Development

```bash
make test    # bats suite
make lint    # shellcheck
make coverage  # kcov line coverage on Linux
```

The timer math lives in [`src/lib/pomodoro/pomodoro.sh`](src/lib/pomodoro/pomodoro.sh) as pure functions, the full work/break/long-break timeline as arithmetic over the elapsed seconds, validated with fixtures and no real clock.

## License

[MIT](LICENSE), copyright Gustavo Franco.

<!-- family:begin -->

## The tmux-revamped family

This plugin is one member of the tmux-revamped family. Every member carries the
same contract in [`FAMILY.md`](FAMILY.md), the same tooling under `family/`, and
the same shared library, all held byte-identical by a checksum manifest. They are
built to be installed together: no member claims a key or a tmux option that
another member claims.

A defect found in one member is hunted across all of them before the fix is
called done. That obligation is written into the contract rather than left to
memory, and `family/bin/sweep` is how it is discharged.

| Member | What it does |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | Edit your tmux config, save, and watch it reload itself, no key, no command |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | Battery status for your tmux status bar, without ever blocking the status render |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | Every connected Bluetooth device and its battery in your tmux status bar, without blocking the render |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | CPU load, temperature, and frequency in your tmux status bar, without ever blocking the render |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | Disk usage for your tmux status bar, without ever blocking the status render |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | Fuzzy-grab any URL, path, or word off the screen and paste it, pure shell, no Python |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | Jump to any session, window, or pane, or kill it, from one fzf popup |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | Git repository status in your tmux status bar, without ever blocking the render |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | GPU load, temperature, frequency, and memory for your tmux status bar |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | Current Kubernetes context and namespace in your tmux status bar, async, kubectl-free, never blocking |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | Launch any TUI app in a popup or a window, scoped to the current pane's directory, with one configurable bindi |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | Capture any pane to a file: live logging, full scrollback, or a one-shot screenshot |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | Now playing in your tmux status bar, without ever blocking the status render |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | Network throughput in your tmux status bar, without ever blocking the render |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | Standard pane and window management bindings for tmux, version aware, vim friendly, and fully configurable |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | One plugin that captures every session, window, pane, layout, and working |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | A template for building non-blocking tmux status plugins |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | **this plugin**, A Pomodoro timer in your tmux status bar, with zero temp files: all state lives in tmux options |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | RAM usage for your tmux status bar, without ever blocking the status render |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | Mouse wheel that does the right thing: scroll the app directly, copy-mode everywhere else. No app names to con |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | Sensible tmux defaults that normalize behavior across every tmux version, OS, and terminal, without clobbering |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | --- |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | Local clock and world clocks in your tmux status bar, without ever blocking the render |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | Weather in your tmux status bar, fetched in the background so the render never waits on the network |

### Checking an installation

With every member on disk, one command reports any conflict between them:

```sh
family/bin/doctor --live
```

It reads each member and the running tmux server, and reports duplicate keys,
duplicate status placeholders, options outside the naming grammar, and any
member whose contract version has fallen behind.

<!-- family:end -->
