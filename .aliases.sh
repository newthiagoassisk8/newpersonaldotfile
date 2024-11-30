alias files=nautilus
alias mylinux='lsb_release -a'
alias count_amount='echo -e "\nTotal files: $(echo `ls -l | wc -l`-1 |bc)\n"'
alias whoareu='ffplay -autoexit -nodisp /home/thiago/Música/.songs/JARVIS.mp3'
alias show_hidden_files='ls -d .?*'
alias convert_video='ffmpeg -i'
alias jarvis='ollama run llama3.2'
alias ssh_security_status='sudo fail2ban-client status sshd'
alias copyfromcat='xsel --clipboard --input'
alias sshMyphone='ssh thiago@192.168.10 -p 65522'
alias myhotspot='nmcli device wifi connect 0A:C7:DF:0A:19:2D password'
alias showdns='cat /etc/resolv.conf'

zipRepo() {
    local dir=$1;
    zip -r -FS ./$(basename $dir)-$(date +"%Y.%m.%d.%H%M").zip $dir --exclude 'node_modules' --exclude 'storage/' --exclude 'vendor/'
}


