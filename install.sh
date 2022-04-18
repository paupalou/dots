#!/usr/bin/env bash

__repository_url=https://github.com/paupalou/dots.git
__destination_path=$HOME/.dots
__bin_path=$HOME/.local/bin
__bash_user_completions_dir=$XDG_DATA_HOME/bash-completion/completions
__fish_user_completions_dir=$XDG_CONFIG_HOME/fish/completions
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

if [[ -z $XDG_CONFIG_HOME ]]; then
  __fish_user_completions_dir="$HOME/.config/fish/completions"
fi

function _is_shell_installed {
  if [[ -n $(which "$1") ]]; then
    return 0
  fi

  return 1
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

if [ ! -d "$__destination_path" ]; then
  _print_installing
  printf "$(_success) Dots installed, run %sdots$(_reset_to_normal) to see options" "$(tput bold)$(tput setaf 6)"
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
  _reset_to_normal
  echo
fi

# install completions
## bash completions
if [ ! -d "$__bash_user_completions_dir" ]; then
  mkdir -p "$__bash_user_completions_dir"
fi

ln -fs "${__destination_path}/dots.complete.bash" "${__bash_user_completions_dir}/dots"

## zsh completions
# TODO Make native zsh completions
if _is_shell_installed "zsh"; then
  if [[ $(grep -c "bashcompinit" < "$HOME/.zshrc") -eq 0 ]]; then
    echo "autoload bashcompinit && bashcompinit" | tee -a "$HOME/.zshrc" >/dev/null
  fi

  if [[ $(grep -c "dots.complete.bash" < "$HOME/.zshrc") -eq 0 ]]; then
    echo "source ${__destination_path}/dots.complete.bash" | tee -a "$HOME/.zshrc" >/dev/null
  fi
fi

## fish completions
if _is_shell_installed "fish"; then
  if [ ! -d "$__fish_user_completions_dir" ]; then
    mkdir -p "$__fish_user_completions_dir"
  fi

  ln -fs "${__destination_path}/dots.complete.fish" "${__fish_user_completions_dir}/dots.fish"
fi
