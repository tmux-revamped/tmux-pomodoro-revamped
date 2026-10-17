#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POMO_CMD="${CURRENT_DIR}/src/pomodoro.sh"
POMO_Q="$(printf '%q' "${POMO_CMD}")"

get_key() {
  local v
  v=$(tmux show-option -gqv "${1}")
  echo "${v:-${2}}"
}

chmod +x "${POMO_CMD}" 2>/dev/null || true

bind_action() {
  local key
  key="$(get_key "${1}" "${2}")"
  [[ -z "${key}" || "${key}" == "off" ]] && return 0
  tmux bind-key "${key}" run-shell "${POMO_Q} ${3}"
}

bind_action "@pomodoro_revamped_toggle_key" "M-s" toggle
bind_action "@pomodoro_revamped_cancel_key" "" cancel
bind_action "@pomodoro_revamped_skip_key" "" skip
bind_action "@pomodoro_revamped_restart_key" "" restart
bind_action "@pomodoro_revamped_menu_key" "" menu
bind_action "@pomodoro_revamped_help_key" "" help

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
