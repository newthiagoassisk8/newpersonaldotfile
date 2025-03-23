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
