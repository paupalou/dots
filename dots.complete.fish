# Sync
complete --command dots --condition __fish_use_subcommand --arguments sync -d "Symlink dotfiles"
complete --no-files --command dots --condition "__fish_seen_subcommand_from sync"
complete --no-files --command dots --condition "__fish_seen_subcommand_from sync; and __fish_not_contain_opt -s v verbose"  --short-option v --long-option verbose -d "Print each file result"
complete --no-files --command dots --condition "__fish_seen_subcommand_from sync; and __fish_contains_opt -s v verbose"

# Config
complete --command dots --no-files --condition __fish_use_subcommand --arguments config -d "Prints dots user config"

set -l config_commands create default edit

complete --no-files --command dots --condition "__fish_seen_subcommand_from config; and not __fish_seen_subcommand_from $config_commands" --arguments create -d "Create dots user config file"
complete --no-files --command dots --condition "__fish_seen_subcommand_from config; and not __fish_seen_subcommand_from $config_commands" --arguments default -d "Prints dots default config"
complete --no-files --command dots --condition "__fish_seen_subcommand_from config; and not __fish_seen_subcommand_from $config_commands" --arguments edit -d "Open $EDITOR to edit dots config file"
complete --no-files --command dots --condition "__fish_seen_subcommand_from config; and __fish_seen_subcommand_from $config_commands"

# Version
complete --command dots --no-files --condition __fish_use_subcommand --arguments version -d "Prints dots version"
complete --no-files --command dots --condition "__fish_seen_subcommand_from update"

# Update
complete --command dots --no-files --condition __fish_use_subcommand --arguments update -d "Update dots to last version"
complete --no-files --command dots --condition "__fish_seen_subcommand_from version"
