# Sync
complete --command dots --no-files --condition __fish_use_subcommand --arguments sync -d "Symlink dotfiles"
complete --command dots --no-files --condition "__fish_seen_subcommand_from sync" --arguments --verbose -d "Print each file result"
complete --command dots --no-files --condition "__fish_seen_subcommand_from sync" -s v

# Config
complete --command dots --no-files --condition __fish_use_subcommand --arguments config -d "Prints dots user config"

complete --command dots --exclusive --condition "__fish_seen_subcommand_from config" --arguments --create -d "Create dots user config file"
complete --command dots --exclusive --condition "__fish_seen_subcommand_from config" --short c -d "Create dots user config file"

complete --command dots --exclusive --condition "__fish_seen_subcommand_from config" --arguments --default -d "Prints dots default config"
complete --command dots --exclusive --condition "__fish_seen_subcommand_from config" --short d -d "Prints dots default config"

complete --command dots --exclusive --condition "__fish_seen_subcommand_from config" --arguments --edit -d "Open $EDITOR to edit dots config file"
complete --command dots --exclusive --condition "__fish_seen_subcommand_from config" --short e -d "Open $EDITOR to edit dots config file"

# Version
complete --command dots --no-files --condition __fish_use_subcommand --arguments version -d "Prints dots version"

# Update
complete --command dots --no-files --condition __fish_use_subcommand --arguments update -d "Update dots to last version"
