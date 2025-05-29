#!/bin/bash

while true; do
    clear
    echo "===== System Configuration Menu ====="
    echo "0. Exit"
    echo "1. Configure Firewall (ufw.sh)"
    echo "2. Mount Block Volume (blockvolume.sh)"
    echo "3. Install dependencies (install.sh)"
    echo "4. Install Redis with TLS (redis.sh)"
    echo "5. Install Azurite Storage Emulator (azurite.sh)"
    echo "6. View Let's Encrypt deploy hook"
    echo "===================================="
    echo
    read -p "Enter your choice [0-6]: " choice
    
    case $choice in
        0)
            echo "Exiting..."
            exit 0
            ;;
        1)
            echo "Running firewall configuration..."
            bash ufw.sh
            read -p "Press Enter to return to menu..."
            ;;
        2)
            echo "Running block volume mounting script..."
            bash blockvolume.sh
            read -p "Press Enter to return to menu..."
            ;;
        3)
            echo "Installing dependencies..."
            bash install.sh
            read -p "Press Enter to return to menu..."
            ;;
        4)
            echo "Installing Redis with TLS support..."
            bash redis.sh
            read -p "Press Enter to return to menu..."
            ;;
        5)
            echo "Installing Azurite Storage Emulator..."
            bash azurite.sh
            read -p "Press Enter to return to menu..."
            ;;
        6)
            echo "Checking Let's Encrypt deploy hook script..."
            if sudo test -f "/etc/letsencrypt/renewal/deploy_hook.sh"; then
                echo "Deploy hook path:"
                echo "===================================="
                echo /etc/letsencrypt/renewal/deploy_hook.sh
                echo "===================================="
            else
                echo "ERROR: Deploy hook file does not exist at /etc/letsencrypt/renewal/deploy_hook.sh"
                echo "The file will be created automatically when you run certbot and set up services that use certificates."
            fi
            read -p "Press Enter to return to menu..."
            ;;
        *)
            echo "Invalid option. Please try again."
            sleep 2
            ;;
    esac
done

