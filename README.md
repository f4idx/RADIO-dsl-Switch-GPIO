# RADIO-dls-Switch-GPIO

CC Joachim Vital-Mermoz Joachim.vm@free.fr

script Bash

Sudo apt-get install wiringpi smbclient

1 - Lire 2 fichier (flux-direct.txt et flux-titre.txt) sur un serveur SMB
2 - Lire le niveau logique le GPIO 4
3 - copier flux-direct.txt ou flux-titre.txt dans le fichir flux-diff.txt selon le GPIO
4 - Log le titre dans le dossier logs/date-dls.txt
3 - Envoié sur le servur SMB le fichier flux-diff.txt et le fichier de log
  
