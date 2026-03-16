#!/bin/bash

CONFIG="/etc/xray/config.json"

function banner(){
clear
echo "=================================="
echo "        XSHORIZON MANAGER"
echo "=================================="
}

function criar_usuario(){

read -p "Usuario: " user
read -p "Dias: " dias

uuid=$(uuidgen)

exp=$(date -d "+$dias days" +"%Y-%m-%d")

jq ".inbounds[0].settings.clients += [{\"id\": \"$uuid\",\"email\": \"$user\"}]" $CONFIG > /tmp/config.json

mv /tmp/config.json $CONFIG

systemctl restart xray

ip=$(curl -s ifconfig.me)

link="vless://$uuid@$ip:443?type=ws&path=%2Fvless#$user"

echo ""
echo "LINK:"
echo "$link"

read
menu
}

function listar(){

jq -r '.inbounds[0].settings.clients[].email' $CONFIG

read
menu
}

function remover(){

read -p "Usuario: " user

jq "(.inbounds[0].settings.clients) |= map(select(.email != \"$user\"))" $CONFIG > /tmp/config.json

mv /tmp/config.json $CONFIG

systemctl restart xray

menu
}

function menu(){

banner

echo "1 Criar usuario"
echo "2 Listar usuarios"
echo "3 Remover usuario"
echo "0 Sair"

read op

case $op in

1) criar_usuario ;;
2) listar ;;
3) remover ;;
0) exit ;;

esac

}

menu
