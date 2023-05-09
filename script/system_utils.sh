#!/bin/bash

function _check_sudo {
	if ! command -v sudo &> /dev/null; then
		echo "sudo is not installed, install it (as root)"
		exit 1
	fi
}

function _set_localtime {
	local localtime_file=/etc/localtime
	if [ ! -f "$localtime" ]; then
		local TZ=Europe/Madrid
		sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
	fi
}

function _run_command {
	eval "$1" &>/dev/null
}

function _get_distro {
	echo $(cat /etc/*-release | grep '^ID=' | cut -d "=" -f 2)
}

function _get_machine_hostname {
	echo $(hostnamectl | grep 'Static hostname' | cut -d ":" -f 2 | cut -b 2-)
}

# function _grab_file {
# 	local generic_file=$1
#   local file_path=$(dirname $generic_file)
#   local file_basename=$(echo $(basename $generic_file) | cut -d "." -f 1)
# 	local file_extension=$(echo $(basename $generic_file) | cut -d "." -f 2)
#
# 	local expected_file="${file_path}/${file_basename}:$(_get_distro):$(_get_machine_hostname).${file_extension}"
#
# 	if [ ! -f "$expected_file" ]; then
#     expected_file="${file_path}/${file_basename}:$(_get_distro).${file_extension}"
# 	fi
#
# 	if [ -f "$expected_file" ]; then
# 		echo $expected_file
# 	else
# 		echo $generic_file
# 	fi
# }

function _get_value {
	local prop=$1_$2
	local value=${!prop}
	if [ -n "$value" ]; then
		echo $value
	else
		echo $3
	fi
}

function _is_checker_loaded {
	declare -F "_is_${1}_installed" > /dev/null
}

function _is_installer_loaded {
	declare -F "_install_${1}_from_${2}" > /dev/null
}

function _run_hooks {
	local hook_type=$1
	local item=$2

	local hooks=${item}_${hook_type}_

	for hook in ${!hooks}; do
		if [ -n "$hook" ]; then
			_run_command "${!hook}"
		fi
	done
}
