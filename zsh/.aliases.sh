alias files=nautilus
alias mylinux='lsb_release -a'
alias count_amount='echo -e "\nTotal files: $(echo `ls -l | wc -l`-1 |bc)\n"'
alias show_hidden_files='ls -d .?*'
alias convert_video='ffmpeg -i'
alias jarvis='ollama run llama3.2'
alias ssh_security_status='sudo fail2ban-client status sshd'
alias copyfromcat='xsel --clipboard --input'
alias showdns='cat /etc/resolv.conf'
alias genericPrompt='echo "Adapte o script para que, ... Forneça o código completo para que eu possa copiá-lo, colá-lo e testá-lo diretamente."'
# alias man='tldr'
# alias find='fd'
alias vegas='flatpak run org.kde.kdenlive'
alias kdenlive='flatpak run org.kde.kdenlive'
alias remoteLink='ssh -L 5901:localhost:5901 -p 5632 -N -f vncuser@192.168.0.27'
alias pacman='sudo apt update && sudo apt upgrade -y && flatpak update'
alias bt-battery='python3 ~/bt-battery-indicator/main.py'
alias obs_r='obs --startrecording --minimize-to-tray --profile "Padrão" --scene "Screen+Mic"'
alias gsconnect-cli="/home/$USER/.local/share/gnome-shell/extensions/gsconnect@andyholmes.github.io/service/daemon.js"
alias lah="ls -lah"



zipRepo() {
    local dir=$1;
    zip -r -FS ./$(basename $dir)-$(date +"%Y.%m.%d.%H%M").zip $dir --exclude 'node_modules' --exclude 'storage/' --exclude 'vendor/'
}




check_airpods_battery() {
  local AIRPOD_ICON="🎧"

  # Encontra o MAC address do primeiro dispositivo Bluetooth conectado com "AirPods" no nome
  local MAC_ADDR=$(bluetoothctl devices | grep -i "AirPods" | awk '{print $2}')

  if [[ -z "$MAC_ADDR" ]]; then
    echo "$AIRPOD_ICON Nenhum dispositivo AirPods foi encontrado."
    return 1
  fi

  local INFO=$(bluetoothctl info "$MAC_ADDR")

  if echo "$INFO" | grep -q "Connected: yes"; then
    local BATTERY=$(echo "$INFO" | grep "Battery Percentage" | awk -F': ' '{print $2}')
    if [[ -n "$BATTERY" ]]; then
      echo "$AIRPOD_ICON Bateria dos AirPods: $BATTERY"
    else
      echo "$AIRPOD_ICON Conectado, mas nível da bateria indisponível"
    fi
  else
    echo "$AIRPOD_ICON AirPods encontrados, mas não estão conectados"
  fi
}

add_host_entry() {
    local ip="$1"
    local hostname="$2"

    if [[ -z "$ip" || -z "$hostname" ]]; then
        echo "Usage: add_host_entry <IP> <hostname>"
        return 1
    fi

    # Backup do arquivo /etc/hosts
    sudo cp /etc/hosts "/etc/hosts.bkp.$(date +%Y%m%d_%H%M%S)"

    # Adiciona a entrada no /etc/hosts
    echo -e "\n# $(date +'%Y-%m-%d %H:%M:%S')\n$ip $hostname" | sudo tee -a /etc/hosts

    echo "Entry added: $ip $hostname"
}

kill_service() {
  local service_name="$1"
  if [ -z "$service_name" ]; then
    echo "Por favor, forneça o nome do serviço como parâmetro."
    return 1
  fi

  for pid in $(ps aux | grep "$service_name" | grep -v grep | awk '{print $2}'); do
    kill -9 "$pid" && echo "Processo $pid de $service_name encerrado com sucesso."
  done
}


start_project() {
    # Verifica se dois parâmetros foram fornecidos
    if [ "$#" -ne 2 ]; then
        echo "Uso: abrir_repositorios <diretório_repositorio_1> <diretório_repositorio_2>"
        return 1
    fi

    # Diretórios dos repositórios fornecidos como parâmetros
    local REPO1=$1
    local REPO2=$2

    # Cria uma nova janela do Tilix
   # tilix --action=app-new-window &

    # Espera a janela ser criada
    sleep 1

    # Adiciona a primeira sessão e executa o comando 'npm start'
    tilix --action=app-new-session -e "bash -c 'cd $REPO1 && yarn start; exec bash'" &

    # Adiciona a segunda sessão e executa o comando 'watch.sh'
    tilix --action=session-add-right -e "bash -c 'cd $REPO2 && ./watch.sh; exec bash'" &

    # Adiciona a terceira sessão vazia
    tilix --action=session-add-down -e "bash" &

    # Aguarda o processo Tilix terminar
    wait
}


start_tilix_multi_servers() {
    # Verifica se pelo menos dois argumentos foram fornecidos
    if [ "$#" -lt 2 ] || [ "$#" -gt 4 ]; then
        echo "Uso: start_project <diretorio_1>:<comando_1> [<diretorio_2>:<comando_2> ... até 4]"
        return 1
    fi

    # Cria uma nova janela do Tilix (primeira sessão)
    tilix --action=app-new-window &
    sleep 2

    # Captura o PID da janela do Tilix
    tilix_pid=$(pgrep -o tilix)
    if [ -z "$tilix_pid" ]; then
        echo "Erro ao abrir o Tilix. Não foi possível encontrar o processo."
        return 1
    fi

    # Contador de sessões
    local session_counter=1

    # Itera sobre os argumentos fornecidos
    for param in "$@"; do
        # Divide o parâmetro no formato "diretorio:comando"
        IFS=':' read -r REPO CMD <<< "$param"

        # Verifica se o diretório e o comando foram especificados
        if [ -z "$REPO" ] || [ -z "$CMD" ]; then
            echo "Erro: parâmetro inválido '$param'. Use o formato <diretorio>:<comando>."
            continue
        fi

        # Atrasar a criação da sessão para garantir que a janela principal esteja pronta
        sleep 1

        # Adiciona a primeira sessão
        if [ $session_counter -eq 1 ]; then
            # Primeira sessão na janela
            tilix --action=app-new-session -e "bash -c 'cd $REPO && $CMD; exec bash'" &
        elif [ $session_counter -eq 2 ]; then
            # Segunda sessão à direita da primeira
            tilix --action=session-add-right -e "bash -c 'cd $REPO && $CMD; exec bash'" &
        elif [ $session_counter -eq 3 ]; then
            # Terceira sessão abaixo da primeira
            tilix --action=session-add-down -e "bash -c 'cd $REPO && $CMD; exec bash'" &
        elif [ $session_counter -eq 4 ]; then
            # Quarta sessão abaixo da segunda
            tilix --action=session-add-down -e "bash -c 'cd $REPO && $CMD; exec bash'" &
        fi

        # Incrementa o contador de sessões
        session_counter=$((session_counter + 1))
    done

    # Aguarda o processo Tilix terminar
    wait
}



start_tmux_multi_sessions() {
    # Verifica se pelo menos dois argumentos foram fornecidos
    if [ "$#" -lt 2 ] || [ "$#" -gt 4 ]; then
        echo "Uso: start_project <diretorio_1>:<comando_1> [<diretorio_2>:<comando_2> ... até 4]"
        return 1
    fi

    # Cria uma nova sessão tmux
    tmux new-session -d -s multi_sessions

    # Contador de painéis
    local panel_counter=1

    # Itera sobre os argumentos fornecidos
    for param in "$@"; do
        # Divide o parâmetro no formato "diretorio:comando"
        IFS=':' read -r REPO CMD <<< "$param"

        # Verifica se o diretório e o comando foram especificados
        if [ -z "$REPO" ] || [ -z "$CMD" ]; then
            echo "Erro: parâmetro inválido '$param'. Use o formato <diretorio>:<comando>."
            continue
        fi

        # Atrasar a criação do painel para garantir que a janela principal esteja pronta
        sleep 1

        # Adiciona os painéis de acordo com a ordem solicitada
        if [ $panel_counter -eq 1 ]; then
            # Primeira sessão no painel principal
            tmux send-keys "cd $REPO && $CMD" C-m
        elif [ $panel_counter -eq 2 ]; then
            # Segunda sessão à direita da primeira
            tmux split-window -h
            tmux send-keys "cd $REPO && $CMD" C-m
        elif [ $panel_counter -eq 3 ]; then
            # Terceira sessão abaixo da primeira
            tmux split-window -v
            tmux send-keys "cd $REPO && $CMD" C-m
        elif [ $panel_counter -eq 4 ]; then
            # Quarta sessão abaixo da primeira, à esquerda da segunda
            tmux split-window -v
            tmux send-keys "cd $REPO && $CMD" C-m
        fi

        # Incrementa o contador de painéis
        panel_counter=$((panel_counter + 1))
    done

    # Anexa à sessão tmux
    tmux attach -t multi_sessions
}


ffmpeg_convert_webm_to_mp4() {
    if [ -z "$1" ]; then
        echo "Uso: ffmpeg_convert <arquivo.webm>"
        return 1
    fi

    input_file="$1"
    output_file="${input_file%.webm}.mp4"

    ffmpeg -i "$input_file" -c:v copy -c:a copy "$output_file"

    echo "Conversão concluída: $output_file"
}

convert_video_to_gif() {
    # Verifica se o ffmpeg está instalado
    if ! command -v ffmpeg &> /dev/null; then
        echo "Erro: ffmpeg não está instalado. Instale com 'sudo apt install ffmpeg'"
        return 1
    fi

    # Verifica se o vídeo foi fornecido como argumento
    if [ -z "$1" ]; then
        echo "Uso: convert_video_to_gif caminho/do/video"
        return 1
    fi

    INPUT="$1"
    BASENAME=$(basename "$INPUT")
    FILENAME="${BASENAME%.*}"
    OUTPUT="${FILENAME}.gif"

    # Parâmetros ajustáveis
    FPS=10
    WIDTH=480

    # Executa a conversão
    ffmpeg -i "$INPUT" -vf "fps=$FPS,scale=$WIDTH:-1:flags=lanczos" -c:v gif "$OUTPUT"

    # Verifica se o comando foi bem-sucedido
    if [ $? -eq 0 ]; then
        echo "GIF gerado com sucesso: $OUTPUT"
    else
        echo "Erro ao converter vídeo para GIF"
        return 1
    fi
}

ghpr() {
  local BASE="main"
  local BODY="Criado via CLI"
  local REPO=""
  local HEAD_BRANCH
  local TITLE
  local USER

  # Processamento de argumentos
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --base)
        BASE="$2"
        shift 2
        ;;
      --body)
        BODY="$2"
        shift 2
        ;;
      --repo)
        REPO="$2"
        shift 2
        ;;
      *)
        shift
        ;;
    esac
  done

  # Branch atual
  HEAD_BRANCH=$(git rev-parse --abbrev-ref HEAD)

  # Título default = nome da branch legível
  TITLE="${HEAD_BRANCH//-/ }"

  # Usuário para compor o --head
  USER=$(git config --get user.name)

  # Detecta o repositório atual caso não tenha passado --repo
  if [[ -z "$REPO" ]]; then
    REMOTE_URL=$(git remote get-url origin)
    REPO=$(echo "$REMOTE_URL" | sed -E 's#(git@|https://)([^/:]+)[/:]([^/]+)/([^/]+)(\.git)?#\3/\4#')
    REPO=$(echo "$REPO" | sed 's/\.git$//')
  fi

  echo "Criando PR:"
  echo "  Base: $BASE"
  echo "  Head: $USER:$HEAD_BRANCH"
  echo "  Repo: $REPO"
  echo "  Title: $TITLE"
  echo "  Body: $BODY"

  gh pr create \
    --base "$BASE" \
    --head "$USER:$HEAD_BRANCH" \
    --title "$TITLE" \
    --body "$BODY" \
    --repo "$REPO" \
    --draft
}

git_checkout_fzf() {
  local branch
  branch=$(git branch --format='%(refname:short)' | fzf --prompt="Escolha a branch: ")

  if [ -n "$branch" ]; then
    git checkout "$branch"
  else
    echo "Nenhuma branch selecionada."
  fi
}

glpr() {
  local BASE="main"
  local BODY="Criado via CLI"
  local REPO=""
  local HEAD_BRANCH
  local TITLE

  # Processamento de argumentos
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --base)
        BASE="$2"
        shift 2
        ;;
      --body)
        BODY="$2"
        shift 2
        ;;
      --repo)
        REPO="$2"
        shift 2
        ;;
      *)
        shift
        ;;
    esac
  done

  # Branch atual
  HEAD_BRANCH=$(git rev-parse --abbrev-ref HEAD)

  # Título default = nome da branch legível
  TITLE="${HEAD_BRANCH//-/ }"

  # Detecta o repositório atual caso não tenha passado --repo
  if [[ -z "$REPO" ]]; then
    REMOTE_URL=$(git remote get-url origin)
    REPO=$(echo "$REMOTE_URL" | sed -E 's#(git@|https://)([^/:]+)[/:]([^/]+)/([^/]+)(\.git)?#\3/\4#')
    REPO=$(echo "$REPO" | sed 's/\.git$//')
  fi

  echo "Criando Merge Request:"
  echo "  Base (target): $BASE"
  echo "  Head (source): $HEAD_BRANCH"
  echo "  Repo: $REPO"
  echo "  Title: $TITLE"
  echo "  Body: $BODY"

  glab mr create \
    --source-branch "$HEAD_BRANCH" \
    --target-branch "$BASE" \
    --title "$TITLE" \
    --description "$BODY" \
    --repo "$REPO" \
    --draft
}

alias tmp='cd /tmp'
alias oldpwd='cd $OLDPWD'

ip_servidor_rede () {
	nc 192.168.0.27 5632 -z -w 3
	if [ $? -eq 0 ]
		then
			echo '192.168.0.27'
		else
		    echo '100.99.181.118'
		fi
}


git_explore_commit() {
    local commit="$1"
    local subpath="${2:-.}"

    if [[ -z "$commit" ]]; then
        echo "Uso: git_view <COMMIT> [PASTA]"
        return 1
    fi

    local repo_name short_hash target
    repo_name="$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")" || {
        echo "Erro: não está dentro de um repositório Git."
        return 1
    }

    short_hash="$(git rev-parse --short "$commit")"
    target="/tmp/${repo_name}-view-${short_hash}"

    if [[ ! -d "$target" ]]; then
        echo "[git-view] Criando worktree: $target"
        git worktree add --detach "$target" "$commit" >/dev/null 2>&1 || {
            echo "Erro ao criar worktree para o commit '$commit'"
            return 1
        }
    else
        echo "[git-view] Worktree já existente: $target"
    fi

    cd "$target" || {
        echo "Erro: não foi possível acessar $target"
        return 1
    }

    if [[ -d "$subpath" || -f "$subpath" ]]; then
        echo "[git-view] Abrindo no Neovim: $subpath"
        nvim "$subpath"
    else
        echo "[git-view] Caminho '$subpath' não encontrado no commit. Abrindo raiz."
        nvim .
    fi

    echo
    echo "[git-view] Para remover depois: git worktree remove $target"
}

gerar_totp() {
    local secret="$1"

    if [[ -z "$secret" ]]; then
        echo "Uso: gerar_totp <SECRET>"
        return 1
    fi

    oathtool --base32 --totp "$secret" -d 6
}

git_remote_open () {

    local commit=""
    local url

    # Parse das flags
    while getopts ":c:" opt; do
        case "$opt" in
            c)
                commit="$OPTARG"
                ;;
            \?)
                echo "Flag inválida: -$OPTARG"
                return 1
                ;;
            :)
                echo "A flag -$OPTARG requer um argumento."
                return 1
                ;;
        esac
    done

    url=$(git remote get-url origin 2>/dev/null)
    if [ -z "$url" ]; then
        echo "Nenhum remote 'origin' encontrado neste repositório."
        return 1
    fi

    # Converte SSH para HTTPS
    if [[ "$url" =~ ^git@ ]]; then
        url=$(echo "$url" | sed -E 's#git@(.*):(.*)#https://\1/\2#')
    fi

    # Remove .git do final
    url=${url%.git}

    # Se commit foi informado, monta URL do commit
    if [ -n "$commit" ]; then
        url="$url/commit/$commit"
    fi

    echo "Abrindo: $url"
    xdg-open "$url" > /dev/null 2>&1 &
}

alias nano-bin='/usr/bin/nano'
alias snano-bin='sudo /usr/bin/nano'
# alias nano='nano-bin -T 4 -l -e -A --positionlog --tabstospaces --trimblanks'
alias snano='snano-bin -T 4 -l -e -A --positionlog --tabstospaces --trimblanks'


studyTime() {
    DIR="/home/$USER/Songs"
    ARQUIVO="studyBG.mp3"

    cd "$DIR" || { echo "Erro: não foi possível acessar $DIR"; return 1; }
    mpg123 -q --loop -1 "$ARQUIVO"
}

