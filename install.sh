#!/usr/bin/env bash

__repository_url=https://github.com/paupalou/dots.git
__destination_path=$HOME/.dots
__bin_path=$HOME/.local/bin
__bash_user_completions_dir=$XDG_DATA_HOME/bash-completion/completions
__destination_path_provided=false
__bin_path_provided=false

if [ "$#" -gt 0 ]; then
  __destination_path_provided=true
  __destination_path=$1
fi

if [ "$#" -gt 1 ]; then
  __bin_path_provided=true
  __bin_path=$2
fi

if [[ -z $XDG_DATA_HOME ]]; then
  __bash_user_completions_dir="$HOME/.local/share/bash-completion/completions"
fi

function _is_shell_installed {
  if [[ -n $(which "$1") ]]; then
    true
  fi
  false
}

function _clone_dots {
  local parent_dir
  parent_dir=$(dirname "$__destination_path")

  if [ ! -d "$parent_dir" ]; then
    mkdir -p "$parent_dir"
  fi

  git clone "$__repository_url" "$__destination_path"
}

function _reset_to_normal {
  tput sgr0
}

function _directory_is_in_path {
  local result
  result=$(echo "$PATH" | grep -c ":$1")
  if [[ $result -gt 0 ]]; then
    true
  else
    false
  fi
}

function _print_arguments {
  if [[ $__destination_path_provided = false ]]; then
    local __user_destination_path
    read -rp "$(_question) Dots destination path [$(tput bold)$(tput setaf 3)${__destination_path}$(tput sgr0)]: " __user_destination_path
    __destination_path=${__user_destination_path:-$__destination_path}
  fi

  if [[ $__bin_path_provided = false ]]; then
    local __user_bin_path
    read -rp "$(_question) Bin path [$(tput bold)$(tput setaf 3)${__bin_path}$(tput sgr0)]:" __user_bin_path
    __bin_path=${__user_bin_path:-$__bin_path}
  fi

  echo
}

function _question {
  printf "%s%s" "$(tput setaf 3)$(tput bold)" "$(_reset_to_normal)"
}

function _info {
  printf "%s%s" "$(tput setaf 6)$(tput bold)" "$(_reset_to_normal)"
}

function _success {
  printf "%s%s" "$(tput setaf 2)$(tput bold)" "$(_reset_to_normal)"
}

function _error {
  printf "%s%s" "$(tput setaf 1)$(tput bold)" "$(_reset_to_normal)"
}

function _print_installing {
  printf "$(_info) Installing dots on %s%s%s" "$(tput setaf 6)$(tput bold)" "$__destination_path" "$(_reset_to_normal)"
  echo
  echo
  _clone_dots
  echo
}

_print_arguments

if [[ ! -d "$__destination_path" ]]; then
  _print_installing
  printf "$(_success) Dots installed, run %sdots%s to see options" "$(tput bold)$(tput setaf 6)" "$(_reset_to_normal)"
else
  printf "$(_info) Dots its already installed in %s%s%s" "$(tput bold)$(tput setaf 6)" "$__destination_path" "$(_reset_to_normal)"
fi

echo

# Add ~/.local/bin to the path if needed
if _directory_is_in_path "$__bin_path"; then
  if [ ! -d "$__bin_path" ]; then
    mkdir -p "$__bin_path"
  fi

  ln -fs "${__destination_path}/main.sh" "${__bin_path}/dots"
else
  printf "$(_error) %s is not in $(tput setaf 1)$(tput bold)\$PATH" "$__bin_path"
  echo
fi

# install completions
## bash completions
if [ ! -d "$__bash_user_completions_dir" ]; then
  mkdir -p "$__bash_user_completions_dir"
fi

ln -fs "${__destination_path}/dots.complete.bash" "${__bash_user_completions_dir}/dots"

## zsh completions
#TODO

## fish completions
# sudo cp dots/dots.complete.bash /etc/bash_completion.d/dots

# if [[ -n $(_is_shell_installed fish) ]]; then
#   sudo cp dots/dots.complete.fish /usr/share/fish/vendor_completions.d/dots.fish
# fi
