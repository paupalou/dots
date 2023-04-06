#!/usr/bin/env bash

if [[ "$__dots_colors_loaded" == true ]]; then
  return 0
fi
__dots_colors_loaded=true

## Foreground
# default color
export def='\e[39m'

# 8 Colors
export black='\e[30m'
export red='\e[31m'
export green='\e[32m'
export yellow='\e[33m'
export blue='\e[34m'
export magenta='\e[35m'
export cyan='\e[36m'
export lgray='\e[37m'

# 16 Colors
export dgray='\e[90m'
export lred='\e[91m'
export lgreen='\e[92m'
export lyellow='\e[93m'
export lblue='\e[94m'
export lmagenta='\e[95m'
export lcyan='\e[96m'
export white='\e[97m'

## Background
# 8 Colors
# default bg color
export defbg='\e[49m'
export blackbg='\e[40m'
export redbg='\e[41m'
export greenbg='\e[42m'
export yellowbg='\e[43m'
export bluebg='\e[44m'
export magentabg='\e[45m'
export cyanbg='\e[46m'
export lgraybg='\e[47m'

# 16 Colors
export dgraybg='\e[100m'
export lredbg='\e[101m'
export lgreenbg='\e[102m'
export lyellowbg='\e[103m'
export lbluebg='\e[104m'
export lmagentabg='\e[105m'
export lcyanbg='\e[106m'
export whitebg='\e[107m'

# used to reset attributes
export normal='\e[0m'
export bold='\e[1m'
export uline='\e[4m'
export inverted='\e[7m'
