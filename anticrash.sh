#!/bin/bash

#####################################################
################ SCRIPT ANTICRASH ###################
#####################################################
## LICENÇA: LGPL                                   ##
#####################################################
## Por ##############################################
## Lunovox <lunovox@openmailbox.org>               ##
## BrunoMine <borgesdossantosbruno@gmail.com>      ##
#####################################################

# Intervalo de verificação
interval=$1 #PADRÃO: 300 segundos (5 minutos)
quedas=$13 # Vezes que o servidor pode cair seguidamente

# Nome do processo
processo=$2 #"minetest --server"

# Comando de abertura do servidor 
# Use o comando '~$ minetest --help' 
# para saber os parâmetros válidos
comando_abertura=$3 #"./../../bin/minetest --server"

# Caminho de depuração (debug.txt)
debug_path=$4 "./../../bin" 

# Caminho do diretório do mundo
world_path=$5 "./../../worlds/minemacro"

# Variáveis de Email
from_email=$6 #"gestorminemacro@gmail.com" # Endereço de origem que envia email
from_login=$7 #"gestorminemacro@gmail.com" # Loggin do email de origem
from_senha=$8 #"minemacro123" # Senha do email de origem
from_smtp=$9 #"smtp.gmail.com:587" # Protocolo de SMTP do seu servidor de email
from_subject="[$(date '+%Y-%m-%d %H:%M:%S')] "$10 # Titulo do email que será enviado
from_text=$11 #"O servidor saiu" # Texto do corpo da mensagem de email enviada
to_email=$12 #"borgesdossantosbruno@gmail.com" # Endereço de destinatário que recebe email

echo -e "[\033[01;32m$(date '+%Y-%m-%d %H:%M:%S')\033[00;00m] Iniciando verificação de processo '$processo' a cada $interval segundos..."

# Laço de verificação infinito
while [ true == true ]; do
	if ! [ "$(pgrep -f "$processo")" ]; then # verificar processo
		quando="$(date '+%Y-%m-%d %H-%M-%S')"

		echo -e "[\033[01;32m$quando\033[00;00m] Renomenado 'debug.txt' para 'debug ($quando).txt'..."
		mv "$debug_path/debug.txt" "$debug_path/debug ($quando).txt" # Salvando arquivo de depuração

		echo -e "[\033[01;32m$quando\033[00;00m] Fazendo backup do mapa em '$world_path($quando).tar.gz'..."
		#7z a "$world_path ($quando).7z" "$world_path"
		tar -czf "$world_path($quando).tar.gz" "$world_path"

		echo -e "[\033[01;32m$quando\033[00;00m] Enviando relatório para '$to_email'..."
		sendemail -s "$from_smtp" -xu "$from_login" -xp "$from_senha" -f "$from_email" -t "$to_email" -u "$from_subject" -m "$from_text" -o message-charset=UTF-8 -a "$debug_path/debug ($quando).txt"

		echo -e "[\033[01;32m$quando\033[00;00m] Reativando servidor de minetest ..."
		#$comando_abertura &
	fi
	#echo "aguardando $interval segundos"
	sleep $interval
done
