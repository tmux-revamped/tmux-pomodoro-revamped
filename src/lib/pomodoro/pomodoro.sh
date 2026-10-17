#!/usr/bin/env bash

[[ -n "${_POMODORO_REVAMPED_LOADED:-}" ]] && return 0
_POMODORO_REVAMPED_LOADED=1

pomodoro_format() {
  local s="${1}"
  [[ "${s}" =~ ^-?[0-9]+$ ]] || s=0
  (( s < 0 )) && s=0
  printf '%02d:%02d' "$(( s / 60 ))" "$(( s % 60 ))"
}

pomodoro_phase_at() {
  local e="${1}" w="${2}" b="${3}" l="${4}" n="${5}"
  (( e < 0 )) && e=0
  local round=$(( n * w + (n - 1) * b + l ))
  (( round <= 0 )) && { echo "work ${w} 1"; return 0; }
  local pos=$(( e % round )) i=0
  while (( i < n )); do
    i=$(( i + 1 ))
    if (( pos < w )); then echo "work $(( w - pos )) ${i}"; return 0; fi
    pos=$(( pos - w ))
    if (( i == n )); then echo "long_break $(( l - pos )) ${i}"; return 0; fi
    if (( pos < b )); then echo "break $(( b - pos )) ${i}"; return 0; fi
    pos=$(( pos - b ))
  done
  echo "work ${w} 1"
}

pomodoro_elapsed() {
  local now="${1}" start="${2}" paused_total="${3}" paused_at="${4}"
  local e=$(( now - start - paused_total ))
  (( paused_at > 0 )) && e=$(( e - (now - paused_at) ))
  (( e < 0 )) && e=0
  echo "${e}"
}

pomodoro_percent() {
  local len="${1}" rem="${2}"
  [[ "${len}" =~ ^[0-9]+$ ]] || len=0
  [[ "${rem}" =~ ^-?[0-9]+$ ]] || rem=0
  (( len <= 0 )) && { echo 0; return 0; }
  (( rem < 0 )) && rem=0
  (( rem > len )) && rem=len
  echo $(( (len - rem) * 100 / len ))
}

pomodoro_bar() {
  local pct="${1}" width="${2}" filled="${3:-#}" empty="${4:--}"
  [[ "${pct}" =~ ^[0-9]+$ ]] || pct=0
  [[ "${width}" =~ ^[0-9]+$ ]] || width=8
  (( pct > 100 )) && pct=100
  (( width <= 0 )) && { echo ""; return 0; }
  local on=$(( pct * width / 100 )) i out=""
  for (( i = 0; i < width; i++ )); do
    if (( i < on )); then out="${out}${filled}"; else out="${out}${empty}"; fi
  done
  echo "${out}"
}

pomodoro_sparkline() {
  local ramp='_.-=+*%@' max=0 v out='' idx
  for v in "$@"; do
    [[ "${v}" =~ ^[0-9]+$ ]] || v=0
    (( v > max )) && max="${v}"
  done
  for v in "$@"; do
    [[ "${v}" =~ ^[0-9]+$ ]] || v=0
    idx=0
    (( max > 0 )) && idx=$(( v * 7 / max ))
    out="${out}${ramp:idx:1}"
  done
  echo "${out}"
}

pomodoro_hm_to_min() {
  local hm="${1}"
  echo $(( 10#${hm%:*} * 60 + 10#${hm#*:} ))
}

pomodoro_in_quiet() {
  local now="${1}" win="${2}"
  [[ "${now}" =~ ^[0-9]{1,2}:[0-9]{2}$ ]] || return 1
  [[ "${win}" == *-* ]] || return 1
  local start="${win%-*}" end="${win#*-}"
  [[ "${start}" =~ ^[0-9]{1,2}:[0-9]{2}$ ]] || return 1
  [[ "${end}" =~ ^[0-9]{1,2}:[0-9]{2}$ ]] || return 1
  local n s e
  n=$(pomodoro_hm_to_min "${now}")
  s=$(pomodoro_hm_to_min "${start}")
  e=$(pomodoro_hm_to_min "${end}")
  if (( s <= e )); then
    (( n >= s && n < e )) && return 0
    return 1
  fi
  (( n >= s || n < e )) && return 0
  return 1
}

pomodoro_week_index() {
  local d="${1}"
  [[ "${d}" =~ ^-?[0-9]+$ ]] || d=0
  echo $(( ( (d % 7) + 4 + 7 ) % 7 ))
}

pomodoro_week_today() {
  local counts="${1}" idx="${2}"
  [[ "${idx}" =~ ^[0-9]+$ ]] || idx=0
  local oldifs="${IFS}"
  IFS=','
  # shellcheck disable=SC2206
  local arr=(${counts})
  IFS="${oldifs}"
  local v="${arr[idx]:-0}"
  [[ "${v}" =~ ^[0-9]+$ ]] || v=0
  echo "${v}"
}

pomodoro_week_record() {
  local counts="${1}" last="${2}" cur="${3}"
  [[ "${cur}" =~ ^-?[0-9]+$ ]] || cur=0
  local oldifs="${IFS}"
  IFS=','
  # shellcheck disable=SC2206
  local arr=(${counts})
  IFS="${oldifs}"
  local i
  for i in 0 1 2 3 4 5 6; do
    [[ "${arr[i]:-}" =~ ^[0-9]+$ ]] || arr[i]=0
  done
  if [[ "${last}" =~ ^-?[0-9]+$ ]]; then
    local gap=$(( cur - last ))
    if (( gap >= 7 || gap < 0 )); then
      for i in 0 1 2 3 4 5 6; do arr[i]=0; done
    elif (( gap > 0 )); then
      local d zi
      for (( d = last + 1; d <= cur; d++ )); do
        zi=$(pomodoro_week_index "${d}")
        arr[zi]=0
      done
    fi
  fi
  local ci
  ci=$(pomodoro_week_index "${cur}")
  arr[ci]=$(( arr[ci] + 1 ))
  local out="${arr[0]}"
  for i in 1 2 3 4 5 6; do out="${out},${arr[i]}"; done
  echo "${out} ${cur}"
}

export -f pomodoro_format
export -f pomodoro_phase_at
export -f pomodoro_elapsed
export -f pomodoro_percent
export -f pomodoro_bar
export -f pomodoro_sparkline
export -f pomodoro_hm_to_min
export -f pomodoro_in_quiet
export -f pomodoro_week_index
export -f pomodoro_week_today
export -f pomodoro_week_record
