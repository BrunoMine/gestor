#!/bin/bash

#####################################################
############## SCRIPT ANTICRASH v1.0 ################
#####################################################
## LICENÇA: LGPL                                   ##
#####################################################
## Por ##############################################
## Lunovox <lunovox@openmailbox.org>               ##
## BrunoMine <borgesdossantosbruno@gmail.com>      ##
#####################################################

# Aviso de autenticidade dos dados
echo -e "[\033[01;32m$(date '+%Y-%m-%d %H:%M:%S')\033[00;00m] Para evitar erros nesse anticrash, abra e feche o servidor (no mundo desejado) normalmente uma vez para atualizar dados (para o caso de troca de diretorios e/ou nomes)"

# Caminho para dados do mod
dados_path="./../mods/gestor/dados"

# Intervalo de verificação (em segundos)
interval=$(cat "$dados_path"/interval) 

# Vezes que o servidor pode cair seguidamente
lim_quedas=$(cat "$dados_path"/quedas) 

# Nome do processo
processo="minetest --server" #"minetest --server"

# Comando de abertura do servidor 
bin_args=$(cat "$dados_path"/bin_args)

# Caminho do binario
bin=$(cat "$dados_path"/bin_path)

# Caminho de depuração (debug.txt)
debug_path=$(cat "$dados_path"/debug_path)

# Caminho do diretório do mundo
world_path=$(cat "$dados_path"/world_path)

# Variáveis de Email
from_email=$(cat "$dados_path"/from_email) # Endereço de origem que envia email
from_login=$(cat "$dados_path"/from_login) # Loggin do email de origem
from_senha=$(cat "$dados_path"/from_senha) # Senha do email de origem
from_smtp=$(cat "$dados_path"/from_smtp) # Protocolo de SMTP do seu servidor de email
from_subject=$(cat "$dados_path"/from_subject) # Titulo do email que será enviado
from_text=$(cat "$dados_path"/from_text) # Texto do corpo da mensagem de email enviada
to_email=$(cat "$dados_path"/to_email) # Endereço de destinatário que recebe email
# Mensagens de alerta emergencial
from_subject_em=$(cat "$dados_path"/from_subject_em)
from_text_em=$(cat "$dados_path"/from_text_em)

# Status de Sistemas
status_email=$(cat "$dados_path"/status_email) # Se o sistema de email deve funcionar
status_backup=$(cat "$dados_path"/status_backup) # Se o sistema de email deve funcionar

# Verifica se ja esta aberto
if [ $(cat "$dados_path"/status) == on ]; then
	echo "Falha. Servidor ja foi aberto (feche o servidor e tente novamente, ou abra e feche o servidor e tente novamente)..."
	exit
fi

echo "  ___  _     _____v1.0   ___  ___   ___   ___        "
echo " |   | |\  |   |    |   |    |   | |   | |     |   | "
echo " |___| | \ |   |    |   |    |___/ |___| \___  |___| "
echo " |   | |  \|   |    |   |___ |   \ |   |  ___| |   | "

echo "on" > "$dados_path"/status_anticrash # Anticrash ativado

# Abre o servidor normalmente
echo -e "[\033[01;32m$(date '+%Y-%m-%d %H:%M:%S')\033[00;00m] Abrindo servidor..."
cd "$bin"
echo $bin_args
nohup $bin_args > /dev/null &

echo -e "[\033[01;32m$(date '+%Y-%m-%d %H:%M:%S')\033[00;00m] Iniciando verificação de processo '$processo' a cada $interval segundos..."

quedas=0 # contador de quedas

# Laço de verificação infinito
while [ true == true ]; do
	if ! [ "$(pgrep -f "$processo")" ]; then # verificar processo
	
		quando="$(date '+%Y-%m-%d %H-%M-%S')"
		
		# Verificar se o servidor desligou corretamente
		if [ $(cat "$dados_path"/status) == off ]; then
			echo -e "[\033[01;32m$(date '+%Y-%m-%d %H:%M:%S')\033[00;00m] Servidor foi desligado normalmente..."
			echo "Desligando anticrash..."
			break
		fi
		
		echo -e "[\033[01;32m$quando\033[00;00m] Servidor parou abruptamente (ou de modo inconveniente)..."
		
		# Soma ao contador de quedas
		let quedas++
		
		echo "Renomenado 'debug.txt' para 'debug ($quando).txt'..."
		mv "$debug_path/debug.txt" "$debug_path/debug ($quando).txt" # Salvando arquivo de depuração

		
		if [ $status_backup == "true" ]; then
			echo "Fazendo backup do mapa em '$world_path($quando).tar.gz'..."
			#7z a "$world_path ($quando).7z" "$world_path"
			tar -czf "$world_path($quando).tar.gz" "$world_path"
		fi
		
		if [ $quedas -ge $lim_quedas ]; then
			echo "ALERTA. atingiu o limite de quedas sucessivas."
			if [ $status_email == "true" ]; then
				echo "Enviando relatório para '$to_email'..."
				sendemail -s "$from_smtp" -xu "$from_login" -xp "$from_senha" -f "$from_email" -t "$to_email" -u "$from_subject_em" -m "$from_text_em" -o message-charset=UTF-8 -a "$debug_path/debug ($quando).txt"
			fi
			echo "Desligando anticrash..."
			echo "off" > $dados_path/status # servidor desligado
			break
		else
			if [ $status_email == "true" ]; then
				echo "Enviando relatório para '$to_email'..."
				sendemail -s "$from_smtp" -xu "$from_login" -xp "$from_senha" -f "$from_email" -t "$to_email" -u "$from_subject" -m "$from_text" -o message-charset=UTF-8 -a "$debug_path/debug ($quando).txt"
			fi
		fi
		
		
		echo "Reativando servidor de minetest ..."
		nohup $bin_args > /dev/null &
	
	else
		quedas=0 # zerar o contador de quedas apos 1 intervalo/loop sem queda
	fi
	
	sleep $interval
done


