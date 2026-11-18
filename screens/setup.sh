export PS1='$ '
export PATH="/Users/Shared/demo/tmux-pomodoro-revamped/bin:${PATH}"
unset KODOUGU_THEME KODOUGU_ACCENT POMODORO_REVAMPED_THEME POMODORO_REVAMPED_ACCENT NO_COLOR
export HOME=/Users/Shared/demo/home
cd /Users/Shared/demo || return 1
printf '\033]2;demo\033\134'
clear
