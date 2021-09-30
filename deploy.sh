#!/bin/bash

OS_VERSION=`lsb_release -ds`
NETWORK_INTERFACE=`ip route get 1.1.1.1 | head -n1 | awk '{print $5}'`
IPV4_ADDRESS=`ip addr show $NETWORK_INTERFACE | grep "inet " | awk '{ print $2;exit }' | cut -d/ -f1`

NOCOLOR='\033[0m'
DARKRED='\033[0;31m'
LIGHTRED='\033[1;31m'
ORANGE='\033[0;33m'
YELLOW='\033[1;33m'
DARKGREEN='\033[0;32m'
LIGHTGREEN='\033[1;32m'
DARKCYAN='\033[0;36m'
LIGHTCYAN='\033[1;36m'
DARKBLUE='\033[0;34m'
LIGHTBLUE='\033[1;34m'
DARKPURPLE='\033[0;35m'
LIGHTPURPLE='\033[1;35m'
PURPLE='\033[0;35m'
PINK='\033[1;35m'
DARKGRAY='\033[1;30m'
LIGHTGRAY='\033[0;37m'
WHITE='\033[1;37m'

echo -e ""

echo -e "${LIGHTGRAY}################################################################################${NOCOLOR}"
echo -e "${LIGHTGRAY}Codename           :  ${LIGHTGREEN}F.E.N.I.X${NOCOLOR}"
echo -e "${LIGHTGRAY}OS Version         :  ${LIGHTGREEN}$OS_VERSION${NOCOLOR}"
echo -e "${LIGHTGRAY}IP Address (IPv4)  :  ${LIGHTGREEN}$IPV4_ADDRESS${NOCOLOR}"
echo -e "${LIGHTGRAY}################################################################################${NOCOLOR}"
echo -e ""
sleep 1

##########
# Setup project variables
##########
echo ""
echo ""
echo -e "${LIGHTPURPLE}============================================${NOCOLOR}"
echo -e "${LIGHTPURPLE}| Please enter project related variables...${NOCOLOR}"
echo -e "${LIGHTPURPLE}============================================${NOCOLOR}"
echo ""
echo -e "${LIGHTCYAN}Enter your IP Address:${NOCOLOR}"

read IP

echo ""
echo -e "${LIGHTCYAN}Enter your app name:${NOCOLOR}"

read APPNAME

echo ""
echo -e "${LIGHTCYAN}Enter your domain name (e.g. www.mydomain.com):${NOCOLOR}"

read DNAME

echo ""
echo -e "${LIGHTCYAN}Enter your desired MYSQL_DB_NAME:${NOCOLOR}"

read MYSQL_DB_NAME

echo ""
echo -e "${LIGHTCYAN}Enter your desired MYSQL_ROOT_PASSWORD:${NOCOLOR}"

randomPassword=$(openssl rand -hex 32)
read -e -i "$randomPassword" -a MYSQL_ROOT_PASSWORD

echo ""
echo -e "${LIGHTCYAN}Enter your desired email:${NOCOLOR}"

read EMAIL

echo ""
echo -e "${LIGHTRED}============================================${NOCOLOR}"
echo ""
echo "Please confirm that your project variables are valid to continue"
echo ""
echo -e "IP: ${LIGHTGREEN}$IP${NOCOLOR}"
echo -e "App Name: ${LIGHTGREEN}$APPNAME${NOCOLOR}"
echo -e "Domain Name: ${LIGHTGREEN}$DNAME${NOCOLOR}"
echo -e "MYSQL_DB_NAME: ${LIGHTGREEN}$MYSQL_DB_NAME${NOCOLOR}"
echo -e "MYSQL_ROOT_PASSWORD: ${LIGHTGREEN}$MYSQL_ROOT_PASSWORD${NOCOLOR}"
echo -e "EMAIL: ${LIGHTGREEN}$EMAIL${NOCOLOR}"
echo ""
echo -e "${LIGHTRED}============================================${NOCOLOR}"

echo ""

read -p "Apply changes (y/n)? " choice
case "$choice" in
  y|Y ) echo "Yes! Proceeding now...";;
  n|N ) echo "No! Aborting now...";;
  * ) echo "Invalid input! Aborting now...";;
esac

echo ""
echo -e "${LIGHTGREEN}This might take a while...${NOCOLOR}"
echo ""

sed -i "s/@DBNAME/$MYSQL_DB_NAME/g" ./www/.env.example
sed -i "s/@MYSQL_ROOT_PASSWORD/$MYSQL_ROOT_PASSWORD/g" ./www/.env.example
sed -i "s/@DOMAIN/$DNAME/g" ./www/.env.example
sed -i "s/@DOMAIN/$DNAME/g" docker-compose.yml
sed -i "s/@EMAIL/$EMAIL/g" docker-compose.yml
sed -i "s/@DOMAIN/$DNAME/g" ./conf/nginx/templates/default

rm -rf .env
touch .env
echo "IP=$IP" >> .env
echo "APP_NAME=$APPNAME" >> .env
echo "DOMAIN=$DNAME" >> .env
echo "DB_HOST=mysql" >> .env
echo "DB_NAME=$MYSQL_DB_NAME" >> .env
echo "DB_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" >> .env
echo "DB_TABLE_PREFIX=wp_" >> .env

#########
# Install Docker
#########
echo ""
echo ""
echo -e "${LIGHTPURPLE}============================================${NOCOLOR}"
echo -e "${LIGHTPURPLE}| Initiating Docker installation...${NOCOLOR}"
echo -e "${LIGHTPURPLE}============================================${NOCOLOR}"
echo ""

sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io

echo ""
echo -e "${LIGHTGREEN}Done ✓${NOCOLOR}"

##########
# Run Docker without sudo rights
##########
echo ""
echo ""
echo -e "${LIGHTPURPLE}============================================${NOCOLOR}"
echo -e "${LIGHTPURPLE}| Running Docker without sudo rights...${NOCOLOR}"
echo -e "${LIGHTPURPLE}============================================${NOCOLOR}"
echo ""

sudo usermod -aG docker ${USER}
su - ${USER} &

echo ""
echo -e "${LIGHTGREEN}Done ✓${NOCOLOR}"

##########
# Install Docker-Compose
##########
echo ""
echo ""
echo -e "${LIGHTPURPLE}============================================${NOCOLOR}"
echo -e "${LIGHTPURPLE}| Installing Docker Compose v1.29.2...${NOCOLOR}"
echo -e "${LIGHTPURPLE}============================================${NOCOLOR}"
echo ""

sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo ""
echo -e "${LIGHTGREEN}Done ✓${NOCOLOR}"

echo ""
echo ""
echo -e "${LIGHTPURPLE}============================================${NOCOLOR}"
echo -e "${LIGHTPURPLE}| Generate random secure salts for WP...${NOCOLOR}"
echo -e "${LIGHTPURPLE}============================================${NOCOLOR}"
echo ""

sudo apt-get install pwgen
sudo chmod +x genwpsalts.sh
./genwpsalts.sh | tee -a ./www/.env.example

echo ""
echo -e "${LIGHTGREEN}Done ✓${NOCOLOR}"

echo ""
echo ""
echo -e "${LIGHTPURPLE}============================================${NOCOLOR}"
echo -e "${LIGHTPURPLE}| Initiate composer first run...${NOCOLOR}"
echo -e "${LIGHTPURPLE}============================================${NOCOLOR}"
echo ""

sudo docker-compose up -d
sudo docker-compose down
sudo sed -i '48,57d' docker-compose.yml

echo ""
echo -e "${LIGHTGREEN}Done ✓${NOCOLOR}"

echo ""
echo ""
echo -e "${LIGHTPURPLE}============================================${NOCOLOR}"
echo -e "${LIGHTPURPLE}| Install Let's Encrypt on Nginx...${NOCOLOR}"
echo -e "${LIGHTPURPLE}============================================${NOCOLOR}"
echo ""

sudo rm -rf ./conf/nginx/templates/default.conf.conf
sudo mv ./conf/nginx/templates/default ./conf/nginx/templates/default.conf.conf

echo ""
echo -e "${LIGHTGREEN}Done ✓${NOCOLOR}"

echo ""
echo ""
echo -e "${LIGHTPURPLE}============================================${NOCOLOR}"
echo -e "${LIGHTPURPLE}| Deploying Bedrock...${NOCOLOR}"
echo -e "${LIGHTPURPLE}============================================${NOCOLOR}"
echo ""

sudo docker-compose run composer create-project
sudo docker-compose run composer update

echo ""
echo -e "${LIGHTGREEN}Done ✓${NOCOLOR}"

echo ""
echo ""
echo -e "${LIGHTPURPLE}============================================${NOCOLOR}"
echo -e "${LIGHTPURPLE}| Finalizing...${NOCOLOR}"
echo -e "${LIGHTPURPLE}============================================${NOCOLOR}"
echo ""

sudo docker-compose up -d
sudo docker container prune -f
sudo chown -R www-data:www-data ./www/web

echo ""
echo -e "${LIGHTGREEN}Setup is now complete :)${NOCOLOR}"
