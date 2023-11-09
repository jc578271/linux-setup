#!/bin/bash
set -e

read -p "Enter your passwd: " PASSWD
read -p "Common Name (raspberry.local): " COMMON

read -p "Country (VN): " COUNTRY
read -p "Province: " PROVINCE
read -p "City: " CITY
read -p "Organization Name: " COMPANY
read -p "Organizational Unit Name: " UNIT
read -p "Email Address: " EMAIL

mkdir /home/$USER/ca /home/$USER/certs /home/$USER/csr
echo "openssl genrsa InnovateAsterisk-Root-CA"
sudo openssl genrsa -passout pass:$PASSWD -des3 -out /home/$USER/ca/InnovateAsterisk-Root-CA.key 4096

echo "openssl req InnovateAsterisk-Root-CA"
sudo openssl req -passin pass:$PASSWD -x509 -new -nodes -key /home/$USER/ca/InnovateAsterisk-Root-CA.key -sha256 -days 3650 -out /home/$USER/ca/InnovateAsterisk-Root-CA.crt -subj "/C=${COUNTRY}/ST=${PROVINCE}/L=${CITY}/O=${COMPANY}/OU=${UNIT}/CN=${COMMON}/emailAddress=${EMAIL}"

echo "openssl req raspberrypi"
sudo openssl req -passin pass:$PASSWD -new -sha256 -nodes -out /home/$USER/csr/raspberrypi.csr -newkey rsa:2048 -keyout /home/$USER/certs/raspberrypi.key -subj "/C=${COUNTRY}/ST=${PROVINCE}/L=${CITY}/O=${COMPANY}/OU=${UNIT}/CN=${COMMON}/emailAddress=${EMAIL}"

sudo touch /home/$USER/csr/openssl-v3.cnf

sudo tee -a /home/$USER/csr/openssl-v3.cnf > /dev/null <<EOT
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = $COMMON
EOT
# sudo nano /home/$USER/csr/openssl-v3.cnf

echo "openssl x509"
sudo openssl x509 -passin pass:$PASSWD -req -in /home/$USER/csr/raspberrypi.csr -CA /home/$USER/ca/InnovateAsterisk-Root-CA.crt -CAkey /home/$USER/ca/InnovateAsterisk-Root-CA.key -CAcreateserial -out /home/$USER/certs/raspberrypi.crt -days 365 -sha256 -extfile /home/$USER/csr/openssl-v3.cnf

sudo cat /home/$USER/certs/raspberrypi.crt /home/$USER/certs/raspberrypi.key > /home/$USER/certs/raspberrypi.pem
sudo chmod a+r /home/$USER/certs/raspberrypi.key
echo "Done!"
