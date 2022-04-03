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

function _get_config_setting() {
  local config_key=$1

  eval default_config_value="( \${dots_default_${config_key}[@]} )"
  eval user_config_value="( \${dots_user_${config_key}[@]} )"

  local user_config_setting=dots_user_$config_key
  local user_config_value=${!user_config_setting}

  local config_value

  if [[ -z ${user_config_value} ]]; then
    config_value=( "${default_config_value[@]}" )
  else
    config_value=( "${user_config_value[@]}" )
  fi

  local result
  for i in "${config_value[@]}"; do
    if [[ -z ${!i} ]]; then
      result+=$i
    else
      result+="${!i}"
    fi
  done
  echo "$result"
}

function _create_config {
  local dotfiles_path
  dotfiles_path=$(_get_config_setting "dotfiles_path")

  if [[ -f ${dotfiles_path}/dots/config.yaml ]]; then
    printf "Config file already exists: %s%s%s" "$(tput bold)" "$__user_config" "$(tput sgr0)"
    echo
    exit 1
  fi

  if [[ ! -d ${dotfiles_path}/dots ]]; then
    mkdir -p "${dotfiles_path}/dots"
  fi

  touch "${dotfiles_path}/dots/config.yaml"
  echo "# user config file" >> "${dotfiles_path}/dots/config.yaml"
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

_create_variables "$__default_config" "dots_default"

if [[ -z $XDG_CONFIG_HOME ]]; then
  __user_config=$HOME/.config/dots/config.yaml
fi

if [[ -f "$__user_config" ]]; then
  _create_variables "$__user_config" "dots_user"
fi
