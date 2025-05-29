#!/bin/bash

NORMAL_USER=${SUDO_USER:-$(logname)}
# install
npm install -g azurite

# add to root
which azurite
sudo ln -s "$NVM_DIR/versions/node/$(nvm version)/bin/azurite" "/usr/local/bin/azurite"

# create required files
sudo mkdir -p /mnt/blockvolume/azurite
sudo mkdir -p /var/log
sudo mkdir -p /etc/azurite/certs

sudo chown -R $NORMAL_USER:$NORMAL_USER /usr/local/bin/azurite
sudo chown -R $NORMAL_USER:$NORMAL_USER /mnt/blockvolume/azurite
sudo chown -R $NORMAL_USER:$NORMAL_USER /etc/azurite
sudo chown -R $NORMAL_USER:$NORMAL_USER /var/log

# Check for Let's Encrypt certificates
echo "Checking for SSL certificates..."
read -p "Enter the domain name used for SSL certificates: " domain_name

cert_path="/etc/letsencrypt/live/$domain_name"
# Check if certificates exist using sudo to avoid permission denied
if sudo test -d "$cert_path"; then
    echo "Found certificates. Copying to Azurite cert directory..."
    sudo cp "${cert_path}/fullchain.pem" /etc/azurite/certs/cert.pem
    sudo cp "${cert_path}/privkey.pem" /etc/azurite/certs/key.pem
    sudo chown -R $NORMAL_USER:$NORMAL_USER /etc/azurite
    
    # Update the deploy hook script if it exists
    deploy_hook="/etc/letsencrypt/renewal/deploy_hook.sh"
    if sudo test -f "$deploy_hook"; then
        echo "Updating SSL renewal hook for Azurite..."
        if ! sudo grep -q "azurite" "$deploy_hook"; then
            sudo tee -a $deploy_hook << EOL

# azurite
AZURITE_CERT_DIR="/etc/azurite/certs"
sudo mkdir -p \${AZURITE_CERT_DIR}
sudo cp \${CERT_PATH}/fullchain.pem \${AZURITE_CERT_DIR}/cert.pem
sudo cp \${CERT_PATH}/privkey.pem \${AZURITE_CERT_DIR}/key.pem
sudo chown -R $NORMAL_USER:$NORMAL_USER \${AZURITE_CERT_DIR}
sudo systemctl restart azurite
EOL
        fi
    fi
else
    echo "ERROR: SSL certificates not found for domain $domain_name at $cert_path"
    echo "Please run the certbot.sh script first to obtain SSL certificates"
    exit 1
fi

# create service file
cat > /tmp/azurite.service << EOL
[Unit]
Description=Azurite Storage Emulator
After=network.target

[Service]
User=$NORMAL_USER
Group=$NORMAL_USER
ExecStart=/usr/local/bin/azurite --silent --location /mnt/blockvolume/azurite --debug /var/log/azurite.log --cert /etc/azurite/certs/cert.pem --key /etc/azurite/certs/key.pem --oauth basic --blobHost 0.0.0.0 --queueHost 0.0.0.0 --tableHost 0.0.0.0 --disableProductStyleUrl
Restart=always
RestartSec=5s
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOL

sudo cp /tmp/azurite.service /etc/systemd/system/azurite.service
rm /tmp/azurite.service

# start service
sudo systemctl daemon-reload
sudo systemctl enable azurite
sudo systemctl restart azurite

# check status
sudo systemctl status azurite

# Configure the Firewall
sudo ufw allow 10000
sudo ufw allow 10001
sudo ufw allow 10002