#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/server_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/server_helpers.bash"

bats_require_minimum_version 1.5.0

all_keys() {
  setting cancel_key F5
  setting skip_key F6
  setting restart_key F7
  setting menu_key F8
  setting help_key F9
}

@test "keys - prefix M-s starts the timer, pauses it and resumes it" {
  # Arrange
  load_plugin
  press C-b M-s
  wait_for holds state running
  press C-b M-s
  wait_for holds state paused

  # Act
  press C-b M-s

  # Assert
  wait_for holds state running
  wait_for holds paused_at 0
}

@test "keys - a running timer shows its countdown in the status line and publishes its phase" {
  # Arrange
  tmux set-option -g status-right '#{pomodoro_status} end'
  load_plugin

  # Act
  press C-b M-s

  # Assert
  wait_for host_shows "[1/4]"
  wait_for holds phase work
  wait_for matches remaining '^1[0-9]{3}$'
}

@test "keys - the cancel key stops the timer and clears the status line" {
  # Arrange
  tmux set-option -g status-right '#{pomodoro_status} end'
  all_keys
  load_plugin
  press C-b M-s
  wait_for host_shows "[1/4]"

  # Act
  press C-b F5

  # Assert
  wait_for holds state ""
  wait_for host_lacks "[1/4]"
}

@test "keys - the skip key jumps to the break" {
  # Arrange
  tmux set-option -g status-right '#{pomodoro_status} end'
  all_keys
  load_plugin
  press C-b M-s
  wait_for holds phase work

  # Act
  press C-b F6

  # Assert
  wait_for holds phase break
  wait_for host_shows "[1/4]"
}

@test "keys - the restart key gives the phase its whole length back" {
  # Arrange
  local past
  tmux set-option -g status-right '#{pomodoro_status} end'
  all_keys
  load_plugin
  past=$(seconds_ago 600)
  setting state running
  setting start "${past}"
  setting last_phase work
  wait_for matches remaining '^(8[0-9]{2}|900)$'

  # Act
  press C-b F7

  # Assert
  wait_for matches remaining '^1(4[5-9][0-9]|500)$'
}

@test "keys - the menu key opens the menu, and its items start, skip, restart and cancel" {
  # Arrange
  tmux set-option -g status-right '#{pomodoro_status} end'
  all_keys
  load_plugin
  press C-b F8
  wait_for host_shows "Start / Pause"
  press Enter
  wait_for holds state running
  wait_for holds phase work
  press C-b F8
  wait_for host_shows "Skip phase"
  press Down Enter
  wait_for holds phase break
  press C-b F8
  wait_for host_shows "Restart phase"
  press Down Down Enter
  wait_for matches remaining '^(29[0-9]|300)$'
  press C-b F8
  wait_for host_shows "Cancel"

  # Act
  press Down Down Down Enter

  # Assert
  wait_for holds state ""
}

@test "keys - the help key opens the help page in a pager, and q closes it" {
  # Arrange
  command -v less >/dev/null || skip "less is not installed"
  all_keys
  load_plugin

  # Act
  press C-b F9

  # Assert
  wait_for host_shows "pomodoro-revamped - a Pomodoro timer in the tmux status bar"
  press q
  wait_for host_lacks "pomodoro-revamped - a Pomodoro timer in the tmux status bar"
}

@test "keys - without less the help key shows the page and waits for Enter, where the popup would close at once" {
  # Arrange
  local farm="${BATS_TEST_TMPDIR}/farm" folder
  mkdir -p "${farm}"
  local IFS=:
  for folder in ${PATH}; do
    [[ -d "${folder}" ]] || continue
    ln -s "${folder}"/* "${farm}/" 2>/dev/null || :
  done
  unset IFS
  rm -f "${farm}/less"
  tmux set-environment -g PATH "${STUBS}:${farm}"
  all_keys
  load_plugin

  # Act
  press C-b F9

  # Assert
  wait_for host_shows "pomodoro-revamped doctor"
  press Enter
  wait_for host_lacks "pomodoro-revamped doctor"
}

@test "keys - the end of a work period is counted once, runs its hook and notifies, on a real server" {
  # Arrange
  local past
  tmux set-option -g status-right '#{pomodoro_status} end'
  setting on_break "tmux set-option -g @pomodoro_test_hook ran"
  setting notify 1
  load_plugin
  past=$(seconds_ago 1505)
  setting last_phase work
  setting start "${past}"

  # Act
  setting state running

  # Assert
  wait_for holds phase break
  wait_for holds last_phase break
  wait_for matches week_counts '^(1,0,0,0,0,0,0|0,1,0,0,0,0,0|0,0,1,0,0,0,0|0,0,0,1,0,0,0|0,0,0,0,1,0,0|0,0,0,0,0,1,0|0,0,0,0,0,0,1)$'
  wait_for notified "Pomodoro|Take a short break"
  run tmux show-option -gqv @pomodoro_test_hook
  [[ "${output}" == "ran" ]]
}
