#compdef dots
typeset -A opt_args

_arguments -C \
  '1:cmd:->cmds' \
  '2:cmd_option:->cmd_options' \
&& ret=0

case "$state" in
  (cmds)
    local commands; commands=(
      'sync:Symlink dotfiles'
      'config:Prints dots user config'
      'update:Update dots to last version'
      'version:Prints dots version'
     )

     _describe -t commands 'command' commands && ret=0
     ;;
   (cmd_options)
     case $line[1] in
       (sync)
         local sync_options; sync_options=(
           '-v:Print each file result'
           '--verbose:Print each file result'
         )
         _describe -t sync_options 'sync' sync_options && ret=0
       ;;
       (config)
         local config_options; config_options=(
           '-c:Create dots user config file'
           '--create:Create dots user config file'
           '-d:Print dots default config'
           '--default:Print dots default config'
           '-e:Open $EDITOR to edit dots config file'
           '--edit:Open $EDITOR to edit dots config file'
         )
         _describe -t config_options 'config' config_options && ret=0
       ;;
    esac
    ;;
esac

return 1
