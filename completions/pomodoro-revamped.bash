# shellcheck shell=bash
# shellcheck disable=SC2207

_pomodoro_revamped() {
  local cur prev
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD - 1]}"

  case "${prev}" in
  --theme)
    COMPREPLY=($(compgen -W "kodougu catppuccin-mocha catppuccin-latte dracula nord gruvbox tokyo-night mono" -- "${cur}"))
    return
    ;;
  --notify | --bell | --show-progress | --show-interval | --show-goal | --show-finish)
    COMPREPLY=($(compgen -W "0 1" -- "${cur}"))
    return
    ;;
  --toggle-key | --cancel-key | --skip-key | --restart-key | --menu-key | --help-key | --work | --break | --long-break | --intervals | --warn-seconds | --quiet-hours | --goal | --progress-width | --bar-filled | --bar-empty | --pause-text | --work-color | --break-color | --long-break-color | --work-icon | --break-icon | --long-break-icon | --on-work | --on-break | --on-long-break | --on-cycle | --on-warn)
    return
    ;;
  *) ;;
  esac

  COMPREPLY=($(compgen -W "apply list toggle skip restart cancel status doctor version help --json --theme --toggle-key --cancel-key --skip-key --restart-key --menu-key --help-key --work --break --long-break --intervals --notify --bell --warn-seconds --quiet-hours --goal --show-progress --show-interval --show-goal --show-finish --progress-width --bar-filled --bar-empty --pause-text --work-color --break-color --long-break-color --work-icon --break-icon --long-break-icon --on-work --on-break --on-long-break --on-cycle --on-warn" -- "${cur}"))
}

complete -F _pomodoro_revamped pomodoro-revamped
