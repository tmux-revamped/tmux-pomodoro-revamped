#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/pomodoro_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/pomodoro_helpers.bash"

@test "plan - by default only the toggle is bound, on M-s, and the status line is left alone" {
  # Arrange
  local t
  t=$(tool_path)

  # Act
  planned

  # Assert
  [[ "${#lines[@]}" -eq 1 ]]
  [[ "${lines[0]}" == "bind-key -N Start or pause M-s run-shell ${t} toggle" ]]
}

@test "plan - a binding carries a note from tmux 3.1 on, and none before it or on a version it cannot read" {
  # Arrange
  local t version
  t=$(tool_path)
  local -a seen=()

  # Act
  for version in 3.0 2.9 3.1 4.0 next-3.7 master; do
    tmux_is "${version}"
    planned
    seen+=("${output}")
  done

  # Assert
  [[ "${seen[0]}" == "bind-key M-s run-shell ${t} toggle" ]]
  [[ "${seen[1]}" == "bind-key M-s run-shell ${t} toggle" ]]
  [[ "${seen[2]}" == "bind-key -N Start or pause M-s run-shell ${t} toggle" ]]
  [[ "${seen[3]}" == "bind-key -N Start or pause M-s run-shell ${t} toggle" ]]
  [[ "${seen[4]}" == "bind-key -N Start or pause M-s run-shell ${t} toggle" ]]
  [[ "${seen[5]}" == "bind-key M-s run-shell ${t} toggle" ]]
}

@test "plan - each key runs its command, the menu key opens the menu itself and the help key a pager" {
  # Arrange
  local t
  t=$(tool_path)
  option toggle_key T
  option cancel_key M-c
  option skip_key M-k
  option restart_key M-r
  option menu_key M-p
  option help_key M-o

  # Act
  planned

  # Assert
  [[ "${#lines[@]}" -eq 6 ]]
  [[ "${lines[0]}" == "bind-key -N Start or pause T run-shell ${t} toggle" ]]
  [[ "${lines[1]}" == "bind-key -N Cancel M-c run-shell ${t} cancel" ]]
  [[ "${lines[2]}" == "bind-key -N Skip phase M-k run-shell ${t} skip" ]]
  [[ "${lines[3]}" == "bind-key -N Restart phase M-r run-shell ${t} restart" ]]
  [[ "${lines[4]}" == "bind-key -N Pomodoro menu M-p display-menu -T Pomodoro Start / Pause \"\" run-shell \"${t} toggle\" Skip phase \"\" run-shell \"${t} skip\" Restart phase \"\" run-shell \"${t} restart\" Cancel \"\" run-shell \"${t} cancel\"" ]]
  [[ "${lines[5]}" == "bind-key -N Pomodoro help M-o display-popup -E -w 90% -h 90% if command -v less >/dev/null 2>&1; then ${t} help | less; else ${t} help; read -r pomodoro_revamped_wait; fi" ]]
}

@test "plan - a key set to off binds nothing" {
  # Arrange
  option toggle_key off

  # Act
  planned

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "" ]]
}

@test "plan - the keys other people hold are read from the prefix table, repeat flag and escaped key included" {
  # Arrange
  printf '%s\n' 'bind-key    -T prefix M-s     run-shell foo' 'bind-key -r -T prefix Up      resize-pane -U' 'bind-key    -T prefix \;      last-pane' "bind-key    -T prefix M-z     run-shell \"'/x/bin/pomodoro-revamped' cancel\"" >"${FAKE}/keys"

  # Act
  lib_run pomodoro 'pomodoro_revamped_held'

  # Assert
  [[ "${output}" == "M-s Up ; " ]]
}

@test "plan - the default key is left alone when someone else holds it, and named" {
  # Arrange
  printf '%s\n' 'bind-key    -T prefix M-s     run-shell foo' >"${FAKE}/keys"

  # Act
  lib_run pomodoro 'pomodoro_revamped_plan; pomodoro_revamped_lines; printf "skipped=%s\n" "${POMODORO_REVAMPED_SKIPPED}"'

  # Assert
  [[ "${output}" == "skipped=M-s" ]]
}

@test "plan - its own binding on the default key is bound again" {
  # Arrange
  local t
  t=$(tool_path)
  printf '%s\n' "bind-key    -T prefix M-s     run-shell \"'/old/bin/pomodoro-revamped' toggle\"" >"${FAKE}/keys"

  # Act
  planned

  # Assert
  [[ "${output}" == "bind-key -N Start or pause M-s run-shell ${t} toggle" ]]
}

@test "plan - a key the person names is bound whoever holds it" {
  # Arrange
  local t
  t=$(tool_path)
  option toggle_key x
  printf '%s\n' 'bind-key    -T prefix x       confirm-before kill-pane' >"${FAKE}/keys"

  # Act
  planned

  # Assert
  [[ "${output}" == "bind-key -N Start or pause x run-shell ${t} toggle" ]]
}

@test "plan - two actions on one key bind it for the first, and the clash is named" {
  # Arrange
  local t
  t=$(tool_path)
  option cancel_key M-c
  option skip_key M-c

  # Act
  lib_run pomodoro 'pomodoro_revamped_plan; pomodoro_revamped_lines; printf "skipped=%s\n" "${POMODORO_REVAMPED_SKIPPED}"'

  # Assert
  [[ "${#lines[@]}" -eq 3 ]]
  [[ "${lines[1]}" == "bind-key -N Cancel M-c run-shell ${t} cancel" ]]
  [[ "${lines[2]}" == "skipped=M-c" ]]
}

@test "plan - the placeholder becomes the timer's job in both status strings, every time it appears" {
  # Arrange
  local t
  t=$(tool_path)
  var status-left '#{pomodoro_status} | #S'
  var status-right 'a #{pomodoro_status} b #{pomodoro_status}'

  # Act
  planned

  # Assert
  [[ "${#lines[@]}" -eq 3 ]]
  [[ "${lines[1]}" == "set-option -gq status-left #(${t} status) | #S" ]]
  [[ "${lines[2]}" == "set-option -gq status-right a #(${t} status) b #(${t} status)" ]]
}

@test "plan - a status string without the placeholder is not written" {
  # Arrange
  var status-left '#S'
  var status-right '%H:%M'

  # Act
  planned

  # Assert
  [[ "${#lines[@]}" -eq 1 ]]
  [[ "${lines[0]}" == "bind-key "* ]]
}

@test "plan - a setting from the environment rides on the keys and on the status job, and a key setting does not" {
  # Arrange
  local t
  t=$(tool_path)
  export POMODORO_REVAMPED_WORK=50 POMODORO_REVAMPED_TOGGLE_KEY=T POMODORO_REVAMPED_THEME=mono
  var status-right '#{pomodoro_status}'

  # Act
  planned

  # Assert
  [[ "${lines[0]}" == "bind-key -N Start or pause T run-shell ${t} --work '50' toggle" ]]
  [[ "${lines[1]}" == "set-option -gq status-right #(${t} --work '50' status)" ]]
}

@test "plan - a carried value with a hash is hidden from a popup and doubled for the status line" {
  # Arrange
  local t
  t=$(tool_path)
  export POMODORO_REVAMPED_WORK_COLOR='#[fg=cyan]'
  var status-right '#{pomodoro_status}'

  # Act
  planned

  # Assert
  [[ "${lines[0]}" == "bind-key -N Start or pause M-s run-shell ${t} --work-color ''\"\$(printf '%b' '\\0043')\"'[fg=cyan]' toggle" ]]
  [[ "${lines[1]}" == "set-option -gq status-right #(${t} --work-color '##[fg=cyan]' status)" ]]
}

@test "plan - with every key off and no placeholder, apply sends nothing" {
  # Arrange
  option toggle_key off

  # Act
  tool apply

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "" ]]
  run sends
  [[ "${output}" == "" ]]
}
