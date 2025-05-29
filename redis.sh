CURRENT_EXECUTE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# add user
sudo adduser --system --group --no-create-home redis

# install deps
sudo apt-get install -y build-essential pkg-config libssl-dev

# download
cd ~
wget http://download.redis.io/redis-stable.tar.gz
tar -xzvf redis-stable.tar.gz

# install
cd redis-stable/
make MALLOC=libc BUILD_TLS=yes

# prompt for Redis password
echo "Enter Redis password: "
read -s redis_password
echo "Password set."

# add config file
sudo mkdir -p /etc/redis
sudo cp $CURRENT_EXECUTE_DIR/redis.conf /etc/redis/
sudo sed -i "s/<your password>/$redis_password/g" /etc/redis/redis.conf

# create key, cert
echo "Generating certificates... $CURRENT_EXECUTE_DIR/certs/tls"
sudo bash $CURRENT_EXECUTE_DIR/gen-certs.sh
sudo cp -R $CURRENT_EXECUTE_DIR/certs/tls /etc/redis

# copy to /usr/local/bin/
sudo cp src/redis-server src/redis-cli src/redis-benchmark src/redis-check-aof src/redis-check-rdb /usr/local/bin/

# create folder
sudo mkdir -p /var/lib/redis
sudo mkdir -p /var/log/redis
sudo mkdir -p /var/run/redis

sudo chown -R redis:redis /etc/redis
sudo chown -R redis:redis /var/lib/redis
sudo chown -R redis:redis /var/log/redis
sudo chown -R redis:redis /var/run/redis

# add to system
cat > /tmp/redis.service << EOL
[Unit]
Description=Advanced key-value store
After=network.target
Documentation=http://redis.io/documentation, man:redis-server(1)

[Service]
ExecStart=/usr/local/bin/redis-server /etc/redis/redis.conf
Restart=always
RestartSec=5s
User=redis
Group=redis
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
Alias=redis.service
EOL

sudo cp /tmp/redis.service /etc/systemd/system/redis.service
rm /tmp/redis.service

sudo ln -s /etc/systemd/system/redis.service /etc/systemd/system/redis-server.service

# run redis
sudo systemctl daemon-reload
sudo systemctl enable redis-server
sudo systemctl start redis-server
sudo systemctl status redis-server

echo "Redis installed with TLS support and password protection"
echo "To connect: redis-cli --tls -a $redis_password"

sudo ufw allow 6379