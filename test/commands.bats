#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/pomodoro_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/pomodoro_helpers.bash"

PUBLISHED_WORK='set-option -gq @pomodoro_revamped_status #[fg=red]15:00 [1/4]#[default] ; set-option -gq @pomodoro_revamped_phase work ; set-option -gq @pomodoro_revamped_remaining 900 ; set-option -gq @pomodoro_revamped_fraction 40 ; set-option -gq @pomodoro_revamped_week _______ ; set-option -gq @pomodoro_revamped_today 0'
PUBLISHED_BREAK='set-option -gq @pomodoro_revamped_status #[fg=green]05:00 [1/4]#[default] ; set-option -gq @pomodoro_revamped_phase break ; set-option -gq @pomodoro_revamped_remaining 300 ; set-option -gq @pomodoro_revamped_fraction 0 ; set-option -gq @pomodoro_revamped_week _@_____ ; set-option -gq @pomodoro_revamped_today 1'
CLEARED='set-option -gq @pomodoro_revamped_status  ; set-option -gq @pomodoro_revamped_phase  ; set-option -gq @pomodoro_revamped_remaining  ; set-option -gq @pomodoro_revamped_fraction '

@test "status - an idle timer prints nothing and writes nothing" {
  # Arrange
  local writes

  # Act
  tool status

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "" ]]
  writes=$(sends)
  [[ "${writes}" == "" ]]
}

@test "status - an idle timer clears what the last run published, once" {
  # Arrange
  local writes
  option status '#[fg=red]old#[default]'

  # Act
  tool status

  # Assert
  [[ "${output}" == "" ]]
  writes=$(sends)
  [[ "${writes}" == "${CLEARED}" ]]
  tool status
  writes=$(sends)
  [[ "${writes}" == "${CLEARED}" ]]
}

@test "status - a running timer prints the countdown and publishes it in one tmux call, with no claim while the phase holds" {
  # Arrange
  local writes claims
  running_since 999400

  # Act
  tool status

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == '#[fg=red]15:00 [1/4]#[default]' ]]
  writes=$(sends)
  [[ "${writes}" == "${PUBLISHED_WORK}" ]]
  claims=$(sent '^if-shell')
  [[ "${claims}" == "0" ]]
}

@test "status - a paused timer holds its time and says so" {
  # Arrange
  option state paused
  option start 999400
  option paused_total 0
  option paused_at 1000000
  option last_phase work
  now 1000500

  # Act
  tool --pause-text ' (held)' status

  # Assert
  [[ "${output}" == '#[fg=red]15:00 (held) [1/4]#[default]' ]]
}

@test "status - the bar, the goal, the finish time and the icon show when asked, and the counter can be hidden" {
  # Arrange
  running_since 999400
  option show_progress 1
  option show_goal 1
  option show_finish 1
  option show_interval 0
  option work_icon T
  clock 10:45

  # Act
  tool status

  # Assert
  [[ "${output}" == '#[fg=red]T ###----- 15:00 0/6 ends 10:45#[default]' ]]
  run cat "${FAKE}/clock-asked"
  [[ "${output}" == "-r 1000900 +%H:%M" ]]
}

@test "status - a break and the long break take their own style and icon" {
  # Arrange
  local short
  option break_icon B
  option long_break_icon L
  option long_break_color '#[fg=cyan]'
  running_since 998500 break
  tool status
  short="${output}"
  running_since 993100 long_break

  # Act
  tool status

  # Assert
  [[ "${short}" == '#[fg=green]B 05:00 [1/4]#[default]' ]]
  [[ "${output}" == '#[fg=cyan]L 15:00 [4/4]#[default]' ]]
}

@test "status - the first render after a start claims the phase and runs no hook" {
  # Arrange
  local writes phase
  running_since 1000000 ""
  option on_work 'echo work'
  option notify 1

  # Act
  tool status

  # Assert
  [[ "${output}" == '#[fg=red]25:00 [1/4]#[default]' ]]
  writes=$(sends)
  [[ "${writes}" == "set-option -gq @pomodoro_revamped_warned  ; set-option -gq @pomodoro_revamped_status #[fg=red]25:00 [1/4]#[default] ; "* ]]
  [[ "${writes}" != *"run-shell"* ]]
  phase=$(held last_phase)
  [[ "${phase}" == "work" ]]
  run cat "${FAKE}/notified"
  [[ "${output}" == "" ]]
}

@test "status - the end of a work period is counted, runs the break hook and notifies, all in the one call" {
  # Arrange
  local writes
  running_since 998500 work
  option on_break 'echo rest;'
  option notify 1

  # Act
  tool status

  # Assert
  [[ "${output}" == '#[fg=green]05:00 [1/4]#[default]' ]]
  writes=$(sends)
  [[ "${writes}" == "set-option -gq @pomodoro_revamped_warned  ; set-option -gq @pomodoro_revamped_week_counts 0,1,0,0,0,0,0 ; set-option -gq @pomodoro_revamped_week_day 11 ; run-shell -b -- echo rest\\; ; ${PUBLISHED_BREAK}" ]]
  run cat "${FAKE}/notified"
  [[ "${output}" == "Pomodoro|Take a short break" ]]
}

@test "status - the hook runs with notifications off, and nothing is announced" {
  # Arrange
  local writes
  running_since 998500 work
  option on_break 'echo rest'

  # Act
  tool status

  # Assert
  writes=$(sends)
  [[ "${writes}" == *" ; run-shell -b -- echo rest ; "* ]]
  run cat "${FAKE}/notified"
  [[ "${output}" == "" ]]
}

@test "status - going back to work runs its hook, announces it and counts nothing" {
  # Arrange
  local writes
  running_since 998200 break
  option on_work 'echo go'
  option notify 1

  # Act
  tool status

  # Assert
  [[ "${output}" == '#[fg=red]25:00 [2/4]#[default]' ]]
  writes=$(sends)
  [[ "${writes}" == "set-option -gq @pomodoro_revamped_warned  ; run-shell -b -- echo go ; set-option -gq @pomodoro_revamped_status "* ]]
  run cat "${FAKE}/notified"
  [[ "${output}" == "Pomodoro|Back to work" ]]
}

@test "status - the long break runs its hook and the cycle hook, and announces itself" {
  # Arrange
  local writes
  running_since 993100 work
  option on_long_break 'echo long'
  option on_cycle 'echo cycle'
  option notify 1

  # Act
  tool status

  # Assert
  [[ "${output}" == '#[fg=blue]15:00 [4/4]#[default]' ]]
  writes=$(sends)
  [[ "${writes}" == *" ; set-option -gq @pomodoro_revamped_week_day 11 ; run-shell -b -- echo long ; run-shell -b -- echo cycle ; set-option -gq @pomodoro_revamped_status "* ]]
  run cat "${FAKE}/notified"
  [[ "${output}" == "Pomodoro|Take a long break" ]]
}

@test "status - a phase change another client claimed first is neither counted nor announced" {
  # Arrange
  local writes
  running_since 998500 work
  option on_break 'echo rest'
  option notify 1
  : >"${FAKE}/raced"

  # Act
  tool status

  # Assert
  [[ "${output}" == '#[fg=green]05:00 [1/4]#[default]' ]]
  writes=$(sends)
  [[ "${writes}" == "set-option -gq @pomodoro_revamped_status #[fg=green]05:00 [1/4]#[default] ; set-option -gq @pomodoro_revamped_phase break ; "* ]]
  run cat "${FAKE}/notified"
  [[ "${output}" == "" ]]
}

@test "status - a claim tmux refuses changes nothing but the countdown" {
  # Arrange
  local writes
  running_since 998500 work
  option on_break 'echo rest'
  : >"${FAKE}/no-if-shell"

  # Act
  tool status

  # Assert
  [[ "${status}" -eq 0 ]]
  writes=$(sends)
  [[ "${writes}" != *"run-shell"* ]]
  [[ "${writes}" != *"week_counts"* ]]
}

@test "status - the bell rings on every client's terminal, and one it cannot write stops nothing" {
  # Arrange
  local first="${BATS_TEST_TMPDIR}/tty-one" second="${BATS_TEST_TMPDIR}/tty-two"
  : >"${first}"
  : >"${second}"
  printf '%s\n' "${first}" "" "${BATS_TEST_TMPDIR}/missing/tty" "${second}" >"${FAKE}/clients"
  running_since 998500 work
  option bell 1

  # Act
  tool status

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "$(<"${first}")" == $'\a' ]]
  [[ "$(<"${second}")" == $'\a' ]]
}

@test "status - quiet hours keep the bell and the notification back, and the hook still runs" {
  # Arrange
  local writes tty="${BATS_TEST_TMPDIR}/tty-one"
  : >"${tty}"
  printf '%s\n' "${tty}" >"${FAKE}/clients"
  running_since 998500 work
  option bell 1
  option notify 1
  option on_break 'echo rest'
  option quiet_hours 10:00-11:00

  # Act
  tool status

  # Assert
  writes=$(sends)
  [[ "${writes}" == *"run-shell -b -- echo rest"* ]]
  [[ ! -s "${tty}" ]]
  run cat "${FAKE}/notified"
  [[ "${output}" == "" ]]
}

@test "status - the warning fires once near the end of a phase, with its hook and its notification" {
  # Arrange
  local writes
  running_since 998530 work
  option warn_seconds 60
  option on_warn 'echo soon'
  option notify 1

  # Act
  tool status

  # Assert
  [[ "${output}" == '#[fg=red]00:30 [1/4]#[default]' ]]
  writes=$(sends)
  [[ "${writes}" == "set-option -gq @pomodoro_revamped_warned 1 ; run-shell -b -- echo soon ; set-option -gq @pomodoro_revamped_status "* ]]
  run cat "${FAKE}/notified"
  [[ "${output}" == "Pomodoro|Less than a minute left" ]]
  : >"${FAKE}/log"
  tool status
  writes=$(sends)
  [[ "${writes}" == "set-option -gq @pomodoro_revamped_status "* ]]
}

@test "status - no warning while paused, before its window, with a junk setting or with it off" {
  # Arrange
  local writes
  option on_warn 'echo soon'
  option warn_seconds 60
  option state paused
  option start 998530
  option paused_total 0
  option paused_at 1000000
  option last_phase work
  tool status
  writes=$(sends)
  running_since 999400 work
  tool status
  writes="${writes}$(sends)"
  running_since 998530 work
  option warn_seconds soon
  tool status
  writes="${writes}$(sends)"
  option warn_seconds 0

  # Act
  tool status

  # Assert
  writes="${writes}$(sends)"
  [[ "${writes}" != *"echo soon"* ]]
  [[ "${writes}" != *"warned 1"* ]]
}

@test "status - a warning in quiet hours runs its hook and sends nothing, and one with notifications off sends nothing" {
  # Arrange
  local writes
  running_since 998530 work
  option warn_seconds 60
  option on_warn 'echo soon'
  option notify 1
  option quiet_hours 10:00-11:00
  tool status
  writes=$(sends)
  option warned ""
  option quiet_hours ""
  option notify 0

  # Act
  tool status

  # Assert
  writes="${writes}$(sends)"
  [[ "${writes}" == *"echo soon"*"echo soon"* ]]
  run cat "${FAKE}/notified"
  [[ "${output}" == "" ]]
}

@test "status - when tmux refuses the writes the countdown is still printed" {
  # Arrange
  running_since 999400
  printf '%s\n' 'set-option -gq @pomodoro_revamped_phase work' >"${FAKE}/refused"

  # Act
  tool status

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == '#[fg=red]15:00 [1/4]#[default]' ]]
}

@test "toggle - an idle timer starts, in one tmux call" {
  # Arrange
  local writes

  # Act
  tool toggle

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "" ]]
  writes=$(sends)
  [[ "${writes}" == 'set-option -gq @pomodoro_revamped_state running ; set-option -gq @pomodoro_revamped_start 1000000 ; set-option -gq @pomodoro_revamped_paused_total 0 ; set-option -gq @pomodoro_revamped_paused_at 0 ; set-option -gq @pomodoro_revamped_last_phase  ; set-option -gq @pomodoro_revamped_warned ' ]]
}

@test "toggle - a running timer pauses and remembers when" {
  # Arrange
  local writes
  running_since 999400

  # Act
  tool toggle

  # Assert
  writes=$(sends)
  [[ "${writes}" == 'set-option -gq @pomodoro_revamped_state paused ; set-option -gq @pomodoro_revamped_paused_at 1000000' ]]
}

@test "toggle - a paused timer resumes and adds the pause to the time held" {
  # Arrange
  local writes
  option state paused
  option start 999400
  option paused_total 50
  option paused_at 999900

  # Act
  tool toggle

  # Assert
  writes=$(sends)
  [[ "${writes}" == 'set-option -gq @pomodoro_revamped_paused_total 150 ; set-option -gq @pomodoro_revamped_paused_at 0 ; set-option -gq @pomodoro_revamped_state running' ]]
}

@test "toggle - when tmux refuses the one call each command is sent alone" {
  # Arrange
  local state alone
  : >"${FAKE}/refused"

  # Act
  tool toggle

  # Assert
  [[ "${status}" -eq 0 ]]
  state=$(held state)
  [[ "${state}" == "running" ]]
  alone=$(sent '^set-option -gq @pomodoro_revamped_start 1000000$')
  [[ "${alone}" == "1" ]]
}

@test "toggle - a command tmux refuses alone makes it exit 1" {
  # Arrange
  printf '%s\n' 'set-option -gq @pomodoro_revamped_state running' >"${FAKE}/refused"

  # Act
  tool toggle

  # Assert
  [[ "${status}" -eq 1 ]]
}

@test "cancel - it stops the timer and clears what it published" {
  # Arrange
  local writes
  running_since 999400

  # Act
  tool cancel

  # Assert
  [[ "${status}" -eq 0 ]]
  writes=$(sends)
  [[ "${writes}" == "set-option -gq @pomodoro_revamped_state  ; set-option -gq @pomodoro_revamped_last_phase  ; ${CLEARED}" ]]
}

@test "skip - it moves the start back by the time left, so the next phase begins now" {
  # Arrange
  local writes
  running_since 999400

  # Act
  tool skip

  # Assert
  writes=$(sends)
  [[ "${writes}" == 'set-option -gq @pomodoro_revamped_start 998500' ]]
  tool status
  [[ "${output}" == '#[fg=green]05:00 [1/4]#[default]' ]]
}

@test "restart - it moves the start forward by the time spent and arms the warning again" {
  # Arrange
  local writes
  running_since 999400

  # Act
  tool restart

  # Assert
  writes=$(sends)
  [[ "${writes}" == 'set-option -gq @pomodoro_revamped_start 1000000 ; set-option -gq @pomodoro_revamped_warned ' ]]
}

@test "skip and restart - an idle timer is left alone" {
  # Arrange
  local writes

  # Act
  tool skip
  tool restart

  # Assert
  [[ "${status}" -eq 0 ]]
  writes=$(sends)
  [[ "${writes}" == "" ]]
}

@test "apply - it binds the key and says nothing" {
  # Arrange
  local writes t
  t=$(bin_path)

  # Act
  tool apply

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "" ]]
  writes=$(sends)
  [[ "${writes}" == "bind-key -N Start or pause M-s run-shell ${t} toggle" ]]
}

@test "list - it prints what apply would send, as lines or as one JSON object, and sends nothing" {
  # Arrange
  local t plain writes
  t=$(bin_path)
  tool list
  plain="${output}"

  # Act
  tool --json list

  # Assert
  [[ "${plain}" == "bind-key -N Start or pause M-s run-shell ${t} toggle" ]]
  [[ "${output}" == "{\"bindings\":[[\"bind-key\",\"-N\",\"Start or pause\",\"M-s\",\"run-shell\",\"${t} toggle\"]]}" ]]
  writes=$(sends)
  [[ "${writes}" == "" ]]
}

@test "options - a setting is taken as --name value, --name=value and after --, and rides on the binding" {
  # Arrange
  local t
  t=$(bin_path)

  # Act
  tool --work=50 --toggle-key T --theme mono --theme=mono -- list

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "bind-key -N Start or pause T run-shell ${t} --work '50' toggle" ]]
}

@test "options - an unknown one, one without its value and --json outside list are usage errors" {
  # Arrange
  local unknown short valueless

  # Act
  tool --bogus 1 list
  unknown="${output}"
  tool -x list
  short="${output}"
  tool list --work
  valueless="${output}"
  tool --json status

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${unknown}" == "pomodoro-revamped: unknown option '--bogus'. run 'pomodoro-revamped help' for usage." ]]
  [[ "${short}" == "pomodoro-revamped: unknown option '-x'. run 'pomodoro-revamped help' for usage." ]]
  [[ "${valueless}" == "pomodoro-revamped: option '--work' needs a value. run 'pomodoro-revamped help' for usage." ]]
  [[ "${output}" == "pomodoro-revamped: option '--json' works only with list. run 'pomodoro-revamped help' for usage." ]]
}

@test "options - an unknown one given as --name=value is refused too" {
  # Arrange
  local expected="pomodoro-revamped: unknown option '--bogus'. run 'pomodoro-revamped help' for usage."

  # Act
  tool --bogus=1 list

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "${expected}" ]]
}

@test "version - it prints the version from the library and the tmux version" {
  # Arrange
  local version
  version=$(sed -n 's/^readonly POMODORO_REVAMPED_VERSION="\(.*\)"$/\1/p' "${REVAMPED_TESTS_DIR}/../lib/core.sh")

  # Act
  tool version

  # Assert
  [[ "${lines[0]}" == "pomodoro-revamped ${version}" ]]
  [[ "${lines[1]}" == "tmux: 3.6" ]]
}

@test "doctor - it names the notifier, the pager and its keys" {
  # Arrange
  quiet less ':'

  # Act
  tool doctor

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" =~ notifier\ +ok\ +(osascript|notify-send) ]]
  [[ "${output}" =~ less\ +ok ]]
  [[ "${output}" =~ keys\ +ok\ +every\ key\ it\ binds\ is\ free\ or\ its\ own ]]
}

@test "doctor - it names the default key someone else holds" {
  # Arrange
  printf '%s\n' 'bind-key    -T prefix M-s     run-shell foo' >"${FAKE}/keys"

  # Act
  tool doctor

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" =~ keys\ +warn\ +already\ bound\ and\ left\ alone:\ M-s ]]
}

@test "doctor - a missing pager is a warning that says what the help key does without it" {
  # Arrange
  local row='less +warn +the help key pages with it, and shows the whole page without it'
  harness_hide less

  # Act
  tool doctor

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" =~ ${row} ]]
}

@test "menu - applying from the menu says how many keys are bound" {
  # Arrange
  export REVAMPED_TEST_GUM=1 REVAMPED_TEST_GUM_LOG="${BATS_TEST_TMPDIR}/gum.log"
  answers 'Apply them now'

  # Act
  tool

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Applied. 1 key is bound."* ]]
}

@test "menu - applying with more keys set counts them" {
  # Arrange
  export REVAMPED_TEST_GUM=1 REVAMPED_TEST_GUM_LOG="${BATS_TEST_TMPDIR}/gum.log"
  option cancel_key M-c
  answers 'Apply them now'

  # Act
  tool

  # Assert
  [[ "${output}" == *"Applied. 2 keys are bound."* ]]
}

@test "menu - checking the machine from the menu runs doctor" {
  # Arrange
  export REVAMPED_TEST_GUM=1 REVAMPED_TEST_GUM_LOG="${BATS_TEST_TMPDIR}/gum.log"
  answers 'Check this machine'

  # Act
  tool

  # Assert
  [[ "${status}" -eq 0 ]]
  grep -q 'notifier' "${REVAMPED_TEST_GUM_LOG}"
}
