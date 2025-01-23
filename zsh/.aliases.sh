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
