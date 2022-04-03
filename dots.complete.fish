# Sync
complete --command dots --no-files --condition __fish_use_subcommand --arguments sync -d "Symlink dotfiles"
complete --command dots --no-files --condition "__fish_seen_subcommand_from sync" --arguments --verbose -d "Print each file result"
complete --command dots --no-files --condition "__fish_seen_subcommand_from sync" -s v

# Config
complete --command dots --no-files --condition __fish_use_subcommand --arguments config -d "Prints dots user config"

complete --command dots --no-files --condition "__fish_seen_subcommand_from config" -d "Create dots user config file"
complete --command dots --exclusive --condition "__fish_seen_subcommand_from config" --short c
complete --command dots --exclusive --condition "__fish_seen_subcommand_from config" --long create

complete --command dots --no-files --condition "__fish_seen_subcommand_from config" -d "Prints dots default config"
complete --command dots --exclusive --condition "__fish_seen_subcommand_from config" --short d
complete --command dots --exclusive --condition "__fish_seen_subcommand_from config" --long default

complete --command dots --no-files --condition "__fish_seen_subcommand_from config" -d "Open $EDITOR to edit dots config file"
complete --command dots --exclusive --condition "__fish_seen_subcommand_from config" --short e
complete --command dots --exclusive --condition "__fish_seen_subcommand_from config" --long edit

# Version
complete --command dots --no-files --condition __fish_use_subcommand --arguments version -d "Prints dots version"

# Update
complete --command dots --no-files --condition __fish_use_subcommand --arguments update -d "Update dots to last version"
