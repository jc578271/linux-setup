#!/bin/bash

# INSTALL ASTERISK
read -p "Do use want to install Asterisk (y/n)" INSTALL_OPTION
if [ "$INSTALL_OPTION" = "y" ];
then
echo "Install asterisk..."
sudo apt-get install xmlstarlet libopus-dev libopusfile-dev
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-20-current.tar.gz
tar -xvf asterisk-20-current.tar.gz

echo "here is your unzip file:"
ls
read -p "Enter your unzip Asterisk folder:" ASTERISK_FOLDER
cd /home/pi/$ASTERISK_FOLDER
sudo contrib/scripts/install_prereq install
sudo ./configure --with-pjproject-bundled
sudo make menuselect
sudo make
sudo make install
echo "Install Asterisk successfully"
else
echo "Not install Asterisk. Contninue..."
fi

# ------------------------------------------
# CONFIGURE ASTERISK
echo "Configure Asterisk..."
sudo make samples
sudo make config

# Browser Phone
cd ~
read -p "Do you want to clone Browser-Phone.git (y/n)" BROWSER_PHONE_OPTION
if [ "$BROWSER_PHONE_OPTION" = "y" ];
then
echo "Clone Browser-Phone.git..."
git clone https://github.com/InnovateAsterisk/Browser-Phone.git
else
echo "Continue..."
fi

echo "Config Asterisk with Browser-Phone..."
sudo cp /home/pi/Browser-Phone/config/* /etc/asterisk/
sudo rm /var/lib/asterisk/static-http/*
sudo cp /home/pi/Browser-Phone/Phone/* /var/lib/asterisk/static-http/
sudo chmod 744 /var/lib/asterisk/static-http/*
sudo nano /etc/asterisk/http.conf
sudo cp /home/pi/Browser-Phone/modules/ast-16/codec_opus_arm.so /usr/lib/asterisk/modules
echo "Copy AST_BUILDOPT_SUM:"
cat /home/pi/asterisk-20.5.0/include/asterisk/buildopts.h
read -p "Input AST_BUILDOPT_SUM:" AST_BUILDOPT_SUM
sudo sed -i 's/1fb7f5c06d7a2052e38d021b3d8ca151/$AST_BUILDOPT_SUM/g' /usr/lib/asterisk/modules/codec_opus_arm.so

echo "Start Asterisk service..."
sudo service asterisk start
echo "Done"
