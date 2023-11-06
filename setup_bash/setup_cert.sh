#!/bin/bash
sudo mkdir /home/pi/ca /home/pi/certs /home/pi/csr
sudo openssl genrsa -des3 -out /home/pi/ca/InnovateAsterisk-Root-CA.key 4096
sudo openssl req -x509 -new -nodes -key /home/pi/ca/InnovateAsterisk-Root-CA.key -sha256 -days 3650 -out /home/pi/ca/InnovateAsterisk-Root-CA.crt
sudo openssl req -new -sha256 -nodes -out /home/pi/csr/raspberrypi.csr -newkey rsa:2048 -keyout /home/pi/certs/raspberrypi.key
sudo nano /home/pi/csr/openssl-v3.cnf
sudo openssl x509 -req -in /home/pi/csr/raspberrypi.csr -CA /home/pi/ca/InnovateAsterisk-Root-CA.crt -CAkey /home/pi/ca/InnovateAsterisk-Root-CA.key -CAcreateserial -out /home/pi/certs/raspberrypi.crt -days 365 -sha256 -extfile /home/pi/csr/openssl-v3.cnf
sudo cat /home/pi/certs/raspberrypi.crt /home/pi/certs/raspberrypi.key > /home/pi/certs/raspberrypi.pem
sudo chmod a+r /home/pi/certs/raspberrypi.key
echo "Done!"
