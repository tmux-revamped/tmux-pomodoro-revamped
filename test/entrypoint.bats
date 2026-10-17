#!/usr/bin/env bats

setup() {
  PLUGIN_ROOT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
  COPY_DIR="${BATS_TEST_TMPDIR}/my plugins/it's here"
  mkdir -p "${COPY_DIR}"
  cp -Rf "${PLUGIN_ROOT}/src" "${PLUGIN_ROOT}/pomodoro-revamped.tmux" "${COPY_DIR}/"
  TMUX_LOG="${BATS_TEST_TMPDIR}/tmux.log"
  export TMUX_LOG
  tmux() {
    if [[ "${1}" == "show-option" ]]; then
      [[ "${3}" == "status-right" ]] && printf '%s' '#{pomodoro_status} | %H:%M'
      return 0
    fi
    printf '%s\037' "$@" >> "${TMUX_LOG}"
    printf '\n' >> "${TMUX_LOG}"
  }
  export -f tmux
}

_logged_field() {
  local line
  line="$(grep -F "${1}" "${TMUX_LOG}" | head -n 1)"
  printf '%s' "${line}" | awk -v n="${2}" 'BEGIN { FS = "\037" } { print $n }'
}

@test "entrypoint - the bound run-shell command keeps a spaced plugin path as one word" {
  # Arrange
  local -a words

  # Act
  bash "${COPY_DIR}/pomodoro-revamped.tmux"

  # Assert
  eval "words=($(_logged_field "$(printf 'bind-key\037M-s\037')" 4))"
  [ "${words[0]}" == "${COPY_DIR}/src/pomodoro.sh" ]
  [ "${words[1]}" == "toggle" ]
}

@test "entrypoint - the status placeholder becomes a job with a quoted plugin path" {
  # Arrange
  local value command
  local -a words

  # Act
  bash "${COPY_DIR}/pomodoro-revamped.tmux"

  # Assert
  value="$(_logged_field "$(printf 'set-option\037-gq\037status-right\037')" 4)"
  [[ "${value}" == "#("*") | %H:%M" ]] || false
  command="${value#'#('}"
  command="${command%') | %H:%M'}"
  eval "words=(${command})"
  [ "${words[0]}" == "${COPY_DIR}/src/pomodoro.sh" ]
  [ "${words[1]}" == "status" ]
}

@test "entrypoint - only the toggle is bound by default, on M-s" {
  # Act
  bash "${COPY_DIR}/pomodoro-revamped.tmux"

  # Assert
  [ "$(grep -c "^bind-key"$'\037' "${TMUX_LOG}")" -eq 1 ] || false
  [ "$(_logged_field "$(printf 'bind-key\037')" 2)" == "M-s" ]
}

@test "entrypoint - cancel, skip, restart, menu and help stay unbound by default" {
  # Act
  bash "${COPY_DIR}/pomodoro-revamped.tmux"

  # Assert
  [[ "$(cat "${TMUX_LOG}")" != *"cancel"* ]] || false
  [[ "$(cat "${TMUX_LOG}")" != *" menu"* ]] || false
  [[ "$(cat "${TMUX_LOG}")" != *" help"* ]]
}
