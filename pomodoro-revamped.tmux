#!/usr/bin/env bash
#
# pomodoro-revamped.tmux: TPM entry point.
#
# Binds the timer controls and replaces #{pomodoro_status} in the status line with
# a call to the dispatcher. The phase is computed from stored epochs, so the
# render never waits and no temp file is touched.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POMO_CMD="${CURRENT_DIR}/src/pomodoro.sh"
POMO_Q="$(printf '%q' "${POMO_CMD}")"

get_key() {
  local v
  v=$(tmux show-option -gqv "${1}")
  echo "${v:-${2}}"
}

chmod +x "${POMO_CMD}" 2>/dev/null || true

tmux bind-key "$(get_key "@pomodoro_revamped_toggle_key" "p")" run-shell "${POMO_Q} toggle"
tmux bind-key "$(get_key "@pomodoro_revamped_cancel_key" "P")" run-shell "${POMO_Q} cancel"
tmux bind-key "$(get_key "@pomodoro_revamped_skip_key" "_")" run-shell "${POMO_Q} skip"
tmux bind-key "$(get_key "@pomodoro_revamped_restart_key" "R")" run-shell "${POMO_Q} restart"
tmux bind-key "$(get_key "@pomodoro_revamped_menu_key" "o")" run-shell "${POMO_Q} menu"
tmux bind-key "$(get_key "@pomodoro_revamped_help_key" "?")" run-shell "${POMO_Q} help"

placeholders=(
  "#{pomodoro_status}"
)

commands=(
  "#(${POMO_Q} status)"
)

interpolate() {
  local value="${1}" result placeholder i
  for (( i = 0; i < ${#placeholders[@]}; i++ )); do
    placeholder="${placeholders[i]}"
    result=""
    while [[ "${value}" == *"${placeholder}"* ]]; do
      result=${result}${value%%"${placeholder}"*}${commands[i]}
      value=${value#*"${placeholder}"}
    done
    value=${result}${value}
  done
  printf '%s\n' "${value}"
}

update_option() {
  local option="${1}" current
  current=$(tmux show-option -gqv "${option}")
  tmux set-option -gq "${option}" "$(interpolate "${current}")"
}

update_option "status-left"
update_option "status-right"
