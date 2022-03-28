#!/usr/bin/env bash

__repository_url=https://github.com/paupalou/dots.git
__version_url=https://raw.githubusercontent.com/paupalou/dots/main/version
__dots_folder=$(dirname "$(readlink "$(which dots)")")
__dots_version=$(cat "$__dots_folder"/version)

printf "Checking updates... "

function _is_last_version_installed {
  local installed_version last_version
  local padding=0000

  installed_version=$(echo "$__dots_version" | tr -d .)
  last_version=$(wget -qO - "$__version_url" | tr -d .)

  installed_version=$(printf "%s%s" "$installed_version" "${padding:${#installed_version}}")
  last_version=$(printf "%s%s" "$last_version" "${padding:${#last_version}}")

  installed_version=${installed_version#0??}
  last_version=${last_version#0??}

  if [[ $installed_version -eq $last_version ]]; then
    true
  elif [[ $installed_version -lt $last_version ]]; then
    false
  else
    printf "version file corrupted, please reinstall"
    echo
    exit 1
  fi
}

if _is_last_version_installed; then
  echo "Dots is already last version"
else
  echo "Update required"
fi

# cd "$__destination_path" || exit 1
# echo
# _clone_dots
# # git pull
# echo
