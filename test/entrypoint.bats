#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/server_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/server_helpers.bash"

bats_require_minimum_version 1.5.0

everything() {
  tmux show-options -g
  tmux list-keys
}

@test "entrypoint - git tracks the entry point and the tool as executable" {
  # Arrange
  local modes

  # Act
  modes=$(git -C "${ROOT}" ls-files --stage -- pomodoro-revamped.tmux bin/pomodoro-revamped)

  # Assert
  run awk '$1 != "100755" { bad++ } END { print NR ":" bad + 0 }' <<<"${modes}"
  [[ "${output}" == "2:0" ]]
}

@test "entrypoint - loading binds the toggle on M-s and turns the placeholder into the timer's job" {
  # Arrange
  local keys
  tmux set-option -g status-right '#{pomodoro_status} end'

  # Act
  load_plugin

  # Assert
  keys=$(prefix_keys)
  run grep -c -x 'M-s' <<<"${keys}"
  [[ "${output}" == "1" ]]
  run tmux show-option -gqv status-right
  [[ "${output}" == "#('${ROOT}/bin/pomodoro-revamped' status) end" ]]
}

@test "entrypoint - loading twice changes nothing" {
  # Arrange
  local before after
  tmux set-option -g status-right '#{pomodoro_status} end'
  load_plugin
  before=$(everything)

  # Act
  load_plugin

  # Assert
  after=$(everything)
  [[ "${before}" == "${after}" ]]
}

@test "entrypoint - a checkout whose path holds a space, a quote, a hash and a percent sign loads, counts down and takes its key" {
  # Arrange
  local copy="${BATS_TEST_TMPDIR}/it's #1 50% plug in"
  mkdir -p "${copy}"
  cp -R "${ROOT}/bin" "${ROOT}/lib" "${ROOT}/pomodoro-revamped.tmux" "${copy}/"
  tmux set-option -g status-right '#{pomodoro_status} end'
  load_plugin "${copy}"

  # Act
  press C-b M-s

  # Assert
  wait_for holds state running
  wait_for host_shows "[1/4]"
}

@test "entrypoint - a default key someone else holds is left alone, and one the person names is bound" {
  # Arrange
  local table
  tmux bind-key -T prefix M-s display-message taken
  tmux bind-key -T prefix x display-message taken-too
  setting cancel_key x

  # Act
  load_plugin

  # Assert
  table=$(tmux list-keys -T prefix)
  run grep -c 'M-s  *display-message taken' <<<"${table}"
  [[ "${output}" == "1" ]]
  run grep -c 'pomodoro-revamped. cancel' <<<"${table}"
  [[ "${output}" == "1" ]]
}

@test "entrypoint - a key set to off binds nothing" {
  # Arrange
  local table
  setting toggle_key off

  # Act
  load_plugin

  # Assert
  table=$(tmux list-keys -T prefix)
  run grep -c 'pomodoro-revamped' <<<"${table}"
  [[ "${output}" == "0" ]]
}
