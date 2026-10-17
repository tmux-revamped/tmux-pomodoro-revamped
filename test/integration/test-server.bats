#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../tmux_helpers.bash"

teardown() {
  teardown_tmux_server
}

@test "tmux_helpers - the test server ignores the user tmux config" {
  # Arrange
  export HOME="${BATS_TEST_TMPDIR}/home"
  export XDG_CONFIG_HOME="${HOME}/.config"
  mkdir -p "${XDG_CONFIG_HOME}/tmux"
  printf 'set -g @leaked_from_user_config yes\n' > "${HOME}/.tmux.conf"
  printf 'set -g @leaked_from_user_config yes\n' > "${XDG_CONFIG_HOME}/tmux/tmux.conf"

  # Act
  setup_tmux_server

  # Assert
  command tmux -S "${TMUX_SOCKET}" has-session -t test
  [ -z "$(get_option @leaked_from_user_config)" ]
}
