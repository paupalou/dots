#!/bin/bash

__dots_version="1.0"
__dots_folder=$(dirname "$(readlink "$(which dots)")")

source "${__dots_folder}/printer.sh"
source "${__dots_folder}/dotfiles.sh"

__dots_param=$1 __dots_sub_param=$2

function _print_option {
  local description_padding
  description_padding=$((10 - ${#1}))
  _space
  if [ -z "$3" ]; then
    _print_colored "$1" "$uline$yellow"
  else
    _space
    _space
    _print "$1"
    description_padding=$((8 - ${#1}))
  fi
  _repeat "$description_padding" " "
  _print_colored "$2" "$lgray"
  _newline
}

function _print_option_param {
  _print_option "$1" "$2" true
}

function _print_main {
  _print_colored "Utility to manage your dotfiles"
  _newline
  _newline

  _print_colored "Options:" "$bold"
  _newline

  _print_option "sync" "Symlink all files inside directory"
  _print_option_param "-i" "Info."
  _print_option_param "-v" "Verbose mode, show each symlink path."

  _print_option "config" "View or edit the config"
  _print_option_param "edit" "Open \$EDITOR to edit dots config."

  _print_option "version" "Print dots version"

  _newline
}

function _print_incorrect_argument {
  if [ -n "$2" ]; then
    _print_colored "$1" "$dgray"
    _space
    _print_colored "$2" "$uline$lgray"
  else
    _print_colored "$1" "$uline$dgray"
  fi
  _space
  _print_colored "incorrect argument"
  _newline
}

if [ -z "$__dots_param" ]; then
  _print_main
else
  if [[ $__dots_param == 'sync' ]]; then
    if [[ -z $__dots_sub_param ]]; then
      _sync_dotfiles
      exit 0
    fi

    if [[ $__dots_sub_param == '-v' ]]; then
      _sync_dotfiles verbose
      exit 0
    else
      _print_incorrect_argument "$__dots_param" "$__dots_sub_param"
      exit 0
    fi
  fi

  if [[ $__dots_param == 'config' ]]; then
    if [[ -z $__dots_sub_param ]]; then
      if [[ -n $(which bat) ]]; then
        bat "${__dots_folder}/config.yml"
      else
        cat "${__dots_folder}/config.yml"
      fi
      exit 0
    fi

    if [[ $__dots_sub_param == 'edit' ]]; then
      $EDITOR "${__dots_folder}/config.yml"
      exit 0
    else
      _print_incorrect_argument "$__dots_param" "$__dots_sub_param"
      exit 0
    fi
  fi

  if [[ $__dots_param == 'version' ]]; then
    _print dots
    _space
    _print_colored version "$lgray"
    _space
    _print_colored "$__dots_version" "$bold"
    _newline
    exit 0
  fi

  _print_incorrect_argument "$__dots_param"
fi

