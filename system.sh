#!/bin/bash

function _get_dots_folder {
  dirname "$(readlink "$(which dots)")"
}

function _disable_globbing {
  set -f
}

function _enable_globbing {
  set +f
}

function _get_distro {
  cat /etc/*-release | grep '^ID=' | cut -d "=" -f 2
}

function _get_machine_hostname {
  hostnamectl | grep 'Static hostname' | cut -d ":" -f 2 | cut -b 2-
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
  expected_file="${file_path}/${file_basename}:$(_get_distro):$(_get_machine_hostname).${file_extension}"

  if [ ! -f "$expected_file" ]; then
    expected_file="${file_path}/${file_basename}:$(_get_distro).${file_extension}"
  fi

  if [ -f "$expected_file" ]; then
    echo "$expected_file"
  else
    echo "$generic_file"
  fi
}
