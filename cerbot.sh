#!/bin/bash

# Ask for domain input
echo "Enter your domain name (e.g., example.com):"
read domain_name

if [ -z "$domain_name" ]; then
    echo "Error: Domain name cannot be empty"
    exit 1
fi

echo "Setting up SSL certificate for domain: $domain_name"



# Reminder about firewall
echo "IMPORTANT: Make sure port 80 is open in your firewall/VCN before continuing."
read -p "Press Enter when ready to continue..."

# Obtain the Certificate:
echo "Obtaining SSL certificate for $domain_name..."
sudo certbot certonly --standalone -d $domain_name

# Certbot will place your certificates in:
echo "Certificates are stored in: /etc/letsencrypt/live/$domain_name/"

# Test automatic renewal with Certbot:
echo "Testing automatic renewal..."
sudo certbot renew --dry-run

# Certbot usually sets up a cron job for automatic renewal.
echo "Checking for renewal timers:"
sudo systemctl list-timers | grep certbot

# If it's not set up, set up a cron job:
echo "Setting up cron job for certificate renewal..."
(crontab -l 2>/dev/null; echo "0 0 * * * /usr/bin/certbot renew --quiet") | sort - | uniq - | crontab -

# Create a Script to Copy the Certificates
echo "Creating deploy hook script..."
cat > /tmp/deploy_hook.sh << EOL
#!/bin/bash
CERT_PATH="/etc/letsencrypt/live/$domain_name"
NORMAL_USER=\${SUDO_USER:-\$(logname)}
# Add your certificate deployment commands here
echo "Certificate for $domain_name has been renewed at \$(date)" >> /var/log/letsencrypt/deploy.log
EOL

sudo mv /tmp/deploy_hook.sh /etc/letsencrypt/renewal/deploy_hook.sh

# Make the Script Executable
sudo chmod +x /etc/letsencrypt/renewal/deploy_hook.sh

# Set Up Certbot to Use the Script After Renewal
echo "Configuring renewal hook..."
renewal_conf="/etc/letsencrypt/renewal/$domain_name.conf"

if [ -f "$renewal_conf" ]; then
    # Check if deploy_hook already exists
    if grep -q "deploy_hook" "$renewal_conf"; then
        sudo sed -i "s|deploy_hook =.*|deploy_hook = /etc/letsencrypt/renewal/deploy_hook.sh|" "$renewal_conf"
    else
        # Add deploy_hook to renewalparams section
        sudo sed -i "/\[renewalparams\]/a deploy_hook = /etc/letsencrypt/renewal/deploy_hook.sh" "$renewal_conf"
    fi
else
    echo "Warning: Renewal configuration file not found. It will be created after the first renewal."
fi

echo "SSL certificate setup for $domain_name is complete!"
