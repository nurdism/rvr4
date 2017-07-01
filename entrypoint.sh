#!/bin/bash

#fix user
adduser --disabled-password --uid $(id -u) --gid 0 --gecos container container \ 
adduser container sudo
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

sleep 2

#Install the Server
if [[ ! -d /home/container/server ]] || [[ ${UPDATE} == "yes" ]]; then

    /home/container/steamcmd/steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} +force_install_dir /home/container/server +app_update ${APP_ID} validate +quit

	#fix
	if [[ ! -d /home/container/server/mpmissions ]]; then
		ln -s /home/container/server/mpmissions /home/container/server/MPMissions
	fi
	
	#fix
	if [[ ! -f /home/container/server/steamclient.so ]]; then
		rm /home/container/server/steamclient.so
		ln -s /home/container/server/steamcmd/linux32/steamclient.so /home/container/server/steamclient.so
	fi
	
	#fix
	if [[ ! -d /home/container/.local/share ]]; then
		mkdir -p /home/container/.local/share
	fi
	
fi

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo "~/server: ${MODIFIED_STARTUP}"

cd /home/container/server

# Run the Server
${MODIFIED_STARTUP}

if [ $? -ne 0 ]; then
    echo "PTDL_CONTAINER_ERR: There was an error while attempting to run the start command."
    exit 1
fi