#!/bin/bash

__repository_url=https://github.com/paupalou/dots.git
__destination_path=$HOME/.dots
__bin_path=$HOME/.local/bin
__bash_user_completions_dir=$XDG_DATA_HOME/bash-completion/completions

if [ "$#" -gt 0 ]; then
  __destination_path=$1
fi

if [ "$#" -gt 1 ]; then
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
  fi

  false
}


if [ ! -d "$__destination_path" ]; then
  printf "Installing dots on $(tput bold)%s" "$__destination_path"
  _reset_to_normal
  _clone_dots
  echo
  # sudo ln -s "$(pwd)/dots/main.sh" "${1?"$HOME/.dots"}"
  #TODO
  # else if version == dots installed version print dots is latest version blalba
else
  printf "Updating dots"
  cd "$__destination_path" || exit 1
  git pull
  echo
fi

# Add ~/.local/bin to the path if needed
if _directory_is_in_path "$__bin_path"; then
  printf "%s is not in \$PATH" "$__bin_path"
  echo
else
  if [ ! -d "$__bin_path" ]; then
    mkdir -p "$__bin_path"
  fi

  ln -fs "${__destination_path}/main.sh" "${__bin_path}/dots"
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
