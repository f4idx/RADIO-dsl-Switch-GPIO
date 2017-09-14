#!/bin/bash

sleep=20 #temps de la bouche
urlreseau='\\Nasgalere\dls\'

# Config GPIO

gpio mode 4 in

while true
do

# IN file

sudo smbclient -N $urlreseau -c 'get flux-titre.txt'
sudo smbclient -N $urlreseau -c 'get flux-direct.txt'

# lecture valeurs GPIO 
# sudo apt-get instal wiringpi

# Modication fichiers

read diff < flux-diff.txt
read titre < flux-titre.txt
read direct < flux-direct.txt

var=$(gpio -g read 4)

if [ $var = 1 ]
then
	diff=$titre
	echo "Mode TITRE DLS: $diff"
else
	diff=$direct
	echo "Mode DIRECT DLS: $diff"
fi

echo "$diff" > flux-diff.txt

#OUT file

sudo smbclient -N $urlreseau -c 'put flux-diff.txt'

echo done

sleep $sleep

done
}
