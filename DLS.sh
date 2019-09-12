#!/bin/bash

# sudo apt-get install wiringpi smbclient


diffn=start
sleep=5 #temps de la bouche
urlreseau='\\Nasgalere\dls\'

#dossier local
cd /home/pi/RADIO-dsl-gpio/

# Config GPIO

gpio mode 4 in

while true
do

# IN file


sudo smbclient -N $urlreseau -c 'get file/flux-titre.txt'
sudo smbclient -N $urlreseau -c 'get file/flux-direct.txt'


read diff < ./file/flux-diff.txt
read titre < ./file/flux-titre.txt
#read direct < ./file/flux-direct.txt
direct=$(wget -q -O - https://radiogalere.org/?page_id=4565 | grep -oP 'nom_emission_rds.*nom_emission_rds'| awk 'sub("^.................", "")'| awk 'sub(".....................$", "")')


# Modication fichiers

gpio4=$(gpio -g read 4)

if [ $gpio4 = 0 ] # 1 ou 0 selon capteurs
then
	diff=$titre
	mode="TITRE"
else
	diff="En Direct : $direct"
	mode="DIRECT"
fi

echo "$diff" > file/flux-diff.txt

#Logs file + up to icecast

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
wget -q "http://ID:PW@IP:8080/admin/metadata.xsl?song=$diff&mount=%2Fgalere.mp3&mode=updinfo&charset=UTF-8" -O /dev/null # up DLS to radiogalere.org
#echo -n "$diff" | nc -4u -w1 192.168.1.64 9000
fi

diffn=$diff

#OUT file

echo "$(date +%Y_%m_%d__%H:%M) uplog: $uplog --- Mode: $mode --- DLS: $diff"

sudo smbclient -N $urlreseau -c 'put file/flux-diff.txt'
sudo smbclient -N $urlreseau -c "put logs/$(date +%Y%m%d)-DLS.txt"
rm logs/$(date +%Y%m%d --date="-2 day")-DLS.txt #rm log -2 jour


sleep $sleep

done
}
