#!/bin/bash

sudo apt install curl

# install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

# load NVM into your current terminal session:
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# or
source ~/.bashrc

# Ask user for Node.js version
echo "Enter the Node.js version you want to install (e.g., 18.16.0, 20.11.1):"
read node_version

# install nodejs
nvm install $node_version
nvm use $node_version
nvm alias default $node_version

echo "Node.js $node_version has been installed and set as default."

npm install -g yarn
npm install -g pm2

# install for root
sudo ln -s "$NVM_DIR/versions/node/$(nvm version)/bin/node" "/usr/local/bin/node"
sudo ln -s "$NVM_DIR/versions/node/$(nvm version)/bin/npm" "/usr/local/bin/npm"
sudo ln -s "$NVM_DIR/versions/node/$(nvm version)/bin/npx" "/usr/local/bin/npx"
sudo ln -s "$NVM_DIR/versions/node/$(nvm version)/bin/yarn" "/usr/local/bin/yarn"
sudo ln -s "$NVM_DIR/versions/node/$(nvm version)/bin/pm2" "/usr/local/bin/pm2"

# npm error code EACCES
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bash_profile
source ~/.bash_profile
sudo chown -R $(whoami):$(id -gn) ~/.npm

# Install build-essential (make, gcc, g++)
echo "Installing build-essential..."
sudo apt install build-essential

# Install Python:
echo "Installing Python..."
sudo apt install python3

# Install Certbot:
echo "Installing Certbot..."
sudo apt install certbot -y