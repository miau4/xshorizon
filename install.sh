#!/bin/bash

clear

echo "================================"
echo "   INSTALADOR XSHORIZON"
echo "================================"

sleep 2

apt update -y
apt install curl wget jq unzip uuid-runtime -y

mkdir -p /etc/xray
mkdir -p /etc/xshorizon

echo "Instalando Xray..."

bash -c "$(curl -L https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh)" @ install

echo "Baixando painel..."

wget -O /usr/local/bin/xshorizon https://raw.githubusercontent.com/miau4/xshorizon/main/xshorizon.sh

chmod +x /usr/local/bin/xshorizon

echo ""
echo "Instalação concluída"
echo ""

sleep 2

xshorizon
