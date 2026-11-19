#!/bin/sh
# shellcheck disable=SC2034

[ -n "${POMODORO_REVAMPED_STATE_LOADED:-}" ] && return 0
POMODORO_REVAMPED_STATE_LOADED=1

POMODORO_REVAMPED_SETTINGS='toggle_key	M-s
cancel_key
skip_key
restart_key
menu_key
help_key
work	25
break	5
long_break	15
intervals	4
notify	0
bell	0
warn_seconds	0
quiet_hours
goal	6
show_progress	0
show_interval	1
show_goal	0
show_finish	0
progress_width	8
bar_filled	#
bar_empty	-
pause_text	 paused
work_color	#[fg=red]
break_color	#[fg=green]
long_break_color	#[fg=blue]
work_icon
break_icon
long_break_icon
on_work
on_break
on_long_break
on_cycle
on_warn	'
POMODORO_REVAMPED_NAMES='toggle_key cancel_key skip_key restart_key menu_key help_key work break long_break intervals notify bell warn_seconds quiet_hours goal show_progress show_interval show_goal show_finish progress_width bar_filled bar_empty pause_text work_color break_color long_break_color work_icon break_icon long_break_icon on_work on_break on_long_break on_cycle on_warn'
POMODORO_REVAMPED_CARRIED='work break long_break intervals notify bell warn_seconds quiet_hours goal show_progress show_interval show_goal show_finish progress_width bar_filled bar_empty pause_text work_color break_color long_break_color work_icon break_icon long_break_icon on_work on_break on_long_break on_cycle on_warn'
POMODORO_REVAMPED_LIVE='state start paused_total paused_at last_phase warned week_counts week_day status'
POMODORO_REVAMPED_S_toggle_key='M-s'
POMODORO_REVAMPED_S_cancel_key=''
POMODORO_REVAMPED_S_skip_key=''
POMODORO_REVAMPED_S_restart_key=''
POMODORO_REVAMPED_S_menu_key=''
POMODORO_REVAMPED_S_help_key=''
POMODORO_REVAMPED_S_work='25'
POMODORO_REVAMPED_S_break='5'
POMODORO_REVAMPED_S_long_break='15'
POMODORO_REVAMPED_S_intervals='4'
POMODORO_REVAMPED_S_notify='0'
POMODORO_REVAMPED_S_bell='0'
POMODORO_REVAMPED_S_warn_seconds='0'
POMODORO_REVAMPED_S_quiet_hours=''
POMODORO_REVAMPED_S_goal='6'
POMODORO_REVAMPED_S_show_progress='0'
POMODORO_REVAMPED_S_show_interval='1'
POMODORO_REVAMPED_S_show_goal='0'
POMODORO_REVAMPED_S_show_finish='0'
POMODORO_REVAMPED_S_progress_width='8'
POMODORO_REVAMPED_S_bar_filled='#'
POMODORO_REVAMPED_S_bar_empty='-'
POMODORO_REVAMPED_S_pause_text=' paused'
POMODORO_REVAMPED_S_work_color='#[fg=red]'
POMODORO_REVAMPED_S_break_color='#[fg=green]'
POMODORO_REVAMPED_S_long_break_color='#[fg=blue]'
POMODORO_REVAMPED_S_work_icon=''
POMODORO_REVAMPED_S_break_icon=''
POMODORO_REVAMPED_S_long_break_icon=''
POMODORO_REVAMPED_S_on_work=''
POMODORO_REVAMPED_S_on_break=''
POMODORO_REVAMPED_S_on_long_break=''
POMODORO_REVAMPED_S_on_cycle=''
POMODORO_REVAMPED_S_on_warn=''
POMODORO_REVAMPED_S_state=''
POMODORO_REVAMPED_S_start=''
POMODORO_REVAMPED_S_paused_total=''
POMODORO_REVAMPED_S_paused_at=''
POMODORO_REVAMPED_S_last_phase=''
POMODORO_REVAMPED_S_warned=''
POMODORO_REVAMPED_S_week_counts=''
POMODORO_REVAMPED_S_week_day=''
POMODORO_REVAMPED_PLACEHOLDER='#{pomodoro_status}'
POMODORO_REVAMPED_DEFAULT_TOGGLE_KEY='M-s'
POMODORO_REVAMPED_TITLE='Pomodoro'
POMODORO_REVAMPED_RESET='#[default]'
POMODORO_REVAMPED_DAY=86400
POMODORO_REVAMPED_NOTES_SINCE=3.1
POMODORO_REVAMPED_EMPTY='pomodoro-revamped-empty-argument'
POMODORO_REVAMPED_TMUX=''
POMODORO_REVAMPED_NOTES=0
POMODORO_REVAMPED_TOOL=''
POMODORO_REVAMPED_KEYS=''
POMODORO_REVAMPED_BOUND=''
POMODORO_REVAMPED_SKIPPED=''
POMODORO_REVAMPED_PLAN=''
POMODORO_REVAMPED_NOW=0
POMODORO_REVAMPED_PHASE=''
POMODORO_REVAMPED_REMAINING=0
POMODORO_REVAMPED_INDEX=1
POMODORO_REVAMPED_LENGTH=0
POMODORO_REVAMPED_SEGMENT=''
POMODORO_REVAMPED_WORK_SECONDS=0
POMODORO_REVAMPED_BREAK_SECONDS=0
POMODORO_REVAMPED_LONG_SECONDS=0
POMODORO_REVAMPED_ROUNDS=4
POMODORO_REVAMPED_TODAY=0
POMODORO_REVAMPED_WEEK=''
POMODORO_REVAMPED_S_status=''
POMODORO_REVAMPED_MAX_ROUNDS=100
POMODORO_REVAMPED_MAX_WIDTH=200
POMODORO_REVAMPED_NUMBER=0
POMODORO_REVAMPED_PERCENT=0
POMODORO_REVAMPED_BAR=''
POMODORO_REVAMPED_MINUTES=0
POMODORO_REVAMPED_TWO=''
POMODORO_REVAMPED_COLOR=''
POMODORO_REVAMPED_ICON=''
POMODORO_REVAMPED_JOB=''
POMODORO_REVAMPED_KINDS='work	number
break	number
long_break	number
intervals	number 1 100
warn_seconds	number
goal	number
progress_width	number 0 200
notify	1 0
bell	1 0
show_progress	1 0
show_interval	1 0
show_goal	1 0
show_finish	1 0'
