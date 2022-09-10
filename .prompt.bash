# Bash History Replacement Script
#    Author: Caesar Kabalan
#    Last Modified: June 6th, 2017
# Description:
#    Modifies the default Bash Shell prompt to be in the format of:
#       [CWD:COUNT:BRANCH:VENV]
#       [USER:HOSTNAME] _
#    Where:
#       CWD - Current working directory (green if last command returned 0, red otherwise)
#       COUNT - Session command count
#       BRANCH - Current git branch if in a git repository, omitted if not in a git repo
#       VENV - Current Python Virtual Environment if set, omitted if not set
#       USER - Current username
#       HOSTNAME - System hostname
#    Example:
#       [~/projects/losteyelid:8:master:losteyelid]
#       [ckabalan:spectralcoding] _
# Installation:
#    Add the following to one of the following files
#       System-wide Prompt Change:
#          /etc/profile.d/bash_prompt_custom.sh (new file)
#          /etc/bashrc
#       Single User Prompt Change:
#          ~/.bashrc
#          ~/.bash_profile

function set_bash_prompt () {
	# Color codes for easy prompt building
	COLOR_DIVIDER="\[\e[30;1m\]"
	COLOR_CMDCOUNT="\[\e[34;1m\]"
	COLOR_USERNAME="\[\e[34;1m\]"
	COLOR_USERHOSTAT="\[\e[34;1m\]"
	COLOR_HOSTNAME="\[\e[34;1m\]"
	COLOR_GITBRANCH="\[\e[33;1m\]"
	COLOR_VENV="\[\e[33;1m\]"
	COLOR_GREEN="\[\e[32;1m\]"
	COLOR_PATH_OK="\[\e[32;1m\]"
	COLOR_PATH_ERR="\[\e[31;1m\]"
	COLOR_NONE="\[\e[0m\]"
	# Change the path color based on return value.
	if test $? -eq 0 ; then
		PATH_COLOR=${COLOR_PATH_OK}
	else
		PATH_COLOR=${COLOR_PATH_ERR}
	fi
	# Set the PS1 to be "[workingdirectory:commandcount"
	PS1="${COLOR_DIVIDER}[${PATH_COLOR}\w${COLOR_DIVIDER}:${COLOR_CMDCOUNT}\#${COLOR_DIVIDER}"
	# Add git branch portion of the prompt, this adds ":branchname"
	if ! git_loc="$(type -p "$git_command_name")" || [ -z "$git_loc" ]; then
		# Git is installed
		if [ -d .git ] || git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
			# Inside of a git repository
			GIT_BRANCH=$(git symbolic-ref --short HEAD)
			PS1="${PS1}:${COLOR_GITBRANCH}${GIT_BRANCH}${COLOR_DIVIDER}"
		fi
	fi
	# Add Python VirtualEnv portion of the prompt, this adds ":venvname"
	if ! test -z "$VIRTUAL_ENV" ; then
		PS1="${PS1}:${COLOR_VENV}`basename \"$VIRTUAL_ENV\"`${COLOR_DIVIDER}"
	fi
	# Close out the prompt, this adds "]\n[username@hostname] "
	PS1="${PS1}]\n${COLOR_DIVIDER}[${COLOR_USERNAME}\u${COLOR_USERHOSTAT}@${COLOR_HOSTNAME}\h${COLOR_DIVIDER}]${COLOR_NONE} "
}

# Tell Bash to run the above function for every prompt
#export PROMPT_COMMAND=set_bash_prompt

# Set PS variables for use by 'update_ps1'
if [[ $EUID == 0 ]]
then
	PS_START="\\[\\033[01;31m\\][\\h \\[\\033[01;36m\\]\\W\\[\\033[01;31m\\]]\\[\\033[0m\\]"
	PS_SYMBOL="#"
else
	PS_START="[\\u@\\h \\[\\033[38;5;81m\\]\\W\\[\\033[0m\\]]"
	PS_SYMBOL="$"
fi

function update_ps1 {
	# get the last command's exit status, then color symbol
	# blue if exit code was 0, red if not
	# (disable "Check exit code directly" because we are checking the last user executed exit code)
	# shellcheck disable=SC2181
	if [[ $? -eq 0 ]]
	then
		local symbol="\\[\\033[1;38;5;81m\\]${PS_SYMBOL:-%}\\[\\033[0m\\]"
	else
		local symbol="\\[\\033[1;38;5;09m\\]${PS_SYMBOL:-%}\\[\\033[0m\\]"
	fi
	# check if we are inside a git repository
	if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" == true ]]
	then
		# check if we are ahead of remote repository, then color git indicator
		# green if up to date, red if ahead
		if [[ -z $(git log origin/master..HEAD 2>/dev/null) ]]
		then
			local git_status="\\[\\033[1;38;5;10m\\](git)\\[\\033[0m\\]"
		else
			local git_status="\\[\\033[1;38;5;09m\\](git)\\[\\033[0m\\]"
		fi
	fi
	export PS1="${PS_START:-}${git_status:-}$symbol "
}

#Call 'update_ps1' after every command
PROMPT_COMMAND='update_ps1'

#!/bin/bash

# Cleaned up version of ps1_notifications.sh made on 2018-08-05
# 
# See rybak/scriptps github repository for the full version
# link: https://github.com/rybak/scripts/blob/master/config/ps1_notifications.sh

# copy of lib/colors.sh instead of calling source "$HOME/scripts/lib/colors.sh"

BLACK_FG="$(tput setaf 0)"
RED_FG="$(tput setaf 1)"
GREEN_FG="$(tput setaf 2)"
YELLOW_FG="$(tput setaf 3)"
BLUE_FG="$(tput setaf 4)"
MAGENTA_FG="$(tput setaf 5)"
CYAN_FG="$(tput setaf 6)"
WHITE_FG="$(tput setaf 7)"

BLACK="$BLACK_FG"
RED="$RED_FG"
GREEN="$GREEN_FG"
YELLOW="$YELLOW_FG"
BLUE="$BLUE_FG"
MAGENTA="$MAGENTA_FG"
CYAN="$CYAN_FG"
WHITE="$WHITE_FG"

RESET_FONT="\e[0m"
BRIGHT_FG="\e[1m"
DIM_FG="\e[2m"
HIGHLIGHT_FONT="\e[4m"

PS_RESET_FONT='\[\e[0m\]'

function ps1_reset_font() {
    PS1="$PS1${PS_RESET_FONT}"
}

# /colors.sh

__TOP_BRACKET="\[\e[2m\]┌─"
__BOTTOM_BRACKET="\\[\\e[2m\\]└─"
# set up simple PS1
PS1=
ps1_reset_font
USERNAME_FONT='\033[0;33;93m'
HOSTNAME_FONT='\033[0;32m'
PS1="$__BRACKET_COLOR${__TOP_BRACKET}$PS1\[$USERNAME_FONT\]"'\u' # user
PS1="$PS1\[$WHITE\]"'@'  # @
PS1="$PS1\[$HOSTNAME_FONT\]"'\h' # host
ps1_reset_font

PS1="${PS1}\[\033[01;34m\]" # change to directory color
PS1="$PS1"'\w'              # current working directory

#NODE_VER=`node -v | cut -d'.' -f1-2 | cut -c2-`
#RUBY_VER=`ruby -v | cut -d' ' -f2 | cut -d'.' -f1-2`
#PS1="$PS1\[$MAGENTA_FG\] $NODE_VER $RUBY_VER"
ps1_reset_font

__README_COLOR="$DIM_FG$MAGENTA_FG"

case "$TERM" in
xterm*|rxvt* )
	__SMILEY='☹ '
	__README_SYMBOL='☡'
    ;;
* )
	__SMILEY='('
	__README_SYMBOL='z'
    ;;
esac

function __custom_ps1() {
	local EXIT=$?

	local PREF="$1"
	local POST="$2"
	local SADNESS=
	local NOTIFY=
	local POST_RESET=
	if [[ "$EXIT" != '0' ]]
	then
		SADNESS="$__SMILEY"
	fi
	if [[ -n $(find -maxdepth 1 -iname '*README*' 2>/dev/null) ]]
	then
		NOTIFY='\['$__README_COLOR'\]'"$__README_SYMBOL$PS_RESET_FONT"
		POST_RESET="$PS_RESET_FONT"
	fi

	local GIT_POST="${NOTIFY}\n${SADNESS}${POST}${POST_RESET}"
	__git_ps1 "$PREF" "$GIT_POST"
}

PROMPT_COMMAND="__custom_ps1 '$PS1' '$__BOTTOM_BRACKET$PS_RESET_FONT\\\$ '"
