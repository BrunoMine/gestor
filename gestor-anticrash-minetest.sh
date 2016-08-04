#!/bin/bash

#####################################################
## SCRIPT ANTICRASH v1.1 Copyright (C) 2016        ##
## LICENÇA: LGPL v3.0                              ##
## Por                                             ##
## Lunovox <lunovox@openmailbox.org>               ##
## BrunoMine <borgesdossantosbruno@gmail.com>      ##
#####################################################
## Recebeste uma cópia da GNU Lesser General       ##
## Public License junto com esse software.         ##
## Se não, veja em <http://www.gnu.org/licenses/>. ##
#####################################################

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

# AVISO de autenticidade dos dados
echo -e "\033[01;34m###_AVISO_#################################################\033[00;00m"
echo "Para evitar erros nesse anticrash, abra e feche o servidor (no mundo desejado) normalmente uma vez para atualizar dados (para o caso de troca de diretorios e/ou nomes)"

# AVISO servidor so pode ser fechado pelo gestor
echo -e "\033[01;34m###_AVISO_#################################################\033[00;00m"
echo "Uma vez iniciado o anticrash o servidor pode ser fechado apenas pelo botao de desligamento no painel administrativo do gestor"
echo "on" > $dados_path/status # anticrash trabalha

echo -e "\033[01;35m###########################################################\033[00;00m"
echo -e "\033[01;35m##   ___  _     _____       ___  ___   ___   ___   v1.1  ##\033[00;00m"
echo -e "\033[01;35m##  |   | |\  |   |    |   |    |   \ |   | |     |   |  ##\033[00;00m"
echo -e "\033[01;35m##  |___| | \ |   |    |   |    |___/ |___| \___  |___|  ##\033[00;00m"
echo -e "\033[01;35m##  |   | |  \|   |    |   |___ |   \ |   |  ___| |   |  ##\033[00;00m"
echo -e "\033[01;35m###########################################################\033[00;00m"
echo -e "\033[01;35m## Gestor  Copyright (C)  2016.                          ##\033[00;00m"
echo -e "\033[01;35m## Esse programa não tem ABSOLUTAMENTE NENHUMA GARANTIA. ##\033[00;00m"
echo -e "\033[01;35m###########################################################\033[00;00m"

# INFO Abre o servidor normalmente
echo -e "\033[01;32m###_INFO_##################################################\033[00;00m"
echo "Abrindo servidor..."
nohup $bin_args >> debug.out &


# INFO Inicia loopde verificação
echo -e "\033[01;32m###_INFO_##################################################\033[00;00m"
echo -e "[\033[01;32m$(date '+%Y-%m-%d %H:%M:%S')\033[00;00m] Iniciando verificação de processo '$processo' a cada $interval segundos..."

quedas=0 # contador de quedas

# Laço de verificação infinito
while [ true == true ]; do
	if ! [ "$(pgrep -f "$processo")" ]; then # verificar processo
	
		quando="$(date '+%Y-%m-%d %H-%M-%S')"
		
		# Verificar se o servidor desligou corretamente
		if [ $(cat "$dados_path"/status) == off ]; then
			echo -e "[\033[01;32m$quando\033[00;00m] Servidor foi desligado normalmente..."
			echo "Desligando anticrash..."
			break
		fi
		
		# Servidor parou abruptamente
		echo -e "\033[01;32m###_INFO_##################################################\033[00;00m"
		echo -e "[\033[01;32m$quando\033[00;00m] Servidor parou abruptamente (ou de modo inconveniente)..."
		
		# Soma ao contador de quedas
		let quedas++
		
		# Renomeia arquivo de depuração
		echo "Renomenado 'debug.txt' para 'debug ($quando).txt'..."
		mv "debug.txt" "debug ($quando).txt"

		# Faz backup do mundo
		if [ $status_backup == "true" ]; then
			echo "Fazendo backup do mapa em '$world_path($quando).tar.gz'..."
			tar -czf "$world_path($quando).tar.gz" "$world_path"
		fi
		
		if [ $quedas -ge $lim_quedas ]; then
			# AVISO Atingiu limite de quedas sucessivas
			echo -e "\033[01;34m###_AVISO_#################################################\033[00;00m"
			echo "Atingiu o limite de quedas sucessivas."
			if [ $status_email == "true" ]; then
				# Enviando relatorio para email
				echo "Enviando relatório para '$to_email'..."
				sendemail -s "$from_smtp" -xu "$from_login" -xp "$from_senha" -f "$from_email" -t "$to_email" -u "$from_subject_em" -m "$from_text_em" -o message-charset=UTF-8 -a "debug ($quando).txt"
			fi
			# Desligando anticrash
			echo "Desligando anticrash..."
			echo "off" > $dados_path/status # anticrash parou
			break
		else
			if [ $status_email == "true" ]; then
				# Enviando relatorio para email
				echo "Enviando relatório para '$to_email'..."
				sendemail -s "$from_smtp" -xu "$from_login" -xp "$from_senha" -f "$from_email" -t "$to_email" -u "$from_subject" -m "$from_text" -o message-charset=UTF-8 -a "debug ($quando).txt"
			fi
		fi
		
		# Reativando servidor
		echo "Reativando servidor de minetest ..."
		nohup $bin_args >> debug.out &
	
	else
		quedas=0 # zerar o contador de quedas apos 1 intervalo/loop sem queda
	fi
	
	sleep $interval
done

