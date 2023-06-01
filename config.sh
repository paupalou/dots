#!/usr/bin/env bash

# do not re-source this file if its already sourced
if [[ -f $__user_config ]] || [[ -f $__default_config ]]; then
  return
fi

# shellcheck disable=SC1003

# Based on https://gist.github.com/pkuczynski/8665367

function _parse_yaml() {
  local yaml_file=$1
  local prefix=$2
  local s
  local w
  local fs

  s='[[:space:]]*'
  w='[a-zA-Z0-9_.-]*'
  fs="$(echo @ | tr @ '\034')"

  (
    sed -e '/- [^\“]'"[^\']"'.*: /s|\([ ]*\)- \([[:space:]]*\)|\1-\'$'\n''  \1\2|g' |
        sed -ne '/^--/s|--||g; s|\"|\\\"|g; s/[[:space:]]*$//g;' \
            -e 's/\$/\\\$/g' \
            -e "/#.*[\"\']/!s| #.*||g; /^#/s|#.*||g;" \
            -e "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
            -e "s|^\($s\)\($w\)${s}[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" |
        awk -F"$fs" '{
        indent = length($1)/2;
        if (length($2) == 0) { conj[indent]="+";} else {conj[indent]="";}
        vname[indent] = $2;
        for (i in vname) {if (i > indent) {delete vname[i]}}
            if (length($3) > 0) {
                vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
                printf("%s%s%s%s=(\"%s\")\n", "'"$prefix"'",vn, $2, conj[indent-1], $3);
            }
        }' |
        sed -e 's/_=/+=/g' |
        awk 'BEGIN {
            FS="=";
            OFS="="
        }
        /(-|\.).*=/ {
            gsub("-|\\.", "_", $1)
        }
        { print }'
  ) <"$yaml_file"
}

function _unset_variables() {
  # Pulls out the variable names and unsets them.
  #shellcheck disable=SC2048,SC2206 #Permit variables without quotes
  local variable_string=($*)
  unset variables
  variables=()
  for variable in "${variable_string[@]}"; do
    tmpvar=$(echo "$variable" | grep '=' | sed 's/=.*//' | sed 's/+.*//')
    variables+=("$tmpvar")
  done
  for variable in "${variables[@]}"; do
    if [ -n "$variable" ]; then
      unset "$variable"
    fi
  done
}

function _create_variables() {
  local yaml_file="$1"
  local prefix="$2"
  local yaml_string
  yaml_string="$(_parse_yaml "$yaml_file" "${prefix}_")"
  _unset_variables "${yaml_string}"
  eval "${yaml_string}"
}


function _read_config_value {
  local config_key=$1

  eval default_config_value="( \${dots_default_${config_key}[@]} )"
  eval user_config_value="( \${dots_user_${config_key}[@]} )"

  unset __config_value

  if [[ -z ${user_config_value} ]]; then
    __config_value=( "${default_config_value[@]}" )
  else
    __config_value=( "${user_config_value[@]}" )
  fi
}

function _dots_setting {
  _read_config_value "$1"
  local result
  local user_directory
  user_directory="$HOME"
  for i in "${__config_value[@]}"; do
    result+="$i"
  done

  case $result in
    *"\$HOME"*)
      echo "${result/\$HOME/${user_directory}}"
      ;;
    *"~"*)
      echo "${result/\~/${user_directory}}"
      ;;
    *)
      echo "$result"
  esac
}

function _dots_color {
  _read_config_value "$1"
  local result
  for i in "${__config_value[@]}"; do
    eval result+="\$${i}"
  done
  echo "$result"
}

function _link_dots_config {
  local success_char success_style
  success_char=$(_dots_setting "success_char")
  success_style=$(_dots_color "success_style")

  ln -sfn "$1" "$__user_config"
  _print_colored "$success_char" "$success_style"
  _space
  _print "config file:"
  _space
  _print_colored "$1" "$uline"
  _print_colored " -> " "$bold"
  _print_colored "$__user_config" "$uline"
  _newline
}


function _create_config {
  #shellcheck disable=SC2119
  _print_dots_title
  _newline
  read -rp "Create a tag for this config [none]: " user_tag 
  local dotfiles_path dots_config
  eval dotfiles_path="$(_dots_setting "dotfiles_path")"
  if [[ -n $user_tag ]]; then
    dots_config=${dotfiles_path}/dots/.config/dots/config:${user_tag}.yaml
  else
    dots_config=${dotfiles_path}/dots/.config/dots/config.yaml
  fi

  if [[ ! -d ${dotfiles_path}/dots/.config/dots ]]; then
    mkdir -p "${dotfiles_path}/dots/.config/dots"
  fi

  if [[ ! -f $dots_config ]]; then
    touch "$dots_config"
    echo "# user config file" >> "$dots_config"
    if [[ -n $user_tag ]]; then
      echo "dotfiles:" >> "$dots_config"
      echo "  tag: $user_tag" >> "$dots_config"
    fi
  fi

  if [[ -f $__user_config ]]; then
    if [[ $(readlink "$__user_config") != "$dots_config" ]]; then
      printf "Config file exists: %s%s%s" "$(tput bold)" "$__user_config" "$(tput sgr0)"
      echo
      printf "Renaming to: %s%s%s" "$(tput bold)" "${__user_config}.backup" "$(tput sgr0)"
      echo
      mv "$__user_config" "${__user_config}.backup"
      _link_dots_config "$dots_config"
      echo
      exit
    else
      printf "Config file already linked: %s%s%s" "$(tput bold)" "$__user_config" "$(tput sgr0)"
      echo
      exit
    fi
  else
    if [[ ! -d $(dirname "$__user_config") ]]; then
      mkdir -p "$(dirname "$__user_config")"
    fi
    _link_dots_config "$dots_config"
  fi
}

function _write_to_config {
  if [[ ! -f $__user_config ]]; then
    _create_config
  fi

  echo "$1" >> "$__user_config"
}

function _echo_config {
  local default=$1
  local config

  if [[ -z $default ]]; then
    config=$__user_config
  else
    config=$__default_config
  fi

  if [[ -n $(which bat) ]]; then
    bat --style="grid,header,numbers" "$config"
  else
    cat "$config"
  fi
}

function _edit_config() {
  if [[ -n $EDITOR ]]; then
    $EDITOR "$__user_config"
  elif [[ -n $(which nvim) ]];then
    nvim "$__user_config"
  elif [[ -n $(which vim) ]];then
    vim "$__user_config"
  else
    vi "$__user_config"
  fi
}

__dots_folder=$(dirname "$(readlink "$(which dots)")")
__default_config=${__dots_folder}/default.yaml
__user_config=$XDG_CONFIG_HOME/dots/config.yaml

source "${__dots_folder}/printer.sh"

_create_variables "$__default_config" "dots_default"

if [[ -z $XDG_CONFIG_HOME ]]; then
  __user_config=$HOME/.config/dots/config.yaml
fi

if [[ -f "$__user_config" ]]; then
  _create_variables "$__user_config" "dots_user"
fi
