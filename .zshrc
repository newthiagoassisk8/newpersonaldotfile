# Garantir que dconf-editor esteja instalado
if ! command -v dconf &> /dev/null; then
    echo "dconf-editor não encontrado. Instalando..."
    sudo apt update && sudo apt install -y dconf-editor
fi

# Verificar e configurar atalhos no Tilix
CURRENT_NEXT_SESSION=$(dconf read /com/gexperts/Tilix/keybindings/switch-to-next-session)
if [[ "$CURRENT_NEXT_SESSION" != "'<Control>Tab'" ]]; then
    echo "Configurando atalho para Próxima Aba: Ctrl+Tab"
    dconf write /com/gexperts/Tilix/keybindings/switch-to-next-session "'<Control>Tab'"
else
    echo "Atalho para Próxima Aba já configurado."
fi

CURRENT_PREV_SESSION=$(dconf read /com/gexperts/Tilix/keybindings/switch-to-previous-session)
if [[ "$CURRENT_PREV_SESSION" != "'<Control><Shift>Tab'" ]]; then
    echo "Configurando atalho para Aba Anterior: Ctrl+Shift+Tab"
    dconf write /com/gexperts/Tilix/keybindings/switch-to-previous-session "'<Control><Shift>Tab'"
else
    echo "Atalho para Aba Anterior já configurado."
fi



