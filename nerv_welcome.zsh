# NERV-style zsh welcome banner.
# Source this file from ~/.zshrc to display it for interactive shells.

[[ -o interactive || "${ZSH_NERV_WELCOME_FORCE:-}" == "1" ]] || return 0
[[ -n "${ZSH_NERV_WELCOME_SHOWN:-}" ]] && return 0
export ZSH_NERV_WELCOME_SHOWN=1

autoload -Uz colors && colors

_nerv_has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

_nerv_truncate() {
  local value="$1"
  local max="${2:-34}"

  if (( ${#value} > max )); then
    print -r -- "...${value[-$(( max - 3 )),-1]}"
  else
    print -r -- "$value"
  fi
}

_nerv_short_pwd() {
  local path="${PWD/#$HOME/~}"
  _nerv_truncate "$path" 34
}

_nerv_system_status() {
  local load="UNAVAILABLE"

  if _nerv_has_cmd uptime; then
    load=$(uptime | sed -E 's/.*load averages?: //; s/, / /g')
    load=$(_nerv_truncate "$load" 18)
  fi

  print -r -- "ONLINE / LOAD ${load}"
}

_nerv_git_status() {
  if _nerv_has_cmd git && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

    if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
      print -r -- "${branch:-DETACHED} / UNSYNCED"
    else
      print -r -- "${branch:-DETACHED} / CLEAN"
    fi
  else
    print -r -- "NO LOCAL REPOSITORY"
  fi
}

_nerv_welcome() {
  local red="${fg_bold[red]}"
  local yellow="${fg[yellow]}"
  local green="${fg_bold[green]}"
  local cyan="${fg[cyan]}"
  local blue="${fg_bold[blue]}"
  local white="${fg_bold[white]}"
  local dim="${fg[black]}"
  local reset="${reset_color}"
  local sep="${dim}:${reset}"
  local left_width=43
  local -a logo info

  logo=(
    "                   ▄▄▄"
    "            ▄     ▄████████   ▄"
    "           ▀█▄    ████████▄███████"
    "             ▀█▄ ▄███████████████████▄"
    "               ▀███████████████████████"
    "                 ▀███████████████████▀"
    "        ███  ▀█ ███▀█████████████▀▀"
    "        █▀██▄ █ ███▄█▀█████████▄▄"
    "        █  ▀███ ███ ▀  ███████████▄"
    "       ▄█▄   ▀█ ███▄▄██ ▀██████████"
    "                ███▀██████▀█████████"
    "                ███ ███ ▀██▄▀██████▄"
    "                ██████▄   ▀███▀█████▄"
    "                ███ ▀███    ▀█  ▀███"
    "                                   ▀"
  )

  info=(
    ""
    ""
    ""
    "${yellow}SYSTEM${reset} ${sep} ${green}$(_nerv_system_status)${reset}"
    "${yellow}CHRONO${reset} ${sep} ${cyan}$(date '+%Y-%m-%d %H:%M:%S')${reset}"
    "${yellow}PILOT ${reset} ${sep} ${white}${USER:-UNKNOWN}${reset}"
    "${yellow}HOST  ${reset} ${sep} ${cyan}${HOST%%.*}${reset}"
    "${yellow}SHELL ${reset} ${sep} ${blue}ZSH ${ZSH_VERSION:-UNKNOWN}${reset}"
    "${yellow}PATH  ${reset} ${sep} ${cyan}$(_nerv_short_pwd)${reset}"
    "${yellow}MAGI  ${reset} ${sep} ${green}$(_nerv_git_status)${reset}"
    "${white}OPERATION STATUS${reset} ${sep} ${green}STANDBY${reset}"
    ""
    ""
    ""
    ""
  )

  print
  print -P "${red}=====================================================================================${reset}"

  local i
  for i in {1..15}; do
    printf "%s%-${left_width}s%s   %b\n" "$red" "${logo[$i]}" "$reset" "${info[$i]}"
  done

  print -P "${red}=====================================================================================${reset}"
  print
}

_nerv_welcome
unfunction _nerv_welcome _nerv_has_cmd _nerv_truncate _nerv_short_pwd _nerv_system_status _nerv_git_status
