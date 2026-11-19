#!/bin/sh

[ -n "${POMODORO_REVAMPED_POMODORO_LOADED:-}" ] && return 0
POMODORO_REVAMPED_POMODORO_LOADED=1

# shellcheck source=SCRIPTDIR/state.sh
. "${REVAMPED_LIB:?}/state.sh"
# shellcheck source=SCRIPTDIR/command.sh
. "${REVAMPED_LIB}/command.sh"

pomodoro_revamped_format() {
  printf '%s\n' "${POMODORO_REVAMPED_SETTINGS}" | awk -F '\t' -v live="${POMODORO_REVAMPED_LIVE}" '{ printf "%s#{@pomodoro_revamped_%s}", (NR > 1 ? "\t" : ""), $1 } END { count = split(live, name, " "); for (i = 1; i <= count; i++) { printf "\t#{@pomodoro_revamped_%s}", name[i] } }'
}

pomodoro_revamped_resolve() {
  env | POMODORO_REVAMPED_ROWS="${POMODORO_REVAMPED_SETTINGS}" POMODORO_REVAMPED_VALUES="$1" awk -v live="${POMODORO_REVAMPED_LIVE}" '
    BEGIN {
      count = split(ENVIRON["POMODORO_REVAMPED_ROWS"], rows, "\n")
      split(ENVIRON["POMODORO_REVAMPED_VALUES"], given, "\t")
      for (i = 1; i <= count; i++) {
        at = index(rows[i], "\t")
        if (at == 0) { at = length(rows[i]) + 1 }
        name[i] = substr(rows[i], 1, at - 1)
        value[i] = (given[i] != "") ? given[i] : substr(rows[i], at + 1)
        want["POMODORO_REVAMPED_" toupper(name[i])] = i
      }
    }
    {
      at = index($0, "=")
      key = substr($0, 1, at - 1)
      if (key in want) { value[want[key]] = substr($0, at + 1) }
    }
    END {
      for (i = 1; i <= count; i++) { print name[i] "\t" value[i] }
      extra = split(live, state, " ")
      for (i = 1; i <= extra; i++) { print state[i] "\t" given[count + i] }
    }
  '
}

pomodoro_revamped_load() {
  pomodoro_revamped_load_format=$(pomodoro_revamped_format)
  pomodoro_revamped_load_live=$(tmux display-message -p "${pomodoro_revamped_load_format}" 2>/dev/null) || pomodoro_revamped_load_live=""
  pomodoro_revamped_load_values=$(pomodoro_revamped_resolve "${pomodoro_revamped_load_live}")
  while IFS='	' read -r pomodoro_revamped_load_name pomodoro_revamped_load_value; do
    IFS= read -r "POMODORO_REVAMPED_S_${pomodoro_revamped_load_name}" <<EOF
${pomodoro_revamped_load_value}
EOF
  done <<EOF
${pomodoro_revamped_load_values}
EOF
}

pomodoro_revamped_parse_version() {
  printf '%s\n' "$1" | sed -En 's/^tmux[ -]([a-z]+-)?([0-9]+\.[0-9]+).*/\2/p'
}

pomodoro_revamped_version_ge() {
  case "$1:$2" in
  *[!0-9.:]* | :* | *:) return 1 ;;
  *) ;;
  esac
  pomodoro_revamped_version_ge_have="${1%%.*}"
  pomodoro_revamped_version_ge_want="${2%%.*}"
  [ "${pomodoro_revamped_version_ge_have}" -gt "${pomodoro_revamped_version_ge_want}" ] && return 0
  [ "${pomodoro_revamped_version_ge_have}" -eq "${pomodoro_revamped_version_ge_want}" ] || return 1
  pomodoro_revamped_version_ge_have="${1#*.}"
  pomodoro_revamped_version_ge_want="${2#*.}"
  [ "${pomodoro_revamped_version_ge_have%%.*}" -ge "${pomodoro_revamped_version_ge_want%%.*}" ]
}

pomodoro_revamped_emit() {
  for pomodoro_revamped_emit_arg in "$@"; do
    case "${pomodoro_revamped_emit_arg}" in
    *\;) pomodoro_revamped_emit_arg="${pomodoro_revamped_emit_arg%;}\\;" ;;
    *) ;;
    esac
    POMODORO_REVAMPED_PLAN="${POMODORO_REVAMPED_PLAN}${pomodoro_revamped_emit_arg:-${POMODORO_REVAMPED_EMPTY}}
"
  done
  POMODORO_REVAMPED_PLAN="${POMODORO_REVAMPED_PLAN}
"
}

pomodoro_revamped_literal() {
  printf '%s\n' "$1" | sed -e "s/'/'\\\\''/g" -e "s/#/'\"\$(printf '%b' '\\\\0043')\"'/g" -e "1s/^/'/" -e "\$s/\$/'/"
}

pomodoro_revamped_tmux_string() {
  printf '%s\n' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\$/\\$/g'
}

pomodoro_revamped_send() {
  set --
  pomodoro_revamped_send_sep=""
  while IFS= read -r pomodoro_revamped_send_line; do
    if [ -z "${pomodoro_revamped_send_line}" ]; then
      [ "$#" -eq 0 ] || pomodoro_revamped_send_sep=";"
      continue
    fi
    [ -z "${pomodoro_revamped_send_sep}" ] || set -- "$@" "${pomodoro_revamped_send_sep}"
    pomodoro_revamped_send_sep=""
    [ "${pomodoro_revamped_send_line}" != "${POMODORO_REVAMPED_EMPTY}" ] || pomodoro_revamped_send_line=""
    set -- "$@" "${pomodoro_revamped_send_line}"
  done <<PLAN
${POMODORO_REVAMPED_PLAN}
PLAN
  [ "$#" -gt 0 ] || return 0
  tmux "$@" 2>/dev/null
}

pomodoro_revamped_send_each() {
  pomodoro_revamped_send_each_status=0
  set --
  while IFS= read -r pomodoro_revamped_send_each_line; do
    if [ -n "${pomodoro_revamped_send_each_line}" ]; then
      [ "${pomodoro_revamped_send_each_line}" != "${POMODORO_REVAMPED_EMPTY}" ] || pomodoro_revamped_send_each_line=""
      set -- "$@" "${pomodoro_revamped_send_each_line}"
      continue
    fi
    [ "$#" -gt 0 ] || continue
    tmux "$@" || pomodoro_revamped_send_each_status=1
    set --
  done <<PLAN
${POMODORO_REVAMPED_PLAN}
PLAN
  return "${pomodoro_revamped_send_each_status}"
}

pomodoro_revamped_deliver() {
  ! pomodoro_revamped_send || return 0
  pomodoro_revamped_send_each
}

pomodoro_revamped_lines() {
  printf '%s' "${POMODORO_REVAMPED_PLAN}" | awk -v empty="${POMODORO_REVAMPED_EMPTY}" '$0 == empty { $0 = "\"\"" } $0 == "" && line != "" { print line; line = ""; next } $0 == "" { next } { line = (line == "" ? $0 : line " " $0) } END { if (line != "") { print line } }'
}

pomodoro_revamped_json() {
  printf '%s' "${POMODORO_REVAMPED_PLAN}" | awk -v empty="${POMODORO_REVAMPED_EMPTY}" '
    function quote(s,    out, i, c) {
      out = ""
      for (i = 1; i <= length(s); i++) {
        c = substr(s, i, 1)
        if (c == "\\") { out = out "\\\\" } else if (c == "\"") { out = out "\\\"" } else { out = out c }
      }
      return "\"" out "\""
    }
    /^$/ { if (args != "") { rows = rows (rows == "" ? "" : ",") "[" args "]" } args = ""; next }
    $0 == empty { $0 = "" }
    { args = args (args == "" ? "" : ",") quote($0) }
    END {
      if (args != "") { rows = rows (rows == "" ? "" : ",") "[" args "]" }
      print "{\"bindings\":[" rows "]}"
    }
  '
}

pomodoro_revamped_bindings() {
  printf '%s' "${POMODORO_REVAMPED_PLAN}" | awk 'previous == "" && $0 == "bind-key" { count++ } { previous = $0 } END { print count + 0 }'
}

pomodoro_revamped_setting_name() {
  pomodoro_revamped_setting_name_raw=$(printf '%s\n' "${1#--}" | tr '-' '_')
  case " ${POMODORO_REVAMPED_NAMES} " in
  *" ${pomodoro_revamped_setting_name_raw} "*) printf '%s\n' "${pomodoro_revamped_setting_name_raw}" ;;
  *) printf '\n' ;;
  esac
}

pomodoro_revamped_bind() {
  case "$1" in
  "" | off) return 0 ;;
  *) ;;
  esac
  case " ${POMODORO_REVAMPED_BOUND} " in
  *" $1 "*)
    POMODORO_REVAMPED_SKIPPED="${POMODORO_REVAMPED_SKIPPED}${POMODORO_REVAMPED_SKIPPED:+ }$1"
    return 0
    ;;
  *) ;;
  esac
  POMODORO_REVAMPED_BOUND="${POMODORO_REVAMPED_BOUND} $1"
  pomodoro_revamped_bind_key="$1" pomodoro_revamped_bind_note="$2"
  shift 2
  set -- "${pomodoro_revamped_bind_key}" "$@"
  [ "${POMODORO_REVAMPED_NOTES}" != 1 ] || set -- -N "${pomodoro_revamped_bind_note}" "$@"
  pomodoro_revamped_emit bind-key "$@"
}

pomodoro_revamped_replaced() {
  printf '%s\n' "$1" | POMODORO_REVAMPED_PUT="$2" awk -v find="${POMODORO_REVAMPED_PLACEHOLDER}" '
    {
      out = ""
      line = $0
      while ((at = index(line, find)) > 0) {
        out = out substr(line, 1, at - 1) ENVIRON["POMODORO_REVAMPED_PUT"]
        line = substr(line, at + length(find))
      }
      print out line
    }
  '
}

pomodoro_revamped_number() {
  POMODORO_REVAMPED_NUMBER="$1"
  case "${POMODORO_REVAMPED_NUMBER}" in
  "" | *[!0-9]*) POMODORO_REVAMPED_NUMBER="$2" ;;
  *) ;;
  esac
  while [ "${#POMODORO_REVAMPED_NUMBER}" -gt 1 ] && [ "${POMODORO_REVAMPED_NUMBER#0}" != "${POMODORO_REVAMPED_NUMBER}" ]; do
    POMODORO_REVAMPED_NUMBER="${POMODORO_REVAMPED_NUMBER#0}"
  done
}

pomodoro_revamped_durations() {
  pomodoro_revamped_number "${POMODORO_REVAMPED_S_work}" 25
  POMODORO_REVAMPED_WORK_SECONDS=$((POMODORO_REVAMPED_NUMBER * 60))
  pomodoro_revamped_number "${POMODORO_REVAMPED_S_break}" 5
  POMODORO_REVAMPED_BREAK_SECONDS=$((POMODORO_REVAMPED_NUMBER * 60))
  pomodoro_revamped_number "${POMODORO_REVAMPED_S_long_break}" 15
  POMODORO_REVAMPED_LONG_SECONDS=$((POMODORO_REVAMPED_NUMBER * 60))
  pomodoro_revamped_number "${POMODORO_REVAMPED_S_intervals}" 4
  POMODORO_REVAMPED_ROUNDS="${POMODORO_REVAMPED_NUMBER}"
  [ "${POMODORO_REVAMPED_ROUNDS}" -gt 0 ] || POMODORO_REVAMPED_ROUNDS=4
  [ "${POMODORO_REVAMPED_ROUNDS}" -le "${POMODORO_REVAMPED_MAX_ROUNDS}" ] || POMODORO_REVAMPED_ROUNDS="${POMODORO_REVAMPED_MAX_ROUNDS}"
}

pomodoro_revamped_at() {
  POMODORO_REVAMPED_PHASE=work POMODORO_REVAMPED_REMAINING="${POMODORO_REVAMPED_WORK_SECONDS}" POMODORO_REVAMPED_INDEX=1
  pomodoro_revamped_at_round=$((POMODORO_REVAMPED_ROUNDS * POMODORO_REVAMPED_WORK_SECONDS + (POMODORO_REVAMPED_ROUNDS - 1) * POMODORO_REVAMPED_BREAK_SECONDS + POMODORO_REVAMPED_LONG_SECONDS))
  [ "${pomodoro_revamped_at_round}" -gt 0 ] || return 0
  pomodoro_revamped_at_left=$(($1 % pomodoro_revamped_at_round))
  pomodoro_revamped_at_turn=0
  while [ "${pomodoro_revamped_at_turn}" -lt "${POMODORO_REVAMPED_ROUNDS}" ]; do
    pomodoro_revamped_at_turn=$((pomodoro_revamped_at_turn + 1))
    POMODORO_REVAMPED_INDEX="${pomodoro_revamped_at_turn}"
    if [ "${pomodoro_revamped_at_left}" -lt "${POMODORO_REVAMPED_WORK_SECONDS}" ]; then
      POMODORO_REVAMPED_PHASE=work POMODORO_REVAMPED_REMAINING=$((POMODORO_REVAMPED_WORK_SECONDS - pomodoro_revamped_at_left))
      return 0
    fi
    pomodoro_revamped_at_left=$((pomodoro_revamped_at_left - POMODORO_REVAMPED_WORK_SECONDS))
    if [ "${pomodoro_revamped_at_turn}" -eq "${POMODORO_REVAMPED_ROUNDS}" ]; then
      POMODORO_REVAMPED_PHASE=long_break POMODORO_REVAMPED_REMAINING=$((POMODORO_REVAMPED_LONG_SECONDS - pomodoro_revamped_at_left))
      return 0
    fi
    if [ "${pomodoro_revamped_at_left}" -lt "${POMODORO_REVAMPED_BREAK_SECONDS}" ]; then
      POMODORO_REVAMPED_PHASE=break POMODORO_REVAMPED_REMAINING=$((POMODORO_REVAMPED_BREAK_SECONDS - pomodoro_revamped_at_left))
      return 0
    fi
    pomodoro_revamped_at_left=$((pomodoro_revamped_at_left - POMODORO_REVAMPED_BREAK_SECONDS))
  done
}

pomodoro_revamped_length() {
  case "${POMODORO_REVAMPED_PHASE}" in
  work) POMODORO_REVAMPED_LENGTH="${POMODORO_REVAMPED_WORK_SECONDS}" ;;
  break) POMODORO_REVAMPED_LENGTH="${POMODORO_REVAMPED_BREAK_SECONDS}" ;;
  *) POMODORO_REVAMPED_LENGTH="${POMODORO_REVAMPED_LONG_SECONDS}" ;;
  esac
}

pomodoro_revamped_now() {
  POMODORO_REVAMPED_NOW=$(date +%s 2>/dev/null) || POMODORO_REVAMPED_NOW=0
}

pomodoro_revamped_current() {
  [ -n "${POMODORO_REVAMPED_S_state}" ] || return 1
  pomodoro_revamped_durations
  pomodoro_revamped_number "${POMODORO_REVAMPED_S_start}" 0
  pomodoro_revamped_current_start="${POMODORO_REVAMPED_NUMBER}"
  pomodoro_revamped_number "${POMODORO_REVAMPED_S_paused_total}" 0
  pomodoro_revamped_current_held="${POMODORO_REVAMPED_NUMBER}"
  pomodoro_revamped_number "${POMODORO_REVAMPED_S_paused_at}" 0
  pomodoro_revamped_current_since="${POMODORO_REVAMPED_NUMBER}"
  [ "${POMODORO_REVAMPED_S_state}" = paused ] || pomodoro_revamped_current_since=0
  pomodoro_revamped_current_spent=$((POMODORO_REVAMPED_NOW - pomodoro_revamped_current_start - pomodoro_revamped_current_held))
  [ "${pomodoro_revamped_current_since}" -le 0 ] || pomodoro_revamped_current_spent=$((pomodoro_revamped_current_spent - (POMODORO_REVAMPED_NOW - pomodoro_revamped_current_since)))
  [ "${pomodoro_revamped_current_spent}" -ge 0 ] || pomodoro_revamped_current_spent=0
  pomodoro_revamped_at "${pomodoro_revamped_current_spent}"
  pomodoro_revamped_length
}

pomodoro_revamped_percent() {
  POMODORO_REVAMPED_PERCENT=0
  [ "$1" -gt 0 ] || return 0
  pomodoro_revamped_percent_left="$2"
  [ "${pomodoro_revamped_percent_left}" -ge 0 ] || pomodoro_revamped_percent_left=0
  [ "${pomodoro_revamped_percent_left}" -le "$1" ] || pomodoro_revamped_percent_left="$1"
  POMODORO_REVAMPED_PERCENT=$((($1 - pomodoro_revamped_percent_left) * 100 / $1))
}

pomodoro_revamped_bar() {
  POMODORO_REVAMPED_BAR=""
  pomodoro_revamped_number "${POMODORO_REVAMPED_S_progress_width}" 8
  pomodoro_revamped_bar_width="${POMODORO_REVAMPED_NUMBER}"
  [ "${pomodoro_revamped_bar_width}" -le "${POMODORO_REVAMPED_MAX_WIDTH}" ] || pomodoro_revamped_bar_width="${POMODORO_REVAMPED_MAX_WIDTH}"
  pomodoro_revamped_bar_on=$(($1 * pomodoro_revamped_bar_width / 100))
  pomodoro_revamped_bar_at=0
  while [ "${pomodoro_revamped_bar_at}" -lt "${pomodoro_revamped_bar_width}" ]; do
    if [ "${pomodoro_revamped_bar_at}" -lt "${pomodoro_revamped_bar_on}" ]; then
      POMODORO_REVAMPED_BAR="${POMODORO_REVAMPED_BAR}${POMODORO_REVAMPED_S_bar_filled}"
    else
      POMODORO_REVAMPED_BAR="${POMODORO_REVAMPED_BAR}${POMODORO_REVAMPED_S_bar_empty}"
    fi
    pomodoro_revamped_bar_at=$((pomodoro_revamped_bar_at + 1))
  done
}

pomodoro_revamped_counts() {
  pomodoro_revamped_counts_ifs="${IFS}"
  IFS=,
  set -f
  # shellcheck disable=SC2086
  set -- ${POMODORO_REVAMPED_S_week_counts:-0,0,0,0,0,0,0}
  set +f
  IFS="${pomodoro_revamped_counts_ifs}"
  pomodoro_revamped_counts_slot=$((((POMODORO_REVAMPED_NOW / POMODORO_REVAMPED_DAY) % 7 + 4) % 7))
  pomodoro_revamped_counts_top=0 pomodoro_revamped_counts_at=0
  POMODORO_REVAMPED_TODAY=0 POMODORO_REVAMPED_WEEK=""
  for pomodoro_revamped_counts_value in "$@"; do
    pomodoro_revamped_number "${pomodoro_revamped_counts_value}" 0
    [ "${POMODORO_REVAMPED_NUMBER}" -le "${pomodoro_revamped_counts_top}" ] || pomodoro_revamped_counts_top="${POMODORO_REVAMPED_NUMBER}"
    [ "${pomodoro_revamped_counts_at}" -ne "${pomodoro_revamped_counts_slot}" ] || POMODORO_REVAMPED_TODAY="${POMODORO_REVAMPED_NUMBER}"
    pomodoro_revamped_counts_at=$((pomodoro_revamped_counts_at + 1))
  done
  for pomodoro_revamped_counts_value in "$@"; do
    pomodoro_revamped_number "${pomodoro_revamped_counts_value}" 0
    pomodoro_revamped_counts_step=0
    [ "${pomodoro_revamped_counts_top}" -le 0 ] || pomodoro_revamped_counts_step=$((POMODORO_REVAMPED_NUMBER * 7 / pomodoro_revamped_counts_top))
    pomodoro_revamped_glyph "${pomodoro_revamped_counts_step}"
  done
}

pomodoro_revamped_glyph() {
  case "$1" in
  0) POMODORO_REVAMPED_WEEK="${POMODORO_REVAMPED_WEEK}_" ;;
  1) POMODORO_REVAMPED_WEEK="${POMODORO_REVAMPED_WEEK}." ;;
  2) POMODORO_REVAMPED_WEEK="${POMODORO_REVAMPED_WEEK}-" ;;
  3) POMODORO_REVAMPED_WEEK="${POMODORO_REVAMPED_WEEK}=" ;;
  4) POMODORO_REVAMPED_WEEK="${POMODORO_REVAMPED_WEEK}+" ;;
  5) POMODORO_REVAMPED_WEEK="${POMODORO_REVAMPED_WEEK}*" ;;
  6) POMODORO_REVAMPED_WEEK="${POMODORO_REVAMPED_WEEK}%" ;;
  *) POMODORO_REVAMPED_WEEK="${POMODORO_REVAMPED_WEEK}@" ;;
  esac
}

pomodoro_revamped_week_record() {
  printf '%s\n' "$1" | awk -F ',' -v last="$2" -v now="$3" '
    function slot(day) { return ((day % 7) + 4 + 7) % 7 }
    {
      for (i = 0; i < 7; i++) { count[i] = ($(i + 1) ~ /^[0-9]+$/) ? $(i + 1) + 0 : 0 }
      if (last ~ /^-?[0-9]+$/) {
        gap = now - last
        if (gap >= 7 || gap < 0) { for (i = 0; i < 7; i++) { count[i] = 0 } }
        for (day = last + 1; gap > 0 && gap < 7 && day <= now; day++) { count[slot(day)] = 0 }
      }
      count[slot(now)]++
      printf "%d,%d,%d,%d,%d,%d,%d\n", count[0], count[1], count[2], count[3], count[4], count[5], count[6]
    }
  '
}

pomodoro_revamped_clock() {
  date -r "$1" +%H:%M 2>/dev/null || date -d "@$1" +%H:%M 2>/dev/null || printf '??:??\n'
}

pomodoro_revamped_minutes() {
  POMODORO_REVAMPED_MINUTES=-1
  case "$1" in
  [0-9]:[0-9][0-9] | [0-9][0-9]:[0-9][0-9]) : ;;
  *) return 1 ;;
  esac
  pomodoro_revamped_number "${1%:*}" 0
  pomodoro_revamped_minutes_hours="${POMODORO_REVAMPED_NUMBER}"
  pomodoro_revamped_number "${1#*:}" 0
  POMODORO_REVAMPED_MINUTES=$((pomodoro_revamped_minutes_hours * 60 + POMODORO_REVAMPED_NUMBER))
}

pomodoro_revamped_quiet() {
  case "${POMODORO_REVAMPED_S_quiet_hours}" in
  *-*) : ;;
  *) return 1 ;;
  esac
  pomodoro_revamped_quiet_now=$(pomodoro_revamped_clock "${POMODORO_REVAMPED_NOW}")
  pomodoro_revamped_minutes "${pomodoro_revamped_quiet_now}" || return 1
  pomodoro_revamped_quiet_at="${POMODORO_REVAMPED_MINUTES}"
  pomodoro_revamped_minutes "${POMODORO_REVAMPED_S_quiet_hours%-*}" || return 1
  pomodoro_revamped_quiet_from="${POMODORO_REVAMPED_MINUTES}"
  pomodoro_revamped_minutes "${POMODORO_REVAMPED_S_quiet_hours#*-}" || return 1
  pomodoro_revamped_quiet_to="${POMODORO_REVAMPED_MINUTES}"
  if [ "${pomodoro_revamped_quiet_from}" -le "${pomodoro_revamped_quiet_to}" ]; then
    [ "${pomodoro_revamped_quiet_at}" -ge "${pomodoro_revamped_quiet_from}" ] && [ "${pomodoro_revamped_quiet_at}" -lt "${pomodoro_revamped_quiet_to}" ]
    return
  fi
  [ "${pomodoro_revamped_quiet_at}" -ge "${pomodoro_revamped_quiet_from}" ] || [ "${pomodoro_revamped_quiet_at}" -lt "${pomodoro_revamped_quiet_to}" ]
}

pomodoro_revamped_bell() {
  pomodoro_revamped_bell_ttys=$(tmux list-clients -F '#{client_tty}' 2>/dev/null) || pomodoro_revamped_bell_ttys=""
  while IFS= read -r pomodoro_revamped_bell_tty; do
    [ -n "${pomodoro_revamped_bell_tty}" ] || continue
    printf '\a' >>"${pomodoro_revamped_bell_tty}" 2>/dev/null || :
  done <<EOF
${pomodoro_revamped_bell_ttys}
EOF
}

pomodoro_revamped_notify() {
  [ "${POMODORO_REVAMPED_S_notify}" = 1 ] || return 0
  # shellcheck source=SCRIPTDIR/notify.sh
  . "${REVAMPED_LIB}/notify.sh"
  revamped_notify_send "${POMODORO_REVAMPED_TITLE}" "$1"
}

pomodoro_revamped_hook() {
  [ -n "$1" ] || return 0
  pomodoro_revamped_emit run-shell -b -- "$1"
}

pomodoro_revamped_hook_for() {
  case "$1" in
  work) pomodoro_revamped_hook "${POMODORO_REVAMPED_S_on_work}" ;;
  break) pomodoro_revamped_hook "${POMODORO_REVAMPED_S_on_break}" ;;
  *) pomodoro_revamped_hook "${POMODORO_REVAMPED_S_on_long_break}" ;;
  esac
}

pomodoro_revamped_alert() {
  ! pomodoro_revamped_quiet || return 0
  [ "${POMODORO_REVAMPED_S_bell}" != 1 ] || pomodoro_revamped_bell
  case "$1" in
  work) pomodoro_revamped_notify "Back to work" ;;
  break) pomodoro_revamped_notify "Take a short break" ;;
  *) pomodoro_revamped_notify "Take a long break" ;;
  esac
}

pomodoro_revamped_claim() {
  pomodoro_revamped_claim_id="$$-${POMODORO_REVAMPED_NOW}-$2"
  tmux if-shell -F "#{==:#{@pomodoro_revamped_last_phase},$1}" "set-option -gq @pomodoro_revamped_last_phase $2 ; set-option -gq @pomodoro_revamped_transition_claim ${pomodoro_revamped_claim_id}" 2>/dev/null || return 1
  pomodoro_revamped_claim_got=$(tmux show-option -gqv @pomodoro_revamped_transition_claim 2>/dev/null) || pomodoro_revamped_claim_got=""
  [ "${pomodoro_revamped_claim_got}" = "${pomodoro_revamped_claim_id}" ]
}

pomodoro_revamped_transition() {
  [ "${POMODORO_REVAMPED_S_last_phase}" != "${POMODORO_REVAMPED_PHASE}" ] || return 0
  pomodoro_revamped_claim "${POMODORO_REVAMPED_S_last_phase}" "${POMODORO_REVAMPED_PHASE}" || return 0
  pomodoro_revamped_emit set-option -gq @pomodoro_revamped_warned ""
  POMODORO_REVAMPED_S_warned=""
  [ -n "${POMODORO_REVAMPED_S_last_phase}" ] || return 0
  if [ "${POMODORO_REVAMPED_S_last_phase}" = work ]; then
    pomodoro_revamped_transition_day=$((POMODORO_REVAMPED_NOW / POMODORO_REVAMPED_DAY))
    POMODORO_REVAMPED_S_week_counts=$(pomodoro_revamped_week_record "${POMODORO_REVAMPED_S_week_counts:-0,0,0,0,0,0,0}" "${POMODORO_REVAMPED_S_week_day}" "${pomodoro_revamped_transition_day}")
    pomodoro_revamped_emit set-option -gq @pomodoro_revamped_week_counts "${POMODORO_REVAMPED_S_week_counts}"
    pomodoro_revamped_emit set-option -gq @pomodoro_revamped_week_day "${pomodoro_revamped_transition_day}"
  fi
  pomodoro_revamped_hook_for "${POMODORO_REVAMPED_PHASE}"
  [ "${POMODORO_REVAMPED_PHASE}" != long_break ] || pomodoro_revamped_hook "${POMODORO_REVAMPED_S_on_cycle}"
  pomodoro_revamped_alert "${POMODORO_REVAMPED_PHASE}"
}

pomodoro_revamped_warn() {
  [ "${POMODORO_REVAMPED_S_state}" != paused ] || return 0
  pomodoro_revamped_number "${POMODORO_REVAMPED_S_warn_seconds}" 0
  [ "${POMODORO_REVAMPED_NUMBER}" -gt 0 ] || return 0
  [ "${POMODORO_REVAMPED_REMAINING}" -gt 0 ] || return 0
  [ "${POMODORO_REVAMPED_REMAINING}" -le "${POMODORO_REVAMPED_NUMBER}" ] || return 0
  [ "${POMODORO_REVAMPED_S_warned}" != 1 ] || return 0
  pomodoro_revamped_emit set-option -gq @pomodoro_revamped_warned 1
  pomodoro_revamped_hook "${POMODORO_REVAMPED_S_on_warn}"
  ! pomodoro_revamped_quiet || return 0
  pomodoro_revamped_notify "Less than a minute left"
}

pomodoro_revamped_two() {
  POMODORO_REVAMPED_TWO="$1"
  [ "$1" -ge 10 ] || POMODORO_REVAMPED_TWO="0$1"
}

pomodoro_revamped_look() {
  case "${POMODORO_REVAMPED_PHASE}" in
  work) POMODORO_REVAMPED_COLOR="${POMODORO_REVAMPED_S_work_color}" POMODORO_REVAMPED_ICON="${POMODORO_REVAMPED_S_work_icon}" ;;
  break) POMODORO_REVAMPED_COLOR="${POMODORO_REVAMPED_S_break_color}" POMODORO_REVAMPED_ICON="${POMODORO_REVAMPED_S_break_icon}" ;;
  *) POMODORO_REVAMPED_COLOR="${POMODORO_REVAMPED_S_long_break_color}" POMODORO_REVAMPED_ICON="${POMODORO_REVAMPED_S_long_break_icon}" ;;
  esac
}

pomodoro_revamped_render() {
  pomodoro_revamped_render_left="${POMODORO_REVAMPED_REMAINING}"
  [ "${pomodoro_revamped_render_left}" -ge 0 ] || pomodoro_revamped_render_left=0
  pomodoro_revamped_two $((pomodoro_revamped_render_left / 60))
  pomodoro_revamped_render_text="${POMODORO_REVAMPED_TWO}"
  pomodoro_revamped_two $((pomodoro_revamped_render_left % 60))
  pomodoro_revamped_render_text="${pomodoro_revamped_render_text}:${POMODORO_REVAMPED_TWO}"
  [ "${POMODORO_REVAMPED_S_state}" != paused ] || pomodoro_revamped_render_text="${pomodoro_revamped_render_text}${POMODORO_REVAMPED_S_pause_text}"
  pomodoro_revamped_percent "${POMODORO_REVAMPED_LENGTH}" "${POMODORO_REVAMPED_REMAINING}"
  if [ "${POMODORO_REVAMPED_S_show_progress}" = 1 ] && [ "${POMODORO_REVAMPED_LENGTH}" -gt 0 ]; then
    pomodoro_revamped_bar "${POMODORO_REVAMPED_PERCENT}"
    pomodoro_revamped_render_text="${POMODORO_REVAMPED_BAR} ${pomodoro_revamped_render_text}"
  fi
  [ "${POMODORO_REVAMPED_S_show_interval}" != 1 ] || pomodoro_revamped_render_text="${pomodoro_revamped_render_text} [${POMODORO_REVAMPED_INDEX}/${POMODORO_REVAMPED_ROUNDS}]"
  [ "${POMODORO_REVAMPED_S_show_goal}" != 1 ] || pomodoro_revamped_render_text="${pomodoro_revamped_render_text} ${POMODORO_REVAMPED_TODAY}/${POMODORO_REVAMPED_S_goal}"
  if [ "${POMODORO_REVAMPED_S_show_finish}" = 1 ]; then
    pomodoro_revamped_render_end=$(pomodoro_revamped_clock $((POMODORO_REVAMPED_NOW + pomodoro_revamped_render_left)))
    pomodoro_revamped_render_text="${pomodoro_revamped_render_text} ends ${pomodoro_revamped_render_end}"
  fi
  pomodoro_revamped_look
  [ -z "${POMODORO_REVAMPED_ICON}" ] || pomodoro_revamped_render_text="${POMODORO_REVAMPED_ICON} ${pomodoro_revamped_render_text}"
  POMODORO_REVAMPED_SEGMENT="${POMODORO_REVAMPED_COLOR}${pomodoro_revamped_render_text}${POMODORO_REVAMPED_RESET}"
}

pomodoro_revamped_publish() {
  pomodoro_revamped_emit set-option -gq @pomodoro_revamped_status "${POMODORO_REVAMPED_SEGMENT}"
  pomodoro_revamped_emit set-option -gq @pomodoro_revamped_phase "${POMODORO_REVAMPED_PHASE}"
  pomodoro_revamped_emit set-option -gq @pomodoro_revamped_remaining "${POMODORO_REVAMPED_REMAINING}"
  pomodoro_revamped_emit set-option -gq @pomodoro_revamped_fraction "${POMODORO_REVAMPED_PERCENT}"
  pomodoro_revamped_emit set-option -gq @pomodoro_revamped_week "${POMODORO_REVAMPED_WEEK}"
  pomodoro_revamped_emit set-option -gq @pomodoro_revamped_today "${POMODORO_REVAMPED_TODAY}"
}

pomodoro_revamped_clear() {
  pomodoro_revamped_emit set-option -gq @pomodoro_revamped_status ""
  pomodoro_revamped_emit set-option -gq @pomodoro_revamped_phase ""
  pomodoro_revamped_emit set-option -gq @pomodoro_revamped_remaining ""
  pomodoro_revamped_emit set-option -gq @pomodoro_revamped_fraction ""
}

pomodoro_revamped_idle() {
  [ -n "${POMODORO_REVAMPED_S_status}" ] || return 0
  pomodoro_revamped_clear
  pomodoro_revamped_deliver
}

pomodoro_revamped_status() {
  pomodoro_revamped_load
  pomodoro_revamped_now
  POMODORO_REVAMPED_PLAN=""
  if ! pomodoro_revamped_current; then
    pomodoro_revamped_idle
    return 0
  fi
  pomodoro_revamped_transition
  pomodoro_revamped_warn
  pomodoro_revamped_counts
  pomodoro_revamped_render
  pomodoro_revamped_publish
  pomodoro_revamped_deliver || :
  printf '%s\n' "${POMODORO_REVAMPED_SEGMENT}"
}

pomodoro_revamped_begin() {
  pomodoro_revamped_load
  pomodoro_revamped_now
  POMODORO_REVAMPED_PLAN=""
}

pomodoro_revamped_toggle() {
  pomodoro_revamped_begin
  case "${POMODORO_REVAMPED_S_state}" in
  running)
    pomodoro_revamped_emit set-option -gq @pomodoro_revamped_state paused
    pomodoro_revamped_emit set-option -gq @pomodoro_revamped_paused_at "${POMODORO_REVAMPED_NOW}"
    ;;
  paused)
    pomodoro_revamped_number "${POMODORO_REVAMPED_S_paused_at}" 0
    pomodoro_revamped_toggle_since="${POMODORO_REVAMPED_NUMBER}"
    pomodoro_revamped_number "${POMODORO_REVAMPED_S_paused_total}" 0
    pomodoro_revamped_emit set-option -gq @pomodoro_revamped_paused_total $((POMODORO_REVAMPED_NUMBER + POMODORO_REVAMPED_NOW - pomodoro_revamped_toggle_since))
    pomodoro_revamped_emit set-option -gq @pomodoro_revamped_paused_at 0
    pomodoro_revamped_emit set-option -gq @pomodoro_revamped_state running
    ;;
  *)
    pomodoro_revamped_emit set-option -gq @pomodoro_revamped_state running
    pomodoro_revamped_emit set-option -gq @pomodoro_revamped_start "${POMODORO_REVAMPED_NOW}"
    pomodoro_revamped_emit set-option -gq @pomodoro_revamped_paused_total 0
    pomodoro_revamped_emit set-option -gq @pomodoro_revamped_paused_at 0
    pomodoro_revamped_emit set-option -gq @pomodoro_revamped_last_phase ""
    pomodoro_revamped_emit set-option -gq @pomodoro_revamped_warned ""
    ;;
  esac
  pomodoro_revamped_deliver
}

pomodoro_revamped_cancel() {
  POMODORO_REVAMPED_PLAN=""
  pomodoro_revamped_emit set-option -gq @pomodoro_revamped_state ""
  pomodoro_revamped_emit set-option -gq @pomodoro_revamped_last_phase ""
  pomodoro_revamped_clear
  pomodoro_revamped_deliver
}

pomodoro_revamped_skip() {
  pomodoro_revamped_begin
  pomodoro_revamped_current || return 0
  pomodoro_revamped_number "${POMODORO_REVAMPED_S_start}" 0
  pomodoro_revamped_emit set-option -gq @pomodoro_revamped_start $((POMODORO_REVAMPED_NUMBER - POMODORO_REVAMPED_REMAINING))
  pomodoro_revamped_deliver
}

pomodoro_revamped_restart() {
  pomodoro_revamped_begin
  pomodoro_revamped_current || return 0
  pomodoro_revamped_number "${POMODORO_REVAMPED_S_start}" 0
  pomodoro_revamped_emit set-option -gq @pomodoro_revamped_start $((POMODORO_REVAMPED_NUMBER + POMODORO_REVAMPED_LENGTH - POMODORO_REVAMPED_REMAINING))
  pomodoro_revamped_emit set-option -gq @pomodoro_revamped_warned ""
  pomodoro_revamped_deliver
}

pomodoro_revamped_job_quote() {
  printf '%s\n' "$1" | sed -e "s/'/'\\\\''/g" -e 's/#/##/g' -e 's/%/%%/g' -e "1s/^/'/" -e "\$s/\$/'/"
}

pomodoro_revamped_carried() {
  pomodoro_revamped_carried_set=$(env | sed -n 's/^POMODORO_REVAMPED_\([A-Z_]*\)=\(.*\)$/\1 \2/p')
  [ -n "${pomodoro_revamped_carried_set}" ] || return 0
  printf '%s\n' "${pomodoro_revamped_carried_set}" | POMODORO_REVAMPED_WANTED="${POMODORO_REVAMPED_CARRIED}" awk '
    BEGIN { count = split(ENVIRON["POMODORO_REVAMPED_WANTED"], name, " "); for (i = 1; i <= count; i++) { wanted[toupper(name[i])] = i } }
    {
      key = $1
      if (!(key in wanted)) { next }
      given[wanted[key]] = 1
      value[wanted[key]] = substr($0, length(key) + 2)
    }
    END {
      for (i = 1; i <= count; i++) {
        if (!given[i]) { continue }
        flag = name[i]
        gsub(/_/, "-", flag)
        print flag "\t" value[i]
      }
    }
  '
}

pomodoro_revamped_tools() {
  pomodoro_revamped_tools_path="${REVAMPED_LIB%/lib}/bin/pomodoro-revamped"
  POMODORO_REVAMPED_TOOL=$(pomodoro_revamped_literal "${pomodoro_revamped_tools_path}")
  POMODORO_REVAMPED_JOB=$(pomodoro_revamped_job_quote "${pomodoro_revamped_tools_path}")
  pomodoro_revamped_tools_rows=$(pomodoro_revamped_carried)
  while IFS='	' read -r pomodoro_revamped_tools_flag pomodoro_revamped_tools_value; do
    [ -n "${pomodoro_revamped_tools_flag}" ] || continue
    POMODORO_REVAMPED_TOOL="${POMODORO_REVAMPED_TOOL} --${pomodoro_revamped_tools_flag} $(pomodoro_revamped_literal "${pomodoro_revamped_tools_value}")"
    POMODORO_REVAMPED_JOB="${POMODORO_REVAMPED_JOB} --${pomodoro_revamped_tools_flag} $(pomodoro_revamped_job_quote "${pomodoro_revamped_tools_value}")"
  done <<EOF
${pomodoro_revamped_tools_rows}
EOF
}

pomodoro_revamped_held() {
  tmux list-keys -T prefix 2>/dev/null | awk '
    {
      at = 2
      if ($at == "-r") { at++ }
      if ($at == "-T") { at += 2 }
      key = $at
      if (key ~ /^\\./) { key = substr(key, 2) }
      rest = ""
      for (i = at + 1; i <= NF; i++) { rest = rest " " $i }
      if (index(rest, "pomodoro-revamped") == 0) { printf "%s ", key }
    }
  '
}

pomodoro_revamped_plan_keys() {
  case "${POMODORO_REVAMPED_S_toggle_key}: ${POMODORO_REVAMPED_KEYS} " in
  "${POMODORO_REVAMPED_DEFAULT_TOGGLE_KEY}:"*" ${POMODORO_REVAMPED_DEFAULT_TOGGLE_KEY} "*) POMODORO_REVAMPED_SKIPPED="${POMODORO_REVAMPED_DEFAULT_TOGGLE_KEY}" ;;
  *) pomodoro_revamped_bind "${POMODORO_REVAMPED_S_toggle_key}" "Start or pause" run-shell "${POMODORO_REVAMPED_TOOL} toggle" ;;
  esac
  pomodoro_revamped_bind "${POMODORO_REVAMPED_S_cancel_key}" "Cancel" run-shell "${POMODORO_REVAMPED_TOOL} cancel"
  pomodoro_revamped_bind "${POMODORO_REVAMPED_S_skip_key}" "Skip phase" run-shell "${POMODORO_REVAMPED_TOOL} skip"
  pomodoro_revamped_bind "${POMODORO_REVAMPED_S_restart_key}" "Restart phase" run-shell "${POMODORO_REVAMPED_TOOL} restart"
  pomodoro_revamped_plan_keys_tool=$(pomodoro_revamped_tmux_string "${POMODORO_REVAMPED_TOOL}")
  pomodoro_revamped_bind "${POMODORO_REVAMPED_S_menu_key}" "Pomodoro menu" display-menu -T "${POMODORO_REVAMPED_TITLE}" "Start / Pause" "" "run-shell \"${pomodoro_revamped_plan_keys_tool} toggle\"" "Skip phase" "" "run-shell \"${pomodoro_revamped_plan_keys_tool} skip\"" "Restart phase" "" "run-shell \"${pomodoro_revamped_plan_keys_tool} restart\"" Cancel "" "run-shell \"${pomodoro_revamped_plan_keys_tool} cancel\""
  pomodoro_revamped_bind "${POMODORO_REVAMPED_S_help_key}" "Pomodoro help" display-popup -E -w 90% -h 90% "if command -v less >/dev/null 2>&1; then ${POMODORO_REVAMPED_TOOL} help | less; else ${POMODORO_REVAMPED_TOOL} help; read -r pomodoro_revamped_wait; fi"
}

pomodoro_revamped_plan_status() {
  for pomodoro_revamped_plan_status_option in status-left status-right; do
    pomodoro_revamped_plan_status_now=$(tmux show-option -gqv "${pomodoro_revamped_plan_status_option}" 2>/dev/null) || pomodoro_revamped_plan_status_now=""
    case "${pomodoro_revamped_plan_status_now}" in
    *"${POMODORO_REVAMPED_PLACEHOLDER}"*) pomodoro_revamped_plan_status_new=$(pomodoro_revamped_replaced "${pomodoro_revamped_plan_status_now}" "#(${POMODORO_REVAMPED_JOB} status)") ;;
    *) continue ;;
    esac
    pomodoro_revamped_emit set-option -gq "${pomodoro_revamped_plan_status_option}" "${pomodoro_revamped_plan_status_new}"
  done
}

pomodoro_revamped_plan() {
  pomodoro_revamped_load
  pomodoro_revamped_plan_raw=$(tmux -V 2>/dev/null) || pomodoro_revamped_plan_raw=""
  POMODORO_REVAMPED_TMUX=$(pomodoro_revamped_parse_version "${pomodoro_revamped_plan_raw}")
  POMODORO_REVAMPED_NOTES=0
  ! pomodoro_revamped_version_ge "${POMODORO_REVAMPED_TMUX}" "${POMODORO_REVAMPED_NOTES_SINCE}" || POMODORO_REVAMPED_NOTES=1
  pomodoro_revamped_tools
  POMODORO_REVAMPED_KEYS=$(pomodoro_revamped_held)
  POMODORO_REVAMPED_PLAN="" POMODORO_REVAMPED_SKIPPED="" POMODORO_REVAMPED_BOUND=""
  pomodoro_revamped_plan_keys
  pomodoro_revamped_plan_status
}

pomodoro_revamped_apply() {
  pomodoro_revamped_plan
  pomodoro_revamped_deliver
}
