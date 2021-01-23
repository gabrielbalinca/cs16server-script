#!/bin/bash

# Read server name
read -p "Server Name : " input_server_name 

# Lowercase the input
server_name=${input_server_name,,}

# Check if the folder already exist
find . -type d | grep $server_name 

until [ $? -ne 0 ]
do
	echo "This name already is in use ! Please choose another name"
	read -p "Server Name : " input_server_name 
	server_name=${input_server_name,,}
done

# Read the port number
read -p "Port Number : " port

# Support for 32-bit architecture
dpkg --add-architecture i386

# Updating package list
apt-get update -y

# Install required packages
apt-get install -y libsdl2-2.0-0 libsdl2-2.0-0:i386 lib32gcc1 tmux screen curl

# Downloading steamcmd
mkdir /home/resources/steamcmd &&\
cd /home/resources/steamcmd &&\
curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
if [ $? -ne 0 ]; then
	cd /
	echo "ERROR : Cannot download steamcmd !"
else
	cd /
fi

# Installing the server
until /home/resources/steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/$server_name +app_update 90 -beta beta validate +quit; do sleep 1; done

# Fixing steamclient.so issue
rm -rf /root/.steam/sdk32
mkdir /root/.steam/sdk32
cp /home/$server_name/steamclient.so /root/.steam/sdk32

# Non-steam patch
cp -r /home/resources/nonsteam-patch/* /home/$server_name

# Installing base mods (cstrike fix, regamedll, metamod, amxmodx, reunion, rechecker, reauthchecker, reaimdetector)
cp -r /home/resources/cstrike/* /home/$server_name/cstrike

# Change server name
sed -i 's,hostname "Counter-Strike 1.6 Server",hostname "'"$input_server_name"'",g' /home/$server_name/cstrike/server.cfg

# Aditional cfgs
mkdir /home/$server_name/cstrike/banned.cfg
mkdir /home/$server_name/cstrike/listip.cfg

# Script for starting the server
cd /home/$server_name
touch start.sh
echo -n "screen -A -m -d -S $server_name ./hlds_run -game cstrike +maxplayers 25 +map de_dust2 -port " >> start.sh
echo -n $port >> start.sh
echo -n " -autoupdate -pingboost 3" >> start.sh
chmod +x start.sh

