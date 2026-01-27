copy_from_android() {
  if [ -z "$1" ]; then
    echo "Uso: copiar_do_android <caminho/no/android>"
    return 1
  fi

  local ORIGEM="$1"
  local DESTINO="$HOME/fromMobile"

  mkdir -p "$DESTINO"

  local IS_DIR
  IS_DIR=$(adb shell "[ -d '$ORIGEM' ] && echo 'dir'")

  local NOME_BASE
  NOME_BASE=$(basename "$ORIGEM")

  local DESTINO_COMPLETO="$DESTINO/$NOME_BASE"

  echo "Copiando '$ORIGEM' para '$DESTINO_COMPLETO'..."

  adb pull "$ORIGEM" "$DESTINO"

  if [ $? -eq 0 ]; then
    echo "✅ Cópia concluída com sucesso."
  else
    echo "❌ Erro ao copiar arquivo/pasta."
    return 2
  fi
}

screenshot_from_mobile() {
  local DESTINO="$HOME/fromMobile/screenshots"
  local TIMESTAMP
  TIMESTAMP=$(date +%Y%m%d-%H%M%S)
  local FILENAME="screenshot_$TIMESTAMP.png"

  # Cria o diretório se não existir
  mkdir -p "$DESTINO"

  # Tira o print no dispositivo
  adb shell screencap -p /sdcard/screenshot.png

  # Copia para o computador
  adb pull /sdcard/screenshot.png "$DESTINO/$FILENAME"

  # Remove do dispositivo
  adb shell rm /sdcard/screenshot.png

  echo "✅ Screenshot salvo em: $DESTINO/$FILENAME"
}


install_apk() {
  local APK_PATH="$1"

  if [ -z "$APK_PATH" ]; then
    echo "❌ Caminho do APK não fornecido."
    echo "ℹ️  Uso: install_apk /caminho/para/aplicativo.apk"
    return 1
  fi

  if [ ! -f "$APK_PATH" ]; then
    echo "❌ Arquivo não encontrado: $APK_PATH"
    return 1
  fi

  if ! adb get-state 1>/dev/null 2>&1; then
    echo "❌ Nenhum dispositivo conectado via ADB."
    return 1
  fi

  echo "📦 Instalando APK: $APK_PATH"
  adb install -r "$APK_PATH"

  if [ $? -eq 0 ]; then
    echo "✅ APK instalado com sucesso!"
  else
    echo "❌ Falha na instalação do APK."
  fi
}

silentShot_to_android() {
  local ANDROID_DIR="${1:-/sdcard/DCIM/Screenshots}"

  local TS FILE_LOCAL FILE_REMOTE
  TS="$(date +'%Y%m%d_%H%M%S')"
  FILE_LOCAL="/tmp/Screenshot_${TS}_linux.png"
  FILE_REMOTE="${ANDROID_DIR}/Screenshot_${TS}_linux.png"

  # --- Estado original (para restaurar) ---
  local EVENT_SOUNDS_OLD="" ANIM_OLD=""
  local RESTORE_CMDS=()

  # Silenciar "event sounds" (tira som do screenshot)
  if gsettings list-schemas | grep -qx "org.gnome.desktop.sound" \
     && gsettings list-keys org.gnome.desktop.sound 2>/dev/null | grep -qx "event-sounds"; then
    EVENT_SOUNDS_OLD="$(gsettings get org.gnome.desktop.sound event-sounds)"
    RESTORE_CMDS+=("gsettings set org.gnome.desktop.sound event-sounds $EVENT_SOUNDS_OLD")
    gsettings set org.gnome.desktop.sound event-sounds false
  fi

  # Desativar animações (remove o “flash”/efeito visual)
  if gsettings list-schemas | grep -qx "org.gnome.desktop.interface" \
     && gsettings list-keys org.gnome.desktop.interface 2>/dev/null | grep -qx "enable-animations"; then
    ANIM_OLD="$(gsettings get org.gnome.desktop.interface enable-animations)"
    RESTORE_CMDS+=("gsettings set org.gnome.desktop.interface enable-animations $ANIM_OLD")
    gsettings set org.gnome.desktop.interface enable-animations false
  fi

  # Restaura tudo mesmo em erro/Ctrl+C
  _restore() {
    local i
    for ((i=${#RESTORE_CMDS[@]}-1; i>=0; i--)); do
      eval "${RESTORE_CMDS[$i]}" >/dev/null 2>&1 || true
    done
  }
  trap _restore EXIT INT TERM

  # --- Screenshot ---
  if ! command -v gnome-screenshot >/dev/null 2>&1; then
    echo "❌ gnome-screenshot não encontrado (instale gnome-screenshot)"
    return 1
  fi

  gnome-screenshot -f "$FILE_LOCAL" || {
    echo "❌ Falha ao capturar screenshot"
    return 2
  }

  # --- Envio via ADB (MIUI) ---
  adb get-state >/dev/null 2>&1 || {
    echo "❌ Nenhum dispositivo ADB conectado (adb devices)"
    return 3
  }

  adb shell "mkdir -p '$ANDROID_DIR'" >/dev/null 2>&1
  adb push "$FILE_LOCAL" "$FILE_REMOTE" || {
    echo "❌ Falha no adb push"
    return 4
  }

  adb shell "am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d 'file://$FILE_REMOTE'" \
    >/dev/null 2>&1 || true

  echo "✅ Screenshot enviado (silencioso e sem flash):"
  echo "   $FILE_REMOTE"
}
