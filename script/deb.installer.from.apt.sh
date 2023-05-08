#!/bin/bash

function _install_deb_from_apt {
  local package_name=$1
  local repository=$2
  local run=$5
  local is_package_dependency=$6

  if [ -n "$repository" ]; then
    local is_ppa_added=$(apt-cache policy | grep -q $repository)
    if [ -z $is_ppa_added ]; then
      print_adding_repository $repository
      sudo add-apt-repository ppa:$repository -y 1>/dev/null
      sudo apt-get update -y 1>/dev/null
      echo $(pc "  ✓" $green)
    fi
  fi

  if [ -n "$run" ]; then
    _run_command "$run"
  fi

  print_installing $package_name "apt" $is_package_dependency
  local debconf_warning="debconf: delaying package configuration, since apt-utils is not installed"
  local templates_warning="Extracting templates from packages: 100%"

  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $1 1>/dev/null 2>&1 | grep -v "$debconf_warning" | grep -v "$templates_warning"

  echo $(pc "  ✓" $green)
}

