#!/usr/bin/env bash

__dots_folder=$(dirname "$(readlink "$(which dots)")")
__dots_version=$(cat "$__dots_folder"/version)

source "${__dots_folder}/printer.sh"
source "${__dots_folder}/config.sh"
source "${__dots_folder}/dotfiles.sh"

__dots_param=$1
__dots_sub_param=$2
__dots_third_param=$3

function _print_option {
  local option=$1 description=$2 is_sub_option=$3
  local max_column_width description_padding

  max_column_width=$(_dots_setting "main_option_max_width")
  description_padding=$((max_column_width - ${#option}))

  _space
  if [[ -z $is_sub_option ]]; then
    _print_colored "$option" "$(_dots_color "main_option_command")"
    _repeat "$description_padding" " "
    _print_colored "$description" "$(_dots_color "main_option_description")"
  else
    local sub_option_padding
    sub_option_padding=$(_dots_setting "main_sub_option_padding")
    _repeat "$sub_option_padding" " "
    _print_colored "$option" "$(_dots_color "main_sub_option_command")"
    description_padding=$((max_column_width - sub_option_padding - ${#option}))
    _repeat "$description_padding" " "
    _print_colored "$description" "$(_dots_color "main_sub_option_description")"
  fi

  _newline
}

function _print_option_param {
  local option=$1 description=$2 is_sub_option=true
  _print_option "$option" "$description" "$is_sub_option"
}

function _print_main {
  _print_colored "Options:" "$bold"
  _newline

  _print_option "sync" "Symlink all files inside directory"
  _print_option_param "-v or --verbose" "Verbose mode, show each symlink path."

  _print_option "config" "Prints dots user config"
  _print_option_param "create" "Create dots user config file"
  _print_option_param "default" "Prints dots default config"
  _print_option_param "edit" "Open \$EDITOR to edit dots config"

  _print_option "version" "Print dots version"
  _print_option "update" "Update dots"

  _newline
}

function _sync {
  local dotfiles_path
  dotfiles_path=$(_dots_setting "dotfiles_path")
  if [[ ! -d "$dotfiles_path" ]]; then
    _print_error "dotfiles path is not set"
    exit
  fi

  if [[ -z $__dots_sub_param ]]; then
    _sync_dotfiles "$(_dots_setting "verbose")"
    exit
  fi

  if [[ $__dots_sub_param == '--verbose' || $__dots_sub_param == '-v' ]]; then
    _sync_dotfiles true
    exit
  else
    _print_incorrect_argument "$__dots_param" "$__dots_sub_param"
    exit
  fi
}

function _config {
  if [[ -z $__dots_sub_param ]]; then
    if [[ ! -f $__user_config ]]; then
      _command=""
      _print_error "Unable to locate user config file, using default values"
      _space 4
      _print_colored "If you want to customise how dots behaves create a configuration file by running"
      _newline
      _space 4
      _print_colored "dots config create" "$bold"
      _newline
      exit
    fi
    _echo_config
    exit
  fi

  if [[ $__dots_sub_param == 'create' ]]; then
    _create_config
    exit
  elif [[ $__dots_sub_param == 'edit' ]]; then
    _edit_config
    exit
  elif [[ $__dots_sub_param == 'get' ]]; then
    if [[ -z $__dots_third_param ]]; then
      _print_error "config get needs a value"
      exit
    fi
    setting_value="$(_dots_setting "$__dots_third_param")"
    if [[ -n $setting_value ]]; then
      echo "$setting_value"
    fi
    exit
  elif [[ $__dots_sub_param == 'default' ]]; then
    _echo_config default
    exit
  else
    _print_incorrect_argument "$__dots_param" "$__dots_sub_param"
    exit
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
  _print_dots_title
  _newline
  _print_main
  exit
fi

if [[ $__dots_param == 'sync' ]]; then
  _sync
fi

if [[ $__dots_param == 'config' ]]; then
  _config
fi

if [[ $__dots_param == 'version' || $__dots_param == '-v' ]]; then
  version=$(_print_colored "version" "$(_dots_color "version_word")")
  version_number=$(_print_colored "$__dots_version" "$(_dots_color "version_number")")
  _print_dots_title "$version" "$version_number"
  _newline
  exit
fi

if [[ $__dots_param == 'update' ]]; then
  _update
  exit
fi

_print_incorrect_argument "$__dots_param"
