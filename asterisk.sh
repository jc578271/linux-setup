#!/bin/bash
set -e
echo $USER

# INSTALL ASTERISK
read -p "Do you want to download and install Asterisk (y/n)" DOWNLOAD_OPTION
if [ "$DOWNLOAD_OPTION" = "y" ];
then
sudo apt-get install xmlstarlet libopus-dev libopusfile-dev

# Check if file existed
if [ ! -f "/home/${USER}/asterisk-20-current.tar.gz" ];
then
echo "Download asterisk-20-current.tar.gz"
wget -P /home/$USER http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-20-current.tar.gz
fi

# Unzip file
sudo rm -rf /home/$USER/asterisk-20-current
mkdir /home/$USER/asterisk-20-current
tar -xvf /home/$USER/asterisk-20-current.tar.gz -C /home/$USER/asterisk-20-current --strip-components=1

echo "Install asterisk..."
cd /home/$USER/asterisk-20-current && sudo contrib/scripts/install_prereq install
cd /home/$USER/asterisk-20-current && sudo ./configure --with-pjproject-bundled
cd /home/$USER/asterisk-20-current && sudo make menuselect
cd /home/$USER/asterisk-20-current && sudo make
cd /home/$USER/asterisk-20-current && sudo make install
echo "Configure Asterisk..."
cd /home/$USER/asterisk-20-current && sudo make samples
cd /home/$USER/asterisk-20-current && sudo make config
echo "Install Asterisk successfully"
else
echo "Not install Asterisk. Contninue..."
echo "Configure Asterisk..."
cd /home/$USER/asterisk-20-current && sudo make samples
cd /home/$USER/asterisk-20-current && sudo make config
fi

# Browser Phone
read -p "Do you want to clone Browser-Phone.git (y/n)" BROWSER_PHONE_OPTION
if [ "$BROWSER_PHONE_OPTION" = "y" ];
then
echo "Clone Browser-Phone.git..."
cd ~ && git clone https://github.com/InnovateAsterisk/Browser-Phone.git
else
echo "Continue..."
fi

echo "Config Asterisk with Browser-Phone..."
sudo cp -r /home/$USER/Browser-Phone/config/* /etc/asterisk/
sudo rm /var/lib/asterisk/static-http/*
sudo cp -r /home/$USER/Browser-Phone/Phone/* /var/lib/asterisk/static-http/
sudo chmod 744 /var/lib/asterisk/static-http/*

sudo tee /etc/asterisk/http.conf > /dev/null <<EOT
[general]
enabled=no ; HTTP
tlsenable=yes ; HTTPS
tlsbindaddr=0.0.0.0:443
tlscertfile=/home/$USER/certs/raspberrypi.crt
tlsprivatekey=/home/$USER/certs/raspberrypi.key
enablestatic=yes
sessionlimit=1000
redirect=/ /static/index.html
EOT

sudo cp -r /home/$USER/Browser-Phone/modules/ast-16/codec_opus_arm.so /usr/lib/asterisk/modules
echo "Copy AST_BUILDOPT_SUM:"
cat /home/$USER/asterisk-20-current/include/asterisk/buildopts.h
read -p "Input AST_BUILDOPT_SUM:" AST_BUILDOPT_SUM
sudo sed -i "s/1fb7f5c06d7a2052e38d021b3d8ca151/${AST_BUILDOPT_SUM}/g" /usr/lib/asterisk/modules/codec_opus_arm.so


# START ASTERISK SERVICE
echo "Start Asterisk service..."
sudo service asterisk start
sudo service asterisk restart
echo "Done"
