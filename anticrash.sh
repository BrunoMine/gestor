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
interval=300 #PADRÃO: 300 segundos (5 minutos)

# Nome do processo
processo="minetest --server"

# Comando de abertura do servidor 
# Use o comando '~$ minetest --help' 
# para saber os parâmetros válidos
comando_abertura="./../../bin/minetest --server"

# Caminho de depuração (debug.txt)
debug_path="./../../bin" 

# Caminho do diretório do mundo
world_path="./../../worlds/minemacro"

# Variáveis de Email
from_email="gestorminemacro@gmail.com" # Endereço de origem que envia email
from_login="gestorminemacro@gmail.com" # Loggin do email de origem
from_senha="minemacro123" # Senha do email de origem
from_smtp="smtp.gmail.com:587" # Protocolo de SMTP do seu servidor de email
from_subject="[$(date '+%Y-%m-%d %H:%M:%S')] Servidor reiniciado! " # Titulo do email que será enviado
to_email="borgesdossantosbruno@gmail.com" # Endereço de destinatário que recebe email


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
sendemail -s "$from_smtp" -xu "$from_login" -xp "$from_senha" -f "$from_email" -t "$to_email" -u "$from_subject" -m "O servidor Minemacro crashou" -o message-charset=UTF-8 -a "$debug_path/debug ($quando).txt"

echo -e "[\033[01;32m$quando\033[00;00m] Reativando servidor de minetest ..."
#$comando_abertura &
fi
#echo "aguardando $interval segundos"
sleep $interval
done
