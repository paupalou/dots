#!/bin/bash

__dots_folder=$(dirname "$(readlink "$(which dots)")")

source "${__dots_folder}/colors.sh"
source "${__dots_folder}/printer.sh"

function _box_max_width {
  local box_size=72
  if [ -n "$_user_box_size" ]; then
    box_size=$_user_box_size
  fi

  if [[ "$(tput cols)" -lt $box_size ]]; then
    tput cols
  elif [[ "$box_size" -eq 0 ]]; then
    tput cols
  else
    echo "$box_size"
  fi
}

function _box_style {
  # if user custom styles
  if [ -n "$_user_box_style" ]; then
    echo "$_user_box_style"
    return
  fi

  local default="$bold$lblue"
  echo "$default"
}

function _box_padding {
  # if user custom styles
  if [ -n "$_user_box_padding" ]; then
    echo "$_user_box_padding"
    return
  fi

  local default=1
  echo $default
}

function _box_start {
  local box_title=$1
  local line_start="┌"
  local line_end="┐"

  local padding_left=8

  if [[ "$(_box_max_width)" -lt 60 ]]; then padding_left=5; fi
  if [[ "$(_box_max_width)" -lt 50 ]]; then padding_left=4; fi
  if [[ "$(_box_max_width)" -lt 40 ]]; then padding_left=3; fi
  if [[ "$(_box_max_width)" -lt 30 ]]; then padding_left=2; fi
  if [[ "$(_box_max_width)" -lt 20 ]]; then padding_left=1; fi
  if [[ "$(_box_max_width)" -lt 10 ]]; then padding_left=0; fi

  local pending_border
  if [[ "${#box_title}" -eq 0 ]]; then
    # 2 for each border
    pending_border=$(($(_box_max_width) - 2 - "$padding_left" - ${#box_title}))
  else
    # 4 , 2 more for each space at start & end of $box_title
    pending_border=$(($(_box_max_width) - 4 - "$padding_left" - ${#box_title}))
  fi

  _print_colored "$line_start" "$(_box_style)"
  _repeat "$padding_left" "─" "$(_box_style)"
  if [[ "$pending_border" -lt 0 ]]; then
    _print_colored " ${box_title:0:$((${#box_title} - "${pending_border#-}"))} " "$(_box_style)"
  elif [[ -n ${box_title} ]]; then
    _print_colored " ${box_title} " "$(_box_style)"
  fi
  _repeat "$pending_border" "─" "$(_box_style)"
  _print_colored "$line_end" "$(_box_style)"

  _cr
}

function _box_end {
  local line_start="└"
  local line_end="┘"

  local box_content_width
  box_content_width=$(($(_box_max_width) - 2))

  _print_colored "$line_start" "$(_box_style)"
  _repeat "$box_content_width" "─" "$(_box_style)"
  _print_colored "$line_end" "$(_box_style)"

  _cr
}

function _box_line_start {
  local line_start="│"
  _print_colored "$line_start" "$(_box_style)"
  _repeat "$(_box_padding)" " "
}

function _box_line_end {
  # 1 per each border and box padding value per each side
  local box_content_width=$(($(_box_max_width) - 2 - $(($(_box_padding) * 2))))
  local spaces_needed=$((box_content_width - $1 + $(_box_padding)))

  local line_end="│"
  _repeat "$spaces_needed" " "
  _print_colored "$line_end" "$(_box_style)"
}

function _box_line_max_length {
  # 1 per each border and box padding value per each side
  echo $(($(_box_max_width) - 2 - $(($(_box_padding) * 2))))
}
