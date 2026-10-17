<div align="center">

# tmux-pomodoro-revamped

<strong>A Pomodoro timer in the tmux status bar that keeps all of its state in tmux options, with no temp files.</strong>

English | [日本語](README.ja.md) | [简体中文](README.zh-Hans.md) | [繁體中文（香港）](README.zh-HK.md)

[![Tests](https://github.com/tmux-revamped/tmux-pomodoro-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/tmux-revamped/tmux-pomodoro-revamped/actions/workflows/tests.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](CHANGELOG.md)

<p align="center">
  <a href="#what-it-does">What it does</a> |
  <a href="#installation">Installation</a> |
  <a href="#usage">Usage</a> |
  <a href="#configuration">Configuration</a> |
  <a href="#key-bindings">Key bindings</a> |
  <a href="#how-it-works">How it works</a>
</p>

</div>

**25 minutes of work, 5-minute breaks, and a 15-minute long break after every 4 work periods. 0 temp files. Tested on macOS and Linux.**

---

## What it does

The timer counts down work periods and breaks in the status bar, then repeats the cycle. It pauses and resumes without losing a second, and on each phase change it can send a desktop notification, ring the terminal bell, and run a shell command of your choice. It also keeps a 7-day tally of finished work periods.

## Requirements

| Requirement | Version or note |
|:------------|:----------------|
| tmux | 3.2 or later, for the help popup |
| bash | 3.2 or later, so the stock macOS `/bin/bash` works |
| Operating system | macOS on Apple Silicon and Intel, Linux on x86_64 and arm64 |
| Core tools | BSD, GNU or uutils coreutils |
| `osascript` or `notify-send` | Optional, for desktop notifications on macOS or Linux |

## Installation

With [TPM](https://github.com/tmux-plugins/tpm), add the plugin and the placeholder to `~/.tmux.conf`, then press `prefix + I`:

```tmux
set -g @plugin 'tmux-revamped/tmux-pomodoro-revamped'
set -g status-right '#{pomodoro_status} | %H:%M'
```

Without TPM, clone the repository and run the entry point from `~/.tmux.conf`, after the line that sets `status-right`:

```sh
git clone https://github.com/tmux-revamped/tmux-pomodoro-revamped ~/.tmux/plugins/tmux-pomodoro-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-pomodoro-revamped/pomodoro-revamped.tmux
```

## Usage

Press `prefix + M-s` to start the timer. Press it again to pause, and again to resume.

`#{pomodoro_status}` in `status-left` or `status-right` renders the phase color, the `MM:SS` countdown and the `[interval/total]` counter, for example `23:20 [1/4]`. It renders nothing while no timer runs.

Every render also writes these tmux options, which a theme or another plugin can read without running the script:

| Option | Value |
|:-------|:------|
| `@pomodoro_status` | The rendered segment, the same text as `#{pomodoro_status}` |
| `@pomodoro_phase` | `work`, `break` or `long_break` |
| `@pomodoro_remaining` | Seconds left in the phase |
| `@pomodoro_fraction` | Percent of the phase elapsed |
| `@pomodoro_week` | A sparkline of work periods per weekday over the last 7 days, Sunday first, drawn with `_.-=+*%@` |
| `@pomodoro_today` | Work periods finished today |

The same actions run from a shell as `~/.tmux/plugins/tmux-pomodoro-revamped/src/pomodoro.sh <action>`, where the action is `toggle`, `cancel`, `skip`, `restart`, `menu` or `help`.

## Configuration

Set any option in `~/.tmux.conf` before the plugin loads.

| Option | Default | Meaning |
|:-------|:--------|:--------|
| `@pomodoro_revamped_work` | `25` | Work minutes |
| `@pomodoro_revamped_break` | `5` | Short break minutes |
| `@pomodoro_revamped_long_break` | `15` | Long break minutes |
| `@pomodoro_revamped_intervals` | `4` | Work periods before a long break |
| `@pomodoro_revamped_show_interval` | `1` | `0` hides the `[n/N]` counter |
| `@pomodoro_revamped_show_progress` | `0` | `1` puts a progress bar before the countdown |
| `@pomodoro_revamped_progress_width` | `8` | Progress bar width in cells |
| `@pomodoro_revamped_bar_filled` | `#` | Filled progress bar character |
| `@pomodoro_revamped_bar_empty` | `-` | Empty progress bar character |
| `@pomodoro_revamped_show_finish` | `0` | `1` appends `ends HH:MM` |
| `@pomodoro_revamped_show_goal` | `0` | `1` appends today's `done/goal` counter |
| `@pomodoro_revamped_goal` | `6` | Daily goal of work periods |
| `@pomodoro_revamped_pause_text` | ` paused` | Text appended while paused |
| `@pomodoro_revamped_work_color` | `#[fg=red]` | Style of the work phase |
| `@pomodoro_revamped_break_color` | `#[fg=green]` | Style of the short break |
| `@pomodoro_revamped_long_break_color` | `#[fg=blue]` | Style of the long break |
| `@pomodoro_revamped_work_icon` | empty | Text before the work countdown, such as a Nerd Font tomato |
| `@pomodoro_revamped_break_icon` | empty | Text before the short break countdown |
| `@pomodoro_revamped_long_break_icon` | empty | Text before the long break countdown |
| `@pomodoro_revamped_notifications` | `1` | `0` turns desktop notifications off |
| `@pomodoro_revamped_bell` | `0` | `1` rings the bell on every attached client at a phase change |
| `@pomodoro_revamped_quiet_hours` | empty | A range such as `22:00-07:00` that silences notifications and the bell |
| `@pomodoro_revamped_warn_seconds` | `0` | Seconds before a phase ends to warn once. `0` turns the warning off |
| `@pomodoro_revamped_on_work` | empty | Shell command run when a work period begins |
| `@pomodoro_revamped_on_break` | empty | Shell command run when a short break begins |
| `@pomodoro_revamped_on_long_break` | empty | Shell command run when a long break begins |
| `@pomodoro_revamped_on_cycle` | empty | Shell command run when a long break begins, after `on_long_break` |
| `@pomodoro_revamped_on_warn` | empty | Shell command run at the end-of-phase warning |
| `@pomodoro_revamped_toggle_key` | `M-s` | Prefix key that starts, pauses and resumes. `off` unbinds it |
| `@pomodoro_revamped_cancel_key` | empty | Prefix key that cancels the timer |
| `@pomodoro_revamped_skip_key` | empty | Prefix key that skips to the next phase |
| `@pomodoro_revamped_restart_key` | empty | Prefix key that restarts the current phase |
| `@pomodoro_revamped_menu_key` | empty | Prefix key that opens the control menu |
| `@pomodoro_revamped_help_key` | empty | Prefix key that opens the help popup |

### Internal state

The plugin manages these options itself. Do not set them.

| Option | Holds |
|:-------|:------|
| `@pomodoro_revamped_state` | Empty while idle, `running` or `paused` |
| `@pomodoro_revamped_start` | Epoch seconds the timer started, moved by skip and restart |
| `@pomodoro_revamped_paused_at` | Epoch seconds the current pause began, `0` while running |
| `@pomodoro_revamped_paused_total` | Seconds spent paused since the timer started |
| `@pomodoro_revamped_last_phase` | The phase seen last, so a phase change fires its hooks and alerts once |
| `@pomodoro_revamped_transition_claim` | A token that decides which concurrent status refresh handles a phase change |
| `@pomodoro_revamped_warned` | `1` once the warning fired for the current phase |
| `@pomodoro_revamped_week_counts` | Work periods per weekday, 7 comma-separated values from Sunday |
| `@pomodoro_revamped_week_day` | The day number of the last recorded work period, so stale weekdays are reset |

## Key bindings

| Key | Action | Option |
|:----|:-------|:-------|
| `prefix + M-s` | Start, pause or resume | `@pomodoro_revamped_toggle_key` |
| unbound | Cancel | `@pomodoro_revamped_cancel_key` |
| unbound | Skip to the next phase | `@pomodoro_revamped_skip_key` |
| unbound | Restart the current phase | `@pomodoro_revamped_restart_key` |
| unbound | Open the control menu | `@pomodoro_revamped_menu_key` |
| unbound | Open the help popup | `@pomodoro_revamped_help_key` |

`M-s` is the one key the tmux-revamped family allocates to this plugin. Before 2.0.0 the toggle was `p` and the other actions were bound to `P`, `_`, `R`, `o` and `?`. To get one back, set its option:

```tmux
set -g @pomodoro_revamped_menu_key 'o'
```

## How it works

**One start time.** The timer stores the epoch second it started and the seconds it spent paused. Each render subtracts both from the current time and walks the cycle of work periods, short breaks and the long break to find the phase and the seconds left. Skip moves the start time back by the seconds left. Restart moves it forward by the seconds already spent in the phase.

**No files.** Every value lives in tmux server options, so nothing is written under `/tmp` and nothing is left to clean up. The weekly tally is a 7-slot ring in an option.

**Rendering.** The entry point replaces `#{pomodoro_status}` with a `#()` call to [`src/pomodoro.sh`](src/pomodoro.sh), so the countdown advances once per `status-interval`. No background process runs.

**Phase changes.** Each attached client refreshes the status line, so several renders can notice the same phase change. A single conditional tmux command claims the change, and only the claiming render counts the work period, runs the hooks and sends the alerts. Hooks run through `run-shell -b`, so a slow command never holds the status line.

## Development

| Command | What it does |
|:--------|:-------------|
| `make test` | Runs the bats suite |
| `make lint` | Runs shellcheck on every shell file |
| `make coverage` | Measures line coverage with kcov and fails below 95 percent, on Linux |

The suite needs `bats-core` and tmux.

## License

[MIT](LICENSE)

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
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | Pick a URL, path, hash or any other token off the screen with fzf and type it at the cursor, in pure shell |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | Switch to, kill, rename or create tmux sessions, windows and panes from fzf pickers in a popup |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | Show the active pane's git branch, changes and provider counts in the tmux status bar without blocking it |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | GPU load, temperature, clock, power and memory in the tmux status bar, from NVIDIA, AMD, Intel and Apple GPUs |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | Current Kubernetes context and namespace in the tmux status bar, parsed from kubeconfig without kubectl |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | Launch any TUI app in a popup or a window, scoped to the current pane's directory, with one configurable bindi |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | Capture any pane to a file: live logging, full scrollback, or a one-shot screenshot |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | Now playing in your tmux status bar, without ever blocking the status render |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | Network throughput in your tmux status bar, without ever blocking the render |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | Pane and window management bindings for tmux, version aware, vim friendly, every prefix key can be disabled |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | Save every tmux session, window and pane, auto-save on a timer, and restore it all after a reboot |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | The starting point for a tmux-revamped plugin: shared library, bats harness, CI and family tooling |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | **this plugin**, A Pomodoro timer in the tmux status bar that keeps all of its state in tmux options, with no temp files |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | RAM, swap and memory pressure in the tmux status bar, sampled in the background so the render never waits |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | Drag a window tab along the tmux status bar with the mouse to move that window |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | Send the mouse wheel to apps that scroll themselves and into tmux copy-mode everywhere else |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | Sensible tmux defaults, gated by tmux version and terminal, that leave the options you set alone |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | Tiling window management for tmux: eight layouts including BSP dwindle and spiral, with layout undo |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | Local and world clocks for the tmux status bar, colored by time of day, with countdowns and a DST warning |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | Weather for the tmux status bar from wttr.in, fetched in the background so the status line never waits |

### Checking an installation

With every member on disk, one command reports any conflict between them:

```sh
family/bin/doctor --live
```

It reads each member and the running tmux server, and reports duplicate keys,
duplicate status placeholders, options outside the naming grammar, and any
member whose contract version has fallen behind.

<!-- family:end -->
