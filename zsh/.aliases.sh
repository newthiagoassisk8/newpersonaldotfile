alias files=nautilus
alias mylinux='lsb_release -a'
alias count_amount='echo -e "\nTotal files: $(echo `ls -l | wc -l`-1 |bc)\n"'
alias whoareu='ffplay -autoexit -nodisp /home/thiago/Música/.songs/JARVIS.mp3'
alias show_hidden_files='ls -d .?*'
alias convert_video='ffmpeg -i'
alias jarvis='ollama run llama3.2'
alias ssh_security_status='sudo fail2ban-client status sshd'
alias copyfromcat='xsel --clipboard --input'
alias showdns='cat /etc/resolv.conf'
alias genericPrompt='echo "Adapte o script para que, ... Forneça o código completo para que eu possa copiá-lo, colá-lo e testá-lo diretamente."'
alias nano='micro'
alias man='tldr'
alias find='fd'
alias vegas='flatpak run org.kde.kdenlive'
alias kdenlive='flatpak run org.kde.kdenlive'

zipRepo() {
    local dir=$1;
    zip -r -FS ./$(basename $dir)-$(date +"%Y.%m.%d.%H%M").zip $dir --exclude 'node_modules' --exclude 'storage/' --exclude 'vendor/'
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












