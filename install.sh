#!/usr/bin/env bash

__repository_url=https://github.com/paupalou/dots.git
__destination_path=$HOME/.dots
__bin_path=$HOME/.local/bin
__dotfiles_path=$HOME/dotfiles
__bash_user_completions_dir=$XDG_DATA_HOME/bash-completion/completions
__zsh_user_completions_dir=$ZSH/completions
__fish_user_completions_dir=$XDG_CONFIG_HOME/fish/completions
__destination_path_provided=false
__bin_path_provided=false
__dotfiles_path_provided=false

if [ "$#" -gt 0 ]; then
  __dotfiles_path_provided=true
  __dotfiles_path=$1
fi

if [[ -z $XDG_DATA_HOME ]]; then
  __bash_user_completions_dir="$HOME/.local/share/bash-completion/completions"
fi

if [[ -z $XDG_CONFIG_HOME ]]; then
  __fish_user_completions_dir="$HOME/.config/fish/completions"
fi

if [[ -z $ZSH ]]; then
  __zsh_user_completions_dir="$HOME/.local/share/zsh/completions"
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

function _set_dotfiles_path {
  if [[ $__dotfiles_path_provided = false ]]; then
    local __user_dotfiles_path
    read -rep "$(_question) Dotfiles path [$(tput bold)$(tput setaf 3)${__dotfiles_path}$(tput sgr0)]:" __user_dotfiles_path
    __dotfiles_path=${__user_dotfiles_path:-$__dotfiles_path}
  fi
  echo
}

function _generate_user_config {
  local dots_config=${__dotfiles_path}/dots/.config/dots/config.yaml

  if [[ ! -d ${__dotfiles_path}/dots/.config/dots ]]; then
    mkdir -p "${__dotfiles_path}/dots/.config/dots"
  fi

  if [[ ! -f $dots_config ]]; then
    touch "$dots_config"
    echo "# user config file" >> "$dots_config"
  fi

  if [[ $(grep "dotfiles_path" "$dots_config" --count) == 0 ]]; then
    echo "dotfiles_path: ${__dotfiles_path}" >> "$dots_config"
  fi
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
}
function _print_installing_success {
  printf "$(_success) Dots installed, run %sdots$(_reset_to_normal) to see options" "$(tput bold)$(tput setaf 6)"
  echo
}


function _check_dots_bin_path {
  if _directory_is_in_path "$__bin_path"; then
    if [ ! -d "$__bin_path" ]; then
      mkdir -p "$__bin_path"
    fi

    ln -fs "${__destination_path}/main.sh" "${__bin_path}/dots"
  else
    # TODO Add ~/.local/bin to the path if needed
    printf "$(_error) %s is not in $(tput setaf 1)$(tput bold)\$PATH" "$__bin_path"
    _reset_to_normal
    echo
  fi
}

function _install_shell_completions {
  # install completions
  ## bash completions
  if [ ! -d "$__bash_user_completions_dir" ]; then
    mkdir -p "$__bash_user_completions_dir"
  fi

  ln -fs "${__destination_path}/dots.complete.bash" "${__bash_user_completions_dir}/dots"

  ## zsh completions
  if _is_shell_installed "zsh"; then
    if [ ! -d "$__zsh_user_completions_dir" ]; then
      mkdir -p "$__zsh_user_completions_dir"
    fi

    ln -fs "${__destination_path}/dots.complete.zsh" "${__zsh_user_completions_dir}/_dots"
  fi

  ## fish completions
  if _is_shell_installed "fish"; then
    if [ ! -d "$__fish_user_completions_dir" ]; then
      mkdir -p "$__fish_user_completions_dir"
    fi

    ln -fs "${__destination_path}/dots.complete.fish" "${__fish_user_completions_dir}/dots.fish"
  fi
}

function _dots_already_installed {
  if [ -d "$__destination_path" ]; then
    true
  else
    false
  fi
}

if _dots_already_installed; then
  printf "$(_info) Dots its already installed in %s%s%s" "$(tput bold)$(tput setaf 6)" "$__destination_path" "$(_reset_to_normal)"
  echo
  exit 0
fi

_ask_dotfiles_path
_generate_user_config
_print_installing
_clone_dots
_print_installing_success
_check_dots_bin_path
_install_shell_completions
