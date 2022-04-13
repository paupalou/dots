#!/usr/bin/env bash
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

  local user_config_setting=dots_user_$config_key
  local user_config_value=${!user_config_setting}

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
  for i in "${__config_value[@]}"; do
    result+="$i"
  done
  echo "$result"
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
  local dotfiles_path dots_config
  eval dotfiles_path="$(_dots_setting "dotfiles_path")"
  dots_config=${dotfiles_path}/dots/config.yaml

  if [[ ! -d ${dotfiles_path}/dots ]]; then
    mkdir -p "${dotfiles_path}/dots"
  fi

  if [[ ! -f $dots_config ]]; then
    touch "$dots_config"
    echo "# user config file" >> "$dots_config"
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
    _link_dots_config "$dots_config"
  fi

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
    bat "$config"
  else
    cat "$config"
  fi
}

function _edit_config() {
  $EDITOR "$__user_config"
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
