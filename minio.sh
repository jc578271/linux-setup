#!/bin/bash

# Ask for MinIO credentials
echo "MinIO Setup"
echo "==========="
read -p "Enter MinIO root username [default: ubuntu]: " minio_user
minio_user=${minio_user:-ubuntu}

read -s -p "Enter MinIO root password: " minio_password
echo
if [ -z "$minio_password" ]; then
    echo "Error: Password cannot be empty"
    exit 1
fi

# Check if /mnt/blockvolume exists
if [ ! -d "/mnt/blockvolume" ]; then
    echo "Error: /mnt/blockvolume directory not found."
    echo "Please mount a block volume first using the blockvolume.sh script."
    exit 1
fi

echo "Downloading MinIO Binary..."
wget https://dl.min.io/server/minio/release/linux-arm64/minio

echo "Making Binary Executable..."
chmod +x minio

echo "Creating MinIO system user..."
sudo adduser --system --group --no-create-home minio

echo "Moving MinIO Binary to system location..."
sudo mv minio /usr/local/bin/

echo "Creating Directory for MinIO Data..."
sudo mkdir -p /mnt/blockvolume/minio

echo "Setting proper permissions..."
sudo chown -R minio:minio /usr/local/bin/minio
sudo chown -R minio:minio /mnt/blockvolume/minio

# Create certificates directory
echo "Creating MinIO certificates directory..."
sudo mkdir -p /etc/minio/certs
sudo chown -R minio:minio /etc/minio/certs

# Create systemd service file
echo "Creating systemd service file..."
cat > /tmp/minio.service << EOL
[Unit]
Description=MinIO
Documentation=https://docs.min.io
Wants=network-online.target
After=network-online.target

[Service]
Environment="MINIO_ROOT_USER=$minio_user"
Environment="MINIO_ROOT_PASSWORD=$minio_password"
User=minio
Group=minio
ExecStart=/usr/local/bin/minio server /mnt/blockvolume/minio --console-address ":9001" --address ":9000" --certs-dir /etc/minio/certs
Restart=always
RestartSec=5s
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOL

sudo mv /tmp/minio.service /etc/systemd/system/minio.service

# Check if SSL certificates exist and copy them
echo "Checking for SSL certificates..."
read -p "Enter the domain name used for SSL certificates: " domain_name

cert_path="/etc/letsencrypt/live/$domain_name"
if [ -d "$cert_path" ]; then
    echo "Found certificates. Copying to MinIO cert directory..."
    sudo cp ${cert_path}/fullchain.pem /etc/minio/certs/public.crt
    sudo cp ${cert_path}/privkey.pem /etc/minio/certs/private.key
    sudo chown -R minio:minio /etc/minio/certs
    
    # Update the deploy hook script if it exists
    deploy_hook="/etc/letsencrypt/renewal/deploy_hook.sh"
    if [ -f "$deploy_hook" ]; then
        echo "Updating SSL renewal hook for MinIO..."
        if ! grep -q "MINIO_CERT_DIR" "$deploy_hook"; then
            sudo tee -a $deploy_hook << EOL

# minio
MINIO_CERT_DIR="/etc/minio/certs"
sudo mkdir -p \${MINIO_CERT_DIR}
sudo cp \${CERT_PATH}/fullchain.pem \${MINIO_CERT_DIR}/public.crt
sudo cp \${CERT_PATH}/privkey.pem \${MINIO_CERT_DIR}/private.key
sudo chown -R minio:minio \${MINIO_CERT_DIR}
sudo systemctl restart minio
EOL
        fi
    fi
else
    echo "Warning: SSL certificates not found. MinIO will start without SSL."
    echo "You can add certificates later to /etc/minio/certs/"
fi

# Start MinIO service
echo "Starting MinIO service..."
sudo systemctl daemon-reload
sudo systemctl enable minio
sudo systemctl start minio
sudo systemctl status minio

# Configure the Firewall
echo "Configuring firewall..."
sudo ufw allow 9000
sudo ufw allow 9001

echo "MinIO setup complete!"
echo "Access MinIO API at port 9000"
echo "Access MinIO Console at port 9001"