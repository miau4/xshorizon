#!/bin/bash

RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

CONFIG="/etc/xray/config.json"

function banner(){
clear
echo -e "${CYAN}"
echo "========================================"
echo "           XSHORIZON MANAGER"
echo "========================================"
echo -e "${NC}"
}

function install_config(){

if [ ! -f $CONFIG ]; then

cat > $CONFIG <<EOF
{
 "log": {
  "access": "/var/log/xray/access.log",
  "error": "/var/log/xray/error.log",
  "loglevel": "warning"
 },
 "inbounds": [
  {
   "port": 443,
   "protocol": "vless",
   "settings": {
    "clients": []
   },
   "streamSettings": {
    "network": "ws",
    "wsSettings": {
     "path": "/vless"
    }
   }
  }
 ],
 "outbounds":[
  {
   "protocol":"freedom"
  }
 ]
}
EOF

systemctl restart xray

fi
}

function criar_usuario(){

echo ""
read -p "Nome do usuário: " user
read -p "Dias de validade: " dias

uuid=$(uuidgen)

exp=$(date -d "+$dias days" +"%Y-%m-%d")

jq ".inbounds[0].settings.clients += [{\"id\": \"$uuid\",\"email\": \"$user\",\"expiry\": \"$exp\"}]" $CONFIG > /tmp/config.json

mv /tmp/config.json $CONFIG

systemctl restart xray

ip=$(curl -s ifconfig.me)

link="vless://$uuid@$ip:443?type=ws&path=%2Fvless#${user}"

echo ""
echo -e "${GREEN}USUÁRIO CRIADO${NC}"
echo ""
echo "Usuário: $user"
echo "Expira: $exp"
echo ""
echo "Link:"
echo "$link"
echo ""

read -p "ENTER para voltar"
menu
}

function listar_usuarios(){

clear

echo "USUÁRIOS VLESS"
echo "-------------------"

jq -r '.inbounds[0].settings.clients[] | .email + " | " + .expiry' $CONFIG

echo ""
read -p "ENTER para voltar"

menu
}

function remover_usuario(){

echo ""
read -p "Usuário para remover: " user

jq "(.inbounds[0].settings.clients) |= map(select(.email != \"$user\"))" $CONFIG > /tmp/config.json

mv /tmp/config.json $CONFIG

systemctl restart xray

echo "Usuário removido"

sleep 2

menu
}

function backup(){

mkdir -p /root/backup

cp $CONFIG /root/backup/config-$(date +%s).json

echo "Backup salvo em /root/backup"

sleep 2

menu
}

function monitor(){

echo "Conexões ativas:"

ss -antp | grep xray

read -p "ENTER"

menu
}

function menu(){

banner

echo "1 - Criar usuário VLESS"
echo "2 - Listar usuários"
echo "3 - Remover usuário"
echo "4 - Monitor online"
echo "5 - Backup config"
echo "6 - Reiniciar Xray"
echo "0 - Sair"

echo ""
read -p "Escolha: " op

case $op in

1) criar_usuario ;;
2) listar_usuarios ;;
3) remover_usuario ;;
4) monitor ;;
5) backup ;;
6) systemctl restart xray ; menu ;;
0) exit ;;

esac
}

install_config
menu
