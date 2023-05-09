#!/usr/bin/env bash

__dots_folder=$(dirname "$(readlink "$(which dots)")")
source "${__dots_folder}/config.sh"

if [[ $__dots_system_loaded == true ]]; then
  return 0
fi
__dots_system_loaded=true

function _disable_globbing {
  set -f
}

function _enable_globbing {
  set +f
}

function _disable_input {
  if [ -t 0 ]; then
    stty -echo -icanon time 0 min 0
  fi
}

function _enable_input {
  if [ -t 0 ]; then
    stty sane
  fi
}

function _get_dots_tag {
  _dots_setting "tag"
}

function _grab_file {
  local generic_file=$1
  local file_path
  local file_basename
  local file_extension

  file_path="$(dirname "$generic_file")"
  file_basename="$(basename "$generic_file" | cut -d "." -f 1)"
  file_extension="$(basename "$generic_file" | cut -d "." -f 2)"

  local expected_file
  expected_file="${file_path}/${file_basename}:$(_get_dots_tag).${file_extension}"

  if [ -f "$expected_file" ]; then
    echo "$expected_file"
  else
    echo "$generic_file"
  fi
}
