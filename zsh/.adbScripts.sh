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
