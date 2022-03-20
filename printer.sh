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

function _success {
  local success=""
  local success_color=$green
  # if user custom styles
  if [ -n "$_user_success" ]; then
    success=$_user_success
  fi
  if [ -n "$_user_success_color" ]; then
    success_color=$_user_success_color
  fi

  _print_colored "$success" "$success_color"
}

