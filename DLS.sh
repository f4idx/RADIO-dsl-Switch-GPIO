#!/bin/bash

# sudo apt-get install wiringpi smbclient


diffn=start
sleep=20 #temps de la bouche
urlreseau='\\Nasgalere\dls\'

#dossier local
cd /home/pi/RADIO-dsl-gpio/

# Config GPIO

gpio mode 4 in

while true
do

# IN file

sudo smbclient -N $urlreseau -c 'get flux-titre.txt'
sudo smbclient -N $urlreseau -c 'get flux-direct.txt'
sudo smbclient -N $urlreseau -c "get logs/$(date +%Y%m%d)-DLS.txt"

read diff < flux-diff.txt
read titre < flux-titre.txt
read direct < flux-direct.txt

# Modication fichiers

gpio4=$(gpio -g read 4)

if [ $gpio4 = 1 ] # 1 ou 0 selon capteurs
then
	diff=$titre
	mode="TITRE"
else
	diff=$direct
	mode="DIRECT"
fi

echo "$diff" > flux-diff.txt

#Logs file

if [ "$diff" = "$diffn" ]
then
uplog=NON
elif [ "$diffn" = "start" ]
then
uplog=start
echo "$(date +%H:%M) >> STARTING >> $diff" >>  logs/$(date +%Y%m%d)-DLS.txt
else
uplog=OUI
echo "$(date +%H:%M) >> $diff" >>  logs/$(date +%Y%m%d)-DLS.txt
fi

diffn=$diff

#OUT file

echo "$(date +%Y_%m_%d__%H:%M) uplog: $uplog --- Mode: $mode --- DLS: $diff"

sudo smbclient -N $urlreseau -c 'put flux-diff.txt'
sudo smbclient -N $urlreseau -c "put logs/$(date +%Y%m%d)-DLS.txt"

sleep $sleep

done
}
