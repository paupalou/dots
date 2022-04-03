#!/bin/bash
# shellcheck disable=SC2207

__command=dots

_sync_completions() {
  local ACTIONS=([0]="-v" [1]="--verbose")
  COMPREPLY=($(compgen -W "${ACTIONS[*]}" -- "$1"))
}

_config_completions() {
  local ACTIONS=([0]="-c" [1]="--create" [2]="-d" [3]="--default" [4]="-e" [5]="--edit")
  COMPREPLY=($(compgen -W "${ACTIONS[*]}" -- "$1"))
}

_dots_completions() {
  COMPREPLY=()

  local ACTIONS=([0]="sync" [1]="config" [2]="version" [3]="update")
  local cur=${COMP_WORDS[COMP_CWORD]}

  if [[ ($1 == "$__command" && $3 != "$__command") ]]; then
    if [[ $3 == "sync" ]]; then
      _sync_completions "$2"
    fi

    if [[ $3 == "config" ]]; then
      _config_completions "$2"
    fi
  else
    COMPREPLY=($(compgen -W "${ACTIONS[*]}" -- "$cur"))
  fi
}

complete -F _dots_completions dots
