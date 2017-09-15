#!/bin/bash
diffn=start
sleep=20 #temps de la bouche
urlreseau='\\Nasgalere\dls\'

# Config GPIO

gpio mode 4 in

while true
do

# IN file

sudo smbclient -N $urlreseau -c 'get flux-titre.txt'
sudo smbclient -N $urlreseau -c 'get flux-direct.txt'
sudo smbclient -N $urlreseau -c "get logs/$(date +%Y%m%d)-DLS.txt"

# lecture valeurs GPIO
# sudo apt-get install wiringpi

# Modication fichiers

read diff < flux-diff.txt
read titre < flux-titre.txt
read direct < flux-direct.txt

var=$(gpio -g read 4)

if [ $var = 1 ]
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
uplog=YES
echo "$(date +%H:%M) >> $diff" >>  logs/$(date +%Y%m%d)-DLS.txt
fi

diffn=$diff

#OUT file

echo "$(date +%Y%m%d%H%M) uplog: $uplog --- Mode : $mode --- DLS: $diff"


sudo smbclient -N $urlreseau -c 'put flux-diff.txt'
sudo smbclient -N $urlreseau -c "put logs/$(date +%Y%m%d)-DLS.txt"
echo done

sleep $sleep

done
}
