<div align="center">

# tmux-pomodoro-revamped

<strong>A Pomodoro timer in the tmux status bar that keeps all of its state in tmux options, with no temp files.</strong>

English &nbsp;|&nbsp; [日本語](README.ja.md) &nbsp;|&nbsp; [简体中文](README.zh-Hans.md) &nbsp;|&nbsp; [繁體中文（香港）](README.zh-HK.md)

[![ci](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-pomodoro-revamped/ci.yml?branch=main&style=flat-square&label=ci)](https://github.com/tmux-revamped/tmux-pomodoro-revamped/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-pomodoro-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-pomodoro-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-pomodoro-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-pomodoro-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-pomodoro-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#quick-start"><strong>Quick start</strong></a> &nbsp;|&nbsp;
  <a href="#usage">Usage</a> &nbsp;|&nbsp;
  <a href="#how-it-works">How it works</a> &nbsp;|&nbsp;
  <a href="#screens">Screens</a>
</p>

</div>

<p align="center">
  <img src="screens/hero.gif" alt="pomodoro-revamped starting a timer in the status line, pausing it, skipping to the break from its menu and showing a progress bar" width="800">
</p>

```console
$ pomodoro-revamped toggle
$ pomodoro-revamped --show-progress 1 status
#[fg=red]-------- 25:00 [1/4]#[default]
```

The timer counts down work periods and breaks in the status bar, then repeats the cycle. It pauses and resumes without losing a second, and on each phase change it can send a desktop notification, ring the terminal bell, and run a shell command of your choice. It also keeps a 7-day tally of finished work periods.

---

## Quick start

### Prerequisites

| Tool | Version | Used for |
|:-----|:--------|:---------|
| tmux | 3.2 or later | the family floor, and the help popup |
| `osascript` or `notify-send` | optional | desktop notifications on macOS or Linux |
| `less` | optional | the help key pages the help page with it; without it the popup shows the whole page and Enter closes it |
| gum | optional | the menu, tables and colours of `pomodoro-revamped`; without it every command prints plain text |

### Install

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

`make install` in the clone also puts `pomodoro-revamped` in `~/.local/bin`, with its man page and completions under `~/.local/share`.

### Verify

```bash
~/.tmux/plugins/tmux-pomodoro-revamped/bin/pomodoro-revamped doctor
```

## Usage

Press `prefix + M-s` to start the timer. Press it again to pause, and again to resume.

`#{pomodoro_status}` in `status-left` or `status-right` renders the phase color, the `MM:SS` countdown and the `[interval/total]` counter, for example `23:20 [1/4]`. It renders nothing while no timer runs.

Every render also writes these tmux options, which a theme or another plugin can read without running the script:

| Option | Value |
|:-------|:------|
| `@pomodoro_revamped_status` | The rendered segment, the same text as `#{pomodoro_status}` |
| `@pomodoro_revamped_phase` | `work`, `break` or `long_break` |
| `@pomodoro_revamped_remaining` | Seconds left in the phase |
| `@pomodoro_revamped_fraction` | Percent of the phase elapsed |
| `@pomodoro_revamped_week` | A sparkline of work periods per weekday over the last 7 days, Sunday first, drawn with `_.-=+*%@` |
| `@pomodoro_revamped_today` | Work periods finished today |

| Command | What it does |
|:--------|:-------------|
| `pomodoro-revamped apply` | Binds the keys and replaces the placeholder now; the entry point runs it when tmux loads the plugin |
| `pomodoro-revamped list` | Prints every command `apply` would send and changes nothing; `--json` prints one object |
| `pomodoro-revamped toggle` | Starts the timer, pauses it or resumes it |
| `pomodoro-revamped skip` | Jumps to the next phase |
| `pomodoro-revamped restart` | Starts the current phase again |
| `pomodoro-revamped cancel` | Stops the timer and clears it |
| `pomodoro-revamped status` | Prints the status segment; the status line runs it |
| `pomodoro-revamped doctor` | One row per dependency: the notifier, `less` and any key left alone |
| `pomodoro-revamped version` | The version, then the tmux version |
| `pomodoro-revamped help` | The help page; `man pomodoro-revamped` documents the same commands and settings |
| `pomodoro-revamped` | On a terminal, a menu |

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
| `@pomodoro_revamped_notify` | `0` | `1` sends a desktop notification at each phase change and minute warning. |
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

Every option is also a command option with dashes, such as `--work 50`, and an environment variable, such as `POMODORO_REVAMPED_WORK`; the command line wins over the environment, and the environment over the tmux option. An empty tmux option means its default. One given to `apply` rides on every binding and on the status call.

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

`M-s` is the one key the tmux-revamped family allocates to this plugin. The other keys are unbound until you set their options, and a default key someone else holds is left alone, which `doctor` reports:

```tmux
set -g @pomodoro_revamped_menu_key 'o'
```

<a id="how-it-works"></a>

## How it works

**One start time.** The timer stores the epoch second it started and the seconds it spent paused. Each render subtracts both from the current time and walks the cycle of work periods, short breaks and the long break to find the phase and the seconds left. Skip moves the start time back by the seconds left. Restart moves it forward by the seconds already spent in the phase.

**No files.** Every value lives in tmux server options, so nothing is written under `/tmp` and nothing is left to clean up. The weekly tally is a 7-slot ring in an option.

**Rendering.** The entry point replaces `#{pomodoro_status}` with a `#()` call to [`bin/pomodoro-revamped`](bin/pomodoro-revamped), so the countdown advances once per `status-interval`. No background process runs.

**Phase changes.** Each attached client refreshes the status line, so several renders can notice the same phase change. A single conditional tmux command claims the change, and only the claiming render counts the work period, runs the hooks and sends the alerts. Hooks run through `run-shell -b`, so a slow command never holds the status line.

<a id="screens"></a>

## Screens

<details>
<summary>Every screen, recorded inside a real tmux with <code>make screens</code>, with each key on the status line</summary>
<br>

<table>
<tr>
<td width="50%" valign="top"><img src="screens/running.png" alt="pomodoro-revamped: prefix M-s starts the timer"><br><sub><code>prefix M-s</code> starts the timer, from <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/paused.png" alt="pomodoro-revamped: prefix M-s pauses it"><br><sub><code>prefix M-s</code> pauses it, from <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/timer-menu.png" alt="pomodoro-revamped: prefix M-p, the menu key, opens the timer menu"><br><sub><code>prefix M-p</code>, the menu key, opens the timer menu, from <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/break.png" alt="pomodoro-revamped: Skip phase, from the menu, starts the break"><br><sub>Skip phase, from the menu, starts the break, from <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/progress.png" alt="pomodoro-revamped: The progress bar, today's count over the goal and the finish time"><br><sub>The progress bar, today's count over the goal and the finish time, from <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/restarted.png" alt="pomodoro-revamped: prefix M-r, the restart key, starts the phase again"><br><sub><code>prefix M-r</code>, the restart key, starts the phase again, from <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/help-popup.png" alt="pomodoro-revamped: prefix M-o, the help key, opens the help page"><br><sub><code>prefix M-o</code>, the help key, opens the help page, from <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/skipped.png" alt="pomodoro-revamped: prefix M-k, the skip key, jumps to the next phase"><br><sub><code>prefix M-k</code>, the skip key, jumps to the next phase, from <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/cancelled.png" alt="pomodoro-revamped: prefix M-c, the cancel key, clears the timer"><br><sub><code>prefix M-c</code>, the cancel key, clears the timer, from <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/list.png" alt="pomodoro-revamped: list prints every binding"><br><sub><code>list</code> prints every binding, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/status.png" alt="pomodoro-revamped: status prints the segment"><br><sub><code>status</code> prints the segment, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/doctor.png" alt="pomodoro-revamped: doctor"><br><sub><code>doctor</code>, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-menu.png" alt="pomodoro-revamped: The menu without gum"><br><sub>The menu without gum, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/plain-doctor.png" alt="pomodoro-revamped: doctor from the menu"><br><sub><code>doctor</code> from the menu, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/version.png" alt="pomodoro-revamped: The version"><br><sub>The version, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/error.png" alt="pomodoro-revamped: An unknown command"><br><sub>An unknown command, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/themes.png" alt="pomodoro-revamped: The header in six themes"><br><sub>The header in six themes, from <code>themes.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/help.png" alt="pomodoro-revamped: The help page"><br><sub>The help page, from <code>help.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/accent.png" alt="pomodoro-revamped: An accent from POMODORO_REVAMPED_ACCENT"><br><sub>An accent from <code>POMODORO_REVAMPED_ACCENT</code>, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"></td>
</tr>
</table>

</details>

## Portability

The plugin is POSIX `sh`. CI runs every suite on each row below.

| Shell | Status |
|:------|:-------|
| `dash`, `/bin/sh` on macOS | Supported |
| `bash` 3.2 and 5.x, the system's `zsh` and Homebrew's | Supported |

| System | Status |
|:-------|:-------|
| macOS | Tahoe on Apple Silicon and Intel, with the tools it ships, Homebrew's GNU tools and Homebrew's uutils |
| Linux | Ubuntu 26.04 on x86_64 and arm64, with GNU coreutils, uutils and BusyBox |

## Development

| Command | What it runs |
|:--------|:-------------|
| `make fmt` | shfmt `-i 2` on every script |
| `make lint` | shfmt, ShellCheck, mandoc, yamllint and actionlint, at zero findings |
| `make test` | The bats suites under the system `sh` |
| `make test-all` | The suites under every installed shell, both builds of bash and zsh on macOS |
| `make test-linux` | The suites in an Ubuntu container |
| `make coverage` | bashcov on this Mac and in the Ubuntu container, merged and gated at 100 percent |
| `make screens` | The screens above, recorded from the real plugin inside tmux with VHS, on macOS |
| `make install` | The command, its man page and completions under `PREFIX` |

On macOS, `brew bundle` installs every tool these targets call, from the [`Brewfile`](Brewfile).

Commits follow the conventional commit format and go straight to `main`. After a green `ci` run on `main`, `release.yml` runs semantic-release: every `feat` or `fix` since the last tag publishes a release, stamps the version constant and adds the notes to [`CHANGELOG.md`](CHANGELOG.md).

## License

[MIT](LICENSE), copyright Gustavo Franco.

<!-- family:begin -->

## The tmux-revamped family

This plugin is one member of the tmux-revamped family. Every member carries the same contract in [`FAMILY.md`](FAMILY.md) and the same shared library, and they are built to be installed together: no member claims a key or a tmux option that another member claims.

A defect found in one member is hunted across all of them before the fix is called done.

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
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | Open any terminal app in a tmux popup, window or split from one menu, starting at the project root |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | Capture any pane to a file: live logging, full scrollback, or a one-shot screenshot |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | Now playing in your tmux status bar, without ever blocking the status render |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | Network throughput in your tmux status bar, without ever blocking the render |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | Pane and window management bindings for tmux, version aware, vim friendly, every prefix key can be disabled |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | Save every tmux session, window and pane, auto-save on a timer, and restore it all after a reboot |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | The starting point for a tmux-revamped plugin: shared library, bats harness and CI |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | **this plugin**, A Pomodoro timer in the tmux status bar that keeps all of its state in tmux options, with no temp files |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | RAM, swap and memory pressure in the tmux status bar, sampled in the background so the render never waits |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | Drag a window tab along the tmux status bar with the mouse to move that window |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | Send the mouse wheel to apps that scroll themselves and into tmux copy-mode everywhere else |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | Sensible tmux defaults, gated by tmux version and terminal, that leave the options you set alone |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | Tiling window management for tmux: eight layouts including BSP dwindle and spiral, with layout undo |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | Local and world clocks for the tmux status bar, colored by time of day, with countdowns and a DST warning |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | Weather for the tmux status bar from wttr.in, fetched in the background so the status line never waits |

<!-- family:end -->
