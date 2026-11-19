#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/pomodoro_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/pomodoro_helpers.bash"

@test "pomodoro - a number drops its leading zeros and junk takes the fallback" {
  # Arrange
  local script='for given in 007 abc "" 0 12x 000; do pomodoro_revamped_number "${given}" 5; printf "%s\n" "${POMODORO_REVAMPED_NUMBER}"; done'

  # Act
  lib_run pomodoro "${script}"

  # Assert
  [[ "${output}" == $'7\n5\n5\n0\n5\n0' ]]
}

@test "pomodoro - durations come from the settings in seconds, with junk and zero rounds on the defaults" {
  # Arrange
  local script='POMODORO_REVAMPED_S_work=50 POMODORO_REVAMPED_S_break=x POMODORO_REVAMPED_S_long_break=020 POMODORO_REVAMPED_S_intervals=0; pomodoro_revamped_durations; printf "%s %s %s %s\n" "${POMODORO_REVAMPED_WORK_SECONDS}" "${POMODORO_REVAMPED_BREAK_SECONDS}" "${POMODORO_REVAMPED_LONG_SECONDS}" "${POMODORO_REVAMPED_ROUNDS}"'

  # Act
  lib_run pomodoro "${script}"

  # Assert
  [[ "${output}" == "3000 300 1200 4" ]]
}

@test "pomodoro - more rounds than the cap are held at the cap" {
  # Arrange
  local script='POMODORO_REVAMPED_S_intervals=5000; pomodoro_revamped_durations; printf "%s\n" "${POMODORO_REVAMPED_ROUNDS}"'

  # Act
  lib_run pomodoro "${script}"

  # Assert
  [[ "${output}" == "100" ]]
}

@test "pomodoro - the phase walks work and breaks, reaches the long break after the last work and wraps" {
  # Arrange
  local script='pomodoro_revamped_durations; for spent in 0 1499 1500 1799 1800 5399 5400 6900 7799 7800; do pomodoro_revamped_at "${spent}"; pomodoro_revamped_length; printf "%s %s %s %s\n" "${POMODORO_REVAMPED_PHASE}" "${POMODORO_REVAMPED_REMAINING}" "${POMODORO_REVAMPED_INDEX}" "${POMODORO_REVAMPED_LENGTH}"; done'

  # Act
  lib_run pomodoro "${script}"

  # Assert
  [[ "${lines[0]}" == "work 1500 1 1500" ]]
  [[ "${lines[1]}" == "work 1 1 1500" ]]
  [[ "${lines[2]}" == "break 300 1 300" ]]
  [[ "${lines[3]}" == "break 1 1 300" ]]
  [[ "${lines[4]}" == "work 1500 2 1500" ]]
  [[ "${lines[5]}" == "break 1 3 300" ]]
  [[ "${lines[6]}" == "work 1500 4 1500" ]]
  [[ "${lines[7]}" == "long_break 900 4 900" ]]
  [[ "${lines[8]}" == "long_break 1 4 900" ]]
  [[ "${lines[9]}" == "work 1500 1 1500" ]]
}

@test "pomodoro - a round of no length stays on the first work period" {
  # Arrange
  local script='POMODORO_REVAMPED_S_work=0 POMODORO_REVAMPED_S_break=0 POMODORO_REVAMPED_S_long_break=0; pomodoro_revamped_durations; pomodoro_revamped_at 5; printf "%s %s %s\n" "${POMODORO_REVAMPED_PHASE}" "${POMODORO_REVAMPED_REMAINING}" "${POMODORO_REVAMPED_INDEX}"'

  # Act
  lib_run pomodoro "${script}"

  # Assert
  [[ "${output}" == "work 0 1" ]]
}

@test "pomodoro - an idle timer has no current phase" {
  # Arrange
  local script='pomodoro_revamped_load; pomodoro_revamped_now; pomodoro_revamped_current && printf "running\n" || printf "idle\n"'

  # Act
  lib_run pomodoro "${script}"

  # Assert
  [[ "${output}" == "idle" ]]
}

@test "pomodoro - the time spent leaves out every pause, the one under way included, and never goes negative" {
  # Arrange
  option state paused
  option start 999000
  option paused_total 100
  option paused_at 999800
  local script='pomodoro_revamped_load; pomodoro_revamped_now; pomodoro_revamped_current; printf "%s %s\n" "${POMODORO_REVAMPED_PHASE}" "${POMODORO_REVAMPED_REMAINING}"; POMODORO_REVAMPED_S_start=2000000; pomodoro_revamped_current; printf "%s %s\n" "${POMODORO_REVAMPED_PHASE}" "${POMODORO_REVAMPED_REMAINING}"; POMODORO_REVAMPED_S_state=running POMODORO_REVAMPED_S_start=999000; pomodoro_revamped_current; printf "%s %s\n" "${POMODORO_REVAMPED_PHASE}" "${POMODORO_REVAMPED_REMAINING}"'

  # Act
  lib_run pomodoro "${script}"

  # Assert
  [[ "${lines[0]}" == "work 800" ]]
  [[ "${lines[1]}" == "work 1500" ]]
  [[ "${lines[2]}" == "work 600" ]]
}

@test "pomodoro - the percent done is whole and guarded at both ends" {
  # Arrange
  local script='for pair in "1500 1500" "1500 750" "1500 0" "1500 -5" "1500 9999" "0 10"; do set -- ${pair}; pomodoro_revamped_percent "$1" "$2"; printf "%s\n" "${POMODORO_REVAMPED_PERCENT}"; done'

  # Act
  lib_run pomodoro "${script}"

  # Assert
  [[ "${output}" == $'0\n50\n100\n100\n0\n0' ]]
}

@test "pomodoro - the bar fills in proportion, with the glyphs and width the settings give" {
  # Arrange
  local script='pomodoro_revamped_bar 50; printf "[%s]\n" "${POMODORO_REVAMPED_BAR}"; POMODORO_REVAMPED_S_progress_width=4 POMODORO_REVAMPED_S_bar_filled== POMODORO_REVAMPED_S_bar_empty=.; pomodoro_revamped_bar 75; printf "[%s]\n" "${POMODORO_REVAMPED_BAR}"; POMODORO_REVAMPED_S_progress_width=0; pomodoro_revamped_bar 75; printf "[%s]\n" "${POMODORO_REVAMPED_BAR}"; POMODORO_REVAMPED_S_progress_width=9999; pomodoro_revamped_bar 0; printf "%s\n" "${#POMODORO_REVAMPED_BAR}"'

  # Act
  lib_run pomodoro "${script}"

  # Assert
  [[ "${lines[0]}" == "[####----]" ]]
  [[ "${lines[1]}" == "[===.]" ]]
  [[ "${lines[2]}" == "[]" ]]
  [[ "${lines[3]}" == "200" ]]
}

@test "pomodoro - the week is drawn against its busiest day and today is read from its slot" {
  # Arrange
  local script='POMODORO_REVAMPED_NOW=1000000 POMODORO_REVAMPED_S_week_counts=0,1,2,3,4,5,7; pomodoro_revamped_counts; printf "%s %s\n" "${POMODORO_REVAMPED_WEEK}" "${POMODORO_REVAMPED_TODAY}"; POMODORO_REVAMPED_S_week_counts=6,7,x,0,0,0,0; pomodoro_revamped_counts; printf "%s %s\n" "${POMODORO_REVAMPED_WEEK}" "${POMODORO_REVAMPED_TODAY}"; POMODORO_REVAMPED_S_week_counts=; pomodoro_revamped_counts; printf "%s %s\n" "${POMODORO_REVAMPED_WEEK}" "${POMODORO_REVAMPED_TODAY}"'

  # Act
  lib_run pomodoro "${script}"

  # Assert
  [[ "${lines[0]}" == "_.-=+*@ 1" ]]
  [[ "${lines[1]}" == "%@_____ 7" ]]
  [[ "${lines[2]}" == "_______ 0" ]]
}

@test "pomodoro - a finished work period is counted on its day, and days gone by are emptied" {
  # Arrange
  local script='pomodoro_revamped_week_record 0,0,0,0,0,0,0 "" 11; pomodoro_revamped_week_record 0,2,0,0,0,0,0 11 11; pomodoro_revamped_week_record 1,2,3,4,5,6,7 11 13; pomodoro_revamped_week_record 1,2,3,4,5,6,7 11 18; pomodoro_revamped_week_record 1,2,3,4,5,6,7 11 9; pomodoro_revamped_week_record x,2 junk 11'

  # Act
  lib_run pomodoro "${script}"

  # Assert
  [[ "${lines[0]}" == "0,1,0,0,0,0,0" ]]
  [[ "${lines[1]}" == "0,3,0,0,0,0,0" ]]
  [[ "${lines[2]}" == "1,2,0,1,5,6,7" ]]
  [[ "${lines[3]}" == "0,1,0,0,0,0,0" ]]
  [[ "${lines[4]}" == "0,0,0,0,0,0,1" ]]
  [[ "${lines[5]}" == "0,3,0,0,0,0,0" ]]
}

@test "pomodoro - the clock asks date by -r, then by -d, and shows question marks when neither answers" {
  # Arrange
  clock 09:05
  local script='pomodoro_revamped_clock 1000000; : >"${FAKE}/no-r"; pomodoro_revamped_clock 1000000; : >"${FAKE}/no-d"; pomodoro_revamped_clock 1000000'

  # Act
  lib_run pomodoro "${script}"

  # Assert
  [[ "${output}" == $'09:05\n09:05\n??:??' ]]
  run cat "${FAKE}/clock-asked"
  [[ "${output}" == $'-r 1000000 +%H:%M\n-d @1000000 +%H:%M' ]]
}

@test "pomodoro - a time of day becomes minutes, leading zeros and all, and anything else is refused" {
  # Arrange
  local script='for given in 08:05 9:30 23:59 0:00 8h 12:5 "" 123:00; do pomodoro_revamped_minutes "${given}" && printf "%s\n" "${POMODORO_REVAMPED_MINUTES}" || printf "refused\n"; done'

  # Act
  lib_run pomodoro "${script}"

  # Assert
  [[ "${output}" == $'485\n570\n1439\n0\nrefused\nrefused\nrefused\nrefused' ]]
}

@test "pomodoro - quiet hours cover a window in one day and one that wraps past midnight" {
  # Arrange
  local script='quiet() { POMODORO_REVAMPED_S_quiet_hours="$2"; printf "%s\n" "$1" >"${FAKE}/clock"; pomodoro_revamped_quiet && printf "quiet\n" || printf "loud\n"; }; quiet 10:30 09:00-12:00; quiet 12:00 09:00-12:00; quiet 08:59 09:00-12:00; quiet 23:10 22:00-08:00; quiet 07:59 22:00-08:00; quiet 12:00 22:00-08:00'

  # Act
  lib_run pomodoro "${script}"

  # Assert
  [[ "${output}" == $'quiet\nloud\nloud\nquiet\nquiet\nloud' ]]
}

@test "pomodoro - quiet hours that cannot be read are never quiet" {
  # Arrange
  local script='quiet() { POMODORO_REVAMPED_S_quiet_hours="$2"; printf "%s\n" "$1" >"${FAKE}/clock"; pomodoro_revamped_quiet && printf "quiet\n" || printf "loud\n"; }; quiet 10:30 ""; quiet 10:30 always; quiet 10:30 nine-12:00; quiet 10:30 09:00-noon; quiet now 09:00-12:00'

  # Act
  lib_run pomodoro "${script}"

  # Assert
  [[ "${output}" == $'loud\nloud\nloud\nloud\nloud' ]]
}

@test "pomodoro - a setting comes from its default, then the tmux option, then the environment" {
  # Arrange
  option work 30
  option break 7
  export POMODORO_REVAMPED_BREAK=9
  local script='pomodoro_revamped_load; printf "%s %s %s [%s] [%s]\n" "${POMODORO_REVAMPED_S_work}" "${POMODORO_REVAMPED_S_break}" "${POMODORO_REVAMPED_S_long_break}" "${POMODORO_REVAMPED_S_pause_text}" "${POMODORO_REVAMPED_S_state}"'

  # Act
  lib_run pomodoro "${script}"

  # Assert
  [[ "${output}" == "30 9 15 [ paused] []" ]]
}

@test "pomodoro - the settings and the timer's state are read in one tmux call" {
  # Arrange
  running_since 999000
  local script='pomodoro_revamped_load; printf "%s %s\n" "${POMODORO_REVAMPED_S_state}" "${POMODORO_REVAMPED_S_start}"'

  # Act
  lib_run pomodoro "${script}"

  # Assert
  [[ "${output}" == "running 999000" ]]
  run cat "${FAKE}/log"
  [[ "${#lines[@]}" -eq 1 ]]
  [[ "${lines[0]}" == "display-message -p #{@pomodoro_revamped_toggle_key}"* ]]
  [[ "${lines[0]}" == *"#{@pomodoro_revamped_status}" ]]
}

@test "pomodoro - an argument that ends in a semicolon is escaped, and an empty one is kept" {
  # Arrange
  local script='POMODORO_REVAMPED_PLAN=""; pomodoro_revamped_emit run-shell -b -- "say done;"; pomodoro_revamped_emit set-option -gq @x ""; pomodoro_revamped_lines; pomodoro_revamped_json'

  # Act
  lib_run pomodoro "${script}"

  # Assert
  [[ "${lines[0]}" == 'run-shell -b -- say done\;' ]]
  [[ "${lines[1]}" == 'set-option -gq @x ""' ]]
  [[ "${lines[2]}" == '{"bindings":[["run-shell","-b","--","say done\\;"],["set-option","-gq","@x",""]]}' ]]
}

@test "pomodoro - a path is quoted for a shell, with a hash and a percent sign doubled for the status line and the hash hidden from a popup" {
  # Arrange
  local script='pomodoro_revamped_job_quote "/a b/it'"'"'s #1 50%/tool"; pomodoro_revamped_literal "/a b/it'"'"'s #1 50%/tool"; pomodoro_revamped_tmux_string "say \"\$HOME\" \\ end"'

  # Act
  lib_run pomodoro "${script}"

  # Assert
  [[ "${lines[0]}" == "'/a b/it'\\''s ##1 50%%/tool'" ]]
  [[ "${lines[1]}" == "'/a b/it'\\''s '\"\$(printf '%b' '\\0043')\"'1 50%/tool'" ]]
  [[ "${lines[2]}" == 'say \"\$HOME\" \\ end' ]]
}

@test "pomodoro - a long option names its setting, and an unknown one names nothing" {
  # Arrange
  local script='for given in --show-progress --work --bogus --state; do printf "[%s]\n" "$(pomodoro_revamped_setting_name "${given}")"; done'

  # Act
  lib_run pomodoro "${script}"

  # Assert
  [[ "${output}" == $'[show_progress]\n[work]\n[]\n[]' ]]
}

@test "pomodoro - a tmux version is read out of its banner and compared part by part" {
  # Arrange
  local script='for banner in "tmux 3.6a" "tmux next-3.7" "nonsense"; do printf "[%s]" "$(pomodoro_revamped_parse_version "${banner}")"; done; for pair in "3.6 3.2" "3.2 3.2" "3.1 3.2" "4.0 3.2" "2.9 3.2" " 3.2" "x 3.2"; do if pomodoro_revamped_version_ge ${pair}; then printf y; else printf n; fi; done'

  # Act
  lib_run pomodoro "${script}"

  # Assert
  [[ "${output}" == "[3.6][3.7][]yynynnn" ]]
}
