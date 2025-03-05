# ========================
# Powerlevel10k Instant Prompt
# ========================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ========================
# Paths
# ========================
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export PATH="$PATH:/home/thiago/.local/bin"
export PATH="$PATH:/usr/games"
export PATH=$PATH:$HOME/Android/Sdk/emulator:$HOME/Android/Sdk/platform-tools
export PATH=$PATH:~/android-studio/android-studio/bin
export PATH="${PATH}:${HOME}/go/bin"
export ANDROID_HOME=$HOME/Android/Sdk

# ========================
# Oh My Zsh
# ========================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git history-substring-search history zsh-interactive-cd zsh-navigation-tools)
source $ZSH/oh-my-zsh.sh

# ========================
# Custom Plugins & Features
# ========================
source $ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $ZSH_CUSTOM/plugins/auto-notify/auto-notify.plugin.zsh



# ========================
# Alias & Custom Scripts
# ========================
if [ -f ~/newpersonaldotfile/zsh/.aliases.sh ]; then
  . ~/newpersonaldotfile/zsh/.aliases.sh
fi
if [ -f ~/.fa.sh ]; then
  . ~/.fa.sh
fi
if [ -f ~/.encriptFunctions ]; then
  . ~/.encriptFunctions
fi

# ========================
# Virtual Environments & Tooling
# ========================
source ~/.ia/bin/activate
. "$HOME/.asdf/asdf.sh"
fpath=(${ASDF_DIR}/completions $fpath)
autoload -Uz compinit && compinit
export FLUTTER_ROOT="$(asdf where flutter)"

# ========================
# Tilix Shortcuts
# ========================
bindkey -s '^[[1;7T' 'tilix\n'
if ! command -v dconf &> /dev/null; then
    echo "dconf-editor não encontrado. Instalando..."
    sudo apt update && sudo apt install -y dconf-editor
fi

dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/name "'Tilix'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command "'tilix'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/binding "'<Control><Alt>t'"

dconf write /com/gexperts/Tilix/keybindings/switch-to-next-session "'<Control>Tab'"
dconf write /com/gexperts/Tilix/keybindings/switch-to-previous-session "'<Control><Alt>Tab'"

# ========================
# Task Management Functions
# ========================
TODO="$HOME/MyDocs/todo/todo.txt"
UTILS="$HOME/MyDocs/utils/utilsDaily.txt"

tdl() {
    if [ $# -eq 0 ]; then
        nl -w3 -s" - " "$TODO" || echo "Nenhuma tarefa encontrada."
    else
        echo "$*" >> "$TODO"
        echo "Tarefa adicionada."
    fi
}

tdlr() {
    if [ -z "$1" ] || ! [[ "$1" =~ ^[0-9]+$ ]]; then
        echo "Erro: Índice inválido."
    else
        sed -i "${1}d" "$TODO"
        echo "Tarefa removida."
    fi
}

utils() {
    if [ $# -eq 0 ]; then
        nl -w3 -s" - " "$UTILS" || echo "Nenhum link útil encontrado."
    else
        echo "$*" >> "$UTILS"
        echo "Link útil adicionado."
    fi
}

utilsr() {
    if [ -z "$1" ] || ! [[ "$1" =~ ^[0-9]+$ ]]; then
        echo "Erro: Índice inválido."
    else
        sed -i "${1}d" "$UTILS"
        echo "Link útil removido."
    fi
}

# ========================
# CLI Tools
# ========================
prettier_cli() {
    local LOCAL_PRETTIER_CLI_DIR=${PRETTIER_CLI_DIR:-./node_modules/prettier/bin}
    local PRETTIER_EXEC=${PRETTIER_CLI_PATH:-${LOCAL_PRETTIER_CLI_DIR}/prettier.cjs}
    if [[ -f "$PRETTIER_EXEC" ]]; then
        "$PRETTIER_EXEC" "$@"
    else
        echo "Prettier CLI não encontrado em: $PRETTIER_EXEC" >&2
    fi
}

# ========================
# Welcome Message
# ========================
echo -e "\033[1;34m=============================\033[0m"
echo -e "\033[1;33m  Welcome $(whoami)\033[0m"
echo -e "\033[1;34m=============================\033[0m"
