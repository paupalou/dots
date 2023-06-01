#!/usr/bin/env bash
#
if [[ $__dots_printer_loaded == true ]]; then
  return 0
fi
__dots_printer_loaded=true

__dots_folder=$(dirname "$(readlink "$(which dots)")")
source "${__dots_folder}/colors.sh"

function _cr {
  printf "\r\n"
}

function _newline {
  printf "\n"
}

function _str_len {
  echo -n "$1" | wc -m
}

# shellcheck disable=SC2120
function _space {
  if [ -z "$1" ]; then
    printf " "
  else
    for ((i = 1; i <= $1; i++)); do
      printf " "
    done
  fi
}

################################
# Print a colored message      #
# Arguments:                   #
#  $1 message                  #
#  $2 color and/or textstyle   #
################################
function _print_colored {
  local message=$1
  if [ -z "$message" ]; then
    return
  fi

  # Defaults to normal, if not specified.
  local color=${2:-$normal}

  printf "%b%s" "$color" "$message"

  # Reset to normal.
  printf "%b" "$normal"

  return
}

function _print {
  _print_colored "$1"
}

function _repeat {
  local start=1
  local end=${1:-BOX_SIZE}
  local str="${2:-=}"
  local range
  range=$(seq "$start" "$end")
  for _i in $range; do _print_colored "${str}" "$3"; done
}

function _success_icon {
  local success_char success_style
  success_char=$(_dots_setting "success_icon_char")
  success_style=$(_dots_color "success_icon_style")

  _print_colored "$success_char" "$success_style"
}

function _link_icon {
  local link=""
  local link_color=$lblue$bold
  # if user custom styles
  if [ -n "$_user_link_icon" ]; then
    link=$_user_link_icon
  fi
  if [ -n "$_user_link_icon_color" ]; then
    link_color=$_user_link_icon_color
  fi

  _print_colored "$link" "$link_color"
}

# function _print_incorrect_argument {
#   if [[ -n $2 ]]; then
#     _print_colored "$1" "$dgray"
#     _space
#     _print_colored "$2" "$uline$lgray"
#   else
#     _print_colored "$1" "$uline$dgray"
#   fi
#   _space
#   _print_colored "incorrect argument"
#   _newline
# }

function _print_error {
  error_char=$(_dots_setting "error_icon_char")
  error_style=$(_dots_color "error_icon_style")
  _space
  _print_colored "$error_char" "$error_style"
  _space 2
  _print_colored "$1"
  # _print_colored "1. create a new user config"
  # _space
  # _print_colored "dots config create" "$bold$uline"
  _newline
}

function _print_dots_title {
  dots_title_char=$(_dots_setting "title_icon_char")
  dots_title_style=$(_dots_color "title_style")

  _print_colored "$dots_title_char" "$(_dots_color "title_icon_style_first")"
  _print_colored "$dots_title_char" "$(_dots_color "title_icon_style_second")"
  _print_colored "$dots_title_char" "$(_dots_color "title_icon_style_third")"
  _space
  _print_colored "dots" "$dots_title_style"
  for arg in "$@"; do
    _space
    _print_colored "$arg"
  done
}
