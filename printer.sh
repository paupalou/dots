#!/bin/bash

__dots_folder=$(dirname "$(readlink "$(which dots)")")

source "${__dots_folder}/colors.sh"

function _cr {
  printf "\r\n"
}

function _newline {
  printf "\n"
}

function _space {
  printf " "
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
  for _i in $range ; do _print_colored "${str}" "$3"; done
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

