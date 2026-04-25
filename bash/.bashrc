[ -f /etc/bashrc ] && . /etc/bashrc

if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

if [ -f ~/.aliases ]; then
  . ~/.aliases
fi

# 2. Parar aqui se não for shell interativo
[[ $- != *i* ]] && return

# 3. NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# 4. Histórico
export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=50000
export HISTFILESIZE=100000
shopt -s histappend cmdhist

# 5. Bash-it
export BASH_IT="$HOME/.bash_it"
export BASH_IT_THEME='bobby'

[ -s "${BASH_IT}/bash_it.sh" ] && source "${BASH_IT}/bash_it.sh"

# 6. HSTR
if command -v hstr >/dev/null 2>&1; then
    alias hh=hstr
    export HSTR_CONFIG=hicolor
    bind '"\C-r": "\C-a hstr -- \C-j"'
fi

# 7. BLE.sh
[[ ! ${BLE_VERSION-} && -s ~/ble.sh/out/ble.sh ]] && source -- ~/ble.sh/out/ble.sh --attach=none
[[ ${BLE_VERSION-} ]] && ble-attach

