#!/usr/bin/env bash

__dots_folder=$(dirname "$(readlink "$(which dots)")")
__dots_version=$(cat "$__dots_folder"/version)

source "${__dots_folder}/printer.sh"
source "${__dots_folder}/dotfiles.sh"

__dots_param=$1 __dots_sub_param=$2

function _print_option {
  local option=$1 description=$2 is_sub_option=$3 max_column_width=10
  local description_padding
  description_padding=$(("$max_column_width" - ${#option}))

  _space
  if [[ -z $is_sub_option ]]; then
    _print_colored "$option" "$uline$yellow"
  else
    local sub_option_padding=2
    _repeat $sub_option_padding " "
    _print "$option"
    description_padding=$(("$max_column_width" - "$sub_option_padding" - ${#option}))
  fi

  _repeat "$description_padding" " "
  _print_colored "$description" "$lgray"
  _newline
}

function _print_option_param {
  local option=$1 description=$2 is_sub_option=true
  _print_option "$option" "$description" "$is_sub_option"
}

function _print_main {
  _print_colored "Utility to manage your dotfiles"
  _newline
  _newline

  _print_colored "Options:" "$bold"
  _newline

  _print_option "sync" "Symlink all files inside directory"
  _print_option_param "-v or --verbose" "Verbose mode, show each symlink path."

  _print_option "config" "View or edit the config"
  _print_option_param "-e or --edit" "Open \$EDITOR to edit dots config."

  _print_option "version" "Print dots version"
  _print_option "update" "Update dots"

  _newline
}

function _sync {
  if [[ -z $__dots_sub_param ]]; then
    _sync_dotfiles
    exit 0
  fi

  if [[ $__dots_sub_param == 'verbose' || $__dots_sub_param == '-v' ]] ; then
    _sync_dotfiles verbose
    exit 0
  else
    _print_incorrect_argument "$__dots_param" "$__dots_sub_param"
    exit 0
  fi
}

function _update {
  source "${__dots_folder}/update.sh"
}

function _print_incorrect_argument {
  if [[ -n $2 ]]; then
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

if [[ -z $__dots_param ]]; then
  _print_main
  exit 0
fi

if [[ $__dots_param == 'sync' ]]; then
  _sync
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

  if [[ $__dots_sub_param == '--edit' || $__dots_sub_param == '-e' ]]; then
    $EDITOR "${__dots_folder}/config.yml"
    exit 0
  else
    _print_incorrect_argument "$__dots_param" "$__dots_sub_param"
    exit 0
  fi
fi

if [[ $__dots_param == 'version' || $__dots_param == '-v' ]]; then
  _print dots
  _space
  _print_colored version "$lgray"
  _space
  _print_colored "$__dots_version" "$bold"
  _newline
  exit 0
fi

if [[ $__dots_param == 'update' ]]; then
  _update
  exit 0
fi

_print_incorrect_argument "$__dots_param"

