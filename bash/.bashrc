
# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi

unset rc

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Keep a large, deduplicated history and share it across shell sessions.
export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=50000
export HISTFILESIZE=100000
shopt -s histappend cmdhist

__bash_history_sync() {
	history -a
	history -n
}

case ";$PROMPT_COMMAND;" in
	*";__bash_history_sync;"*) ;;
	*) PROMPT_COMMAND="__bash_history_sync${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
esac

# Load bash-completion when it was not already sourced by the system profile.
if ! shopt -oq posix && ! shopt -q progcomp; then
	if [ -r /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	fi
fi

# Enable hstr on Ctrl-r when available.
if [[ $- == *i* ]] && command -v hstr >/dev/null 2>&1; then
	alias hh=hstr
	export HSTR_CONFIG=hicolor
	bind '"\C-r": "\C-a hstr -- \C-j"'
fi
# shellcheck disable=SC2034

# If not running interactively, don't do anything
case $- in
	*i*) ;;
	*) return ;;
esac

# Path to the bash it configuration
BASH_IT="/home/qwcontrol/.bash_it"

# Lock and Load a custom theme file.
# Leave empty to disable theming.
# location "$BASH_IT"/themes/
export BASH_IT_THEME='bobby'

# Some themes can show whether `sudo` has a current token or not.
# Set `$THEME_CHECK_SUDO` to `true` to check every prompt:
#THEME_CHECK_SUDO='true'

# (Advanced): Change this to the name of your remote repo if you
# cloned bash-it with a remote other than origin such as `bash-it`.
#BASH_IT_REMOTE='bash-it'

# (Advanced): Change this to the name of the main development branch if
# you renamed it or if it was changed for some reason
#BASH_IT_DEVELOPMENT_BRANCH='master'

# Your place for hosting Git repos. I use this for private repos.
#GIT_HOSTING='git@git.domain.com'

# Don't check mail when opening terminal.
unset MAILCHECK

# Change this to your console based IRC client of choice.
export IRC_CLIENT='irssi'

# Set this to the command you use for todo.txt-cli
TODO="t"

# Set this to the location of your work or project folders
#BASH_IT_PROJECT_PATHS="${HOME}/Projects:/Volumes/work/src"

# Set this to false to turn off version control status checking within the prompt for all themes
#SCM_CHECK=true

# Set to actual location of gitstatus directory if installed
#SCM_GIT_GITSTATUS_DIR="$HOME/gitstatus"
# per default gitstatus uses 2 times as many threads as CPU cores, you can change this here if you must
#export GITSTATUS_NUM_THREADS=8

# If your theme use command duration, uncomment this to
# enable display of last command duration.
#BASH_IT_COMMAND_DURATION=true
# You can choose the minimum time in seconds before
# command duration is displayed.
#COMMAND_DURATION_MIN_SECONDS=1

# Set Xterm/screen/Tmux title with shortened command and directory.
# Uncomment this to set.
#SHORT_TERM_LINE=true

# Set vcprompt executable path for scm advance info in prompt (demula theme)
# https://github.com/djl/vcprompt
#VCPROMPT_EXECUTABLE=~/.vcprompt/bin/vcprompt

# (Advanced): Uncomment this to make Bash-it reload itself automatically
# after enabling or disabling aliases, plugins, and completions.
# BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=1

# Uncomment this to make Bash-it create alias reload.
# BASH_IT_RELOAD_LEGACY=1

# Load Bash It
source "${BASH_IT?}/bash_it.sh"

# Histórico melhorado
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=10000
export HISTFILESIZE=20000
shopt -s histappend

# Busca no histórico com setas
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# HSTR configuration - add this to ~/.bashrc
alias hh=hstr                    # hh to be alias for hstr
export HSTR_CONFIG=hicolor       # get more colors
shopt -s histappend              # append new history items to .bash_history
export HISTCONTROL=ignorespace   # leading space hides commands from history
export HISTFILESIZE=10000        # increase history file size (default is 500)
export HISTSIZE=${HISTFILESIZE}  # increase history size (default is 500)
# ensure synchronization between bash memory and history file
export PROMPT_COMMAND="history -a; history -n; ${PROMPT_COMMAND}"
if [[ $- =~ .*i.* ]]; then bind '"\C-r": "\C-a hstr -- \C-j"'; fi
# if this is interactive shell, then bind 'kill last command' to Ctrl-x k
if [[ $- =~ .*i.* ]]; then bind '"\C-xk": "\C-a hstr -k \C-j"'; fi
export HSTR_TIOCSTI=y

[[ $- == *i* ]] && [[ ! ${BLE_VERSION-} ]] && source -- ~/ble.sh/out/ble.sh --attach=none
[[ ! ${BLE_VERSION-} ]] || ble-attach
