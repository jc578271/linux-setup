#!/bin/bash
set -e
sudo mkdir /home/$USER/ca /home/$USER/certs /home/$USER/csr
sudo openssl genrsa -des3 -out /home/$USER/ca/InnovateAsterisk-Root-CA.key 4096
sudo openssl req -x509 -new -nodes -key /home/$USER/ca/InnovateAsterisk-Root-CA.key -sha256 -days 3650 -out /home/$USER/ca/InnovateAsterisk-Root-CA.crt
sudo openssl req -new -sha256 -nodes -out /home/$USER/csr/raspberrypi.csr -newkey rsa:2048 -keyout /home/$USER/certs/raspberrypi.key
sudo nano /home/$USER/csr/openssl-v3.cnf
sudo openssl x509 -req -in /home/$USER/csr/raspberrypi.csr -CA /home/$USER/ca/InnovateAsterisk-Root-CA.crt -CAkey /home/$USER/ca/InnovateAsterisk-Root-CA.key -CAcreateserial -out /home/$USER/certs/raspberrypi.crt -days 365 -sha256 -extfile /home/$USER/csr/openssl-v3.cnf
sudo cat /home/$USER/certs/raspberrypi.crt /home/$USER/certs/raspberrypi.key > /home/$USER/certs/raspberrypi.pem
sudo chmod a+r /home/$USER/certs/raspberrypi.key
echo "Done!"
