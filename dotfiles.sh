#!/usr/bin/env bash
# shellcheck disable=SC2086

if [[ "$__dots_dotfiles_loaded" == true ]]; then
  return 0
fi
__dots_dotfiles_loaded=true

__dots_folder=$(dirname "$(readlink "$(which dots)")")

source "${__dots_folder}/system.sh"
source "${__dots_folder}/config.sh"
source "${__dots_folder}/printer.sh"
source "${__dots_folder}/box.sh"

function _excluded_files {
  echo -e \( \( ! -path "*/fish/*" -a ! -name "*.fish" \) -o -path "*/fish/*" -a -name "*" \)
}

function _path_not_match {
  local result
  for i in "${@}"; do
    result+=" ! -path */${i}"
  done

  echo "$result"
}

function _print_topic {
  local topic=$1
  local sync_topic_icon_char
  local message

  sync_topic_icon_char=$(_dots_setting "sync_topic_icon_char")
  message="x $topic"

  _box_line_start
  _print_colored "$sync_topic_icon_char" "$(_dots_color "sync_topic_icon_style")"
  _space
  _print_colored "$topic" "$(_dots_color "sync_topic_style")"
  _box_line_end ${#message}
  _newline
}

function _print_skipped_files {
  local file_count=$1
  local message
  local left_padding

  if [[ $file_count -eq 0 ]]; then
    return
  fi

  left_padding=2
  message="x $file_count file"
  if [[ $file_count -gt 1 ]]; then
    message="${message}s"
  fi

  _box_line_start
  _space $left_padding
  _success_icon
  _space
  _print "$file_count"
  _space
  if [[ $file_count -gt 1 ]]; then
    _print_colored "files" "$lgray"
  else
    _print_colored "file" "$lgray"
  fi
  _box_line_end $((left_padding + ${#message}))
  _newline
}

function _sync_dotfiles {
  _box_start "sync dotfiles" "$(_dots_color "sync_title")"
  _disable_input

  local verbose=$1
  local overwrite_all=false backup_all=false skip_all=false
  local excluded_files excluded_paths dotfiles files

  _disable_globbing
  dotfiles_tag=$(_dots_setting "dotfiles_tag")
  excluded_files=$(_excluded_files)
  excluded_paths=$(_path_not_match ".git")
  dotfiles=$(_dots_setting "dotfiles_path")

  # TODO Check if fd is available then find as fallback
  # for topic in $(fd --base-directory $dotfiles --type d | sort); do

  for topic in $(find -H "$dotfiles" -mindepth 1 -maxdepth 1 -type d $excluded_paths $excluded_files -exec basename {} \; | sort); do
    _disable_globbing
    excluded_paths=$(_path_not_match "*/.git/*")
    files=$(find -H "$dotfiles/$topic" -type f $excluded_paths $excluded_files)
    # files=$(fd . ${dotfiles}/${topic} --type f --hidden --exclude '*:*' --exclude path.fish --exclude '.git')
    local skipped_files_counter=0

    if [[ ${#files} -gt 0 ]]; then
      _print_topic $topic
    fi
    _enable_globbing
    for file_full_path in $files; do
      file=$(basename "$file_full_path")
      # tagged files processing
      # avoid processing same file twice
      if [[ $file =~ ":" ]]; then
        if [[ ! $file =~ :${dotfiles_tag}.* ]]; then
          # tag doest not match, continue with next file
          continue
        else
          if [[ -f ${file_full_path/:*./.} ]]; then
            # default file exists, this file will be processed later
            continue
          else
            # default file not exists, convert this file to default
            # _grab_file will get correct one
            file=${file/:*./.}
          fi
        fi
      fi

      src_dirname=$(dirname "$file_full_path")
      file_depth=$(echo "$src_dirname" | grep -o / | wc -l)
      if [[ $file_depth -lt 5 ]]; then
        destiny=$HOME/$file
      else
        destiny=$HOME/$(echo "$src_dirname" | cut -d'/' -f6-)/$file
      fi
      matching_file=$(_grab_file "$src_dirname/$file")

      _link_file "$matching_file" "$destiny" "$verbose"
    done

    if [[ -z "$verbose" ]] || [[ "$verbose" == false ]]; then
      _print_skipped_files "$skipped_files_counter"
    fi

  done

  _enable_input
  _box_end
}

function _link_file {
  local src=$1 dst=$2 verbose=$3
  local skip

  if [ -f "$dst" ] || [ -d "$dst" ] || [ -L "$dst" ]; then
    if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]; then
      local currentSrc
      currentSrc="$(readlink "$dst")"
      if [ "$currentSrc" == "$src" ]; then
        if [[ "$verbose" == true ]]; then
          _file_synced "$src" "$dst"
        else
          ((skipped_files_counter += 1))
        fi
        return
      fi
    fi
  fi

  if [ "$skip" != "true" ]; then
    if [[ ! -d $(dirname "$dst") ]]; then
      mkdir -p "$(dirname "$dst")"
    fi

    ln -sfn "$src" "$dst"
    _file_linked "$src" "$dst" "$verbose"
    ((file_counter -= 1))
  fi
}

function _file_synced {
  local destiny=$2
  local item_length
  local file_path
  local file_full_path
  local left_padding
  local printable_path

  file_path=${destiny/#$HOME/'~'}
  src_max_length=$(($(_box_line_max_length) - 4))
  item_length="x ${file_path:0:src_max_length}"
  printable_path=${file_path:0:src_max_length}
  left_padding=2

  if [[ ${#file_path} -gt $(_box_line_max_length) ]]; then
    printable_path=${printable_path:0:$((${#printable_path} - 3))}
    printable_path="${printable_path}..."
  fi

  _box_line_start
  _space $left_padding
  _success_icon
  _space
  _print_colored "$printable_path" "$lgray"
  _box_line_end $((left_padding + ${#item_length}))
  _newline
}

function _file_linked {
  local destiny=$2
  local src
  local item_length
  local destiny_max_length
  local file_path
  local left_padding

  src=$(basename "$1")
  file_path=${destiny/#$HOME/'~'}
  src_max_length=$(($(_box_line_max_length) - 4))
  destiny_max_length=$((src_max_length - 2))
  item_length="x ${src:0:src_max_length}"
  left_padding=2

  local printable_file_name=${src:0:src_max_length}
  if [[ ${#src} -gt $(_box_line_max_length) ]]; then
    printable_file_name=${printable_file_name:0:$((${#printable_file_name} - 3))}
    printable_file_name="${printable_file_name}..."
  fi

  _box_line_start
  _space $left_padding
  _link_icon
  _space
  _print_colored "${printable_file_name}" "$bold"
  _box_line_end $((left_padding + ${#item_length}))
  _newline

  _box_line_start
  left_padding=4
  _space $left_padding

  local printable_path=${file_path:0:destiny_max_length}
  if [[ ${#file_path} -gt $(_box_line_max_length) ]]; then
    printable_path=${printable_path:0:$((${#printable_path} - 3))}
    printable_path="${printable_path}..."
  fi

  item_length="└ ${printable_path}"
  _print_colored "└" "$dgray"
  _space
  _print_colored "${printable_path}" "$lgray"
  _box_line_end $((left_padding + ${#item_length}))
  _newline
}
