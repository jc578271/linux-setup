#!/bin/bash

# User Management Menu Script

while true; do
    clear
    echo "===== User Management Menu ====="
    echo "1. List all users"
    echo "2. Add a new user"
    echo "3. Remove a user"
    echo "4. Add user to sudo group"
    echo "5. Remove user from sudo group"
    echo "6. Set password for a user"
    echo "0. Exit"
    echo "================================"
    read -p "Enter your choice: " choice

    case $choice in
        1)  # List all users
            echo "List of users on the system:"
            cat /etc/passwd | cut -d: -f1
            read -p "Press Enter to continue..."
            ;;
        2)  # Add a new user
            read -p "Enter username to add: " username
            if [ -z "$username" ]; then
                echo "Username cannot be empty"
            else
                sudo adduser $username
                echo "User $username added successfully"
            fi
            read -p "Press Enter to continue..."
            ;;
        3)  # Remove a user
            read -p "Enter username to remove: " username
            if [ -z "$username" ]; then
                echo "Username cannot be empty"
            else
                read -p "Remove home directory too? (y/n): " remove_home
                if [[ $remove_home == "y" || $remove_home == "Y" ]]; then
                    sudo deluser --remove-home $username
                else
                    sudo deluser $username
                fi
                echo "User $username removed"
            fi
            read -p "Press Enter to continue..."
            ;;
        4)  # Add user to sudo
            read -p "Enter username to add to sudo group: " username
            if [ -z "$username" ]; then
                echo "Username cannot be empty"
            else
                sudo usermod -aG sudo $username
                echo "User $username added to sudo group"
                echo "Current sudo privileges:"
                sudo -l -U $username
            fi
            read -p "Press Enter to continue..."
            ;;
        5)  # Remove user from sudo
            read -p "Enter username to remove from sudo group: " username
            if [ -z "$username" ]; then
                echo "Username cannot be empty"
            else
                sudo deluser $username sudo
                echo "User $username removed from sudo group"
            fi
            read -p "Press Enter to continue..."
            ;;
        6)  # Set password
            read -p "Enter username to set password: " username
            if [ -z "$username" ]; then
                echo "Username cannot be empty"
            else
                sudo passwd $username
            fi
            read -p "Press Enter to continue..."
            ;;
        0)  # Exit
            echo "Exiting user management menu"
            exit 0
            ;;
        *)  # Invalid option
            echo "Invalid option"
            read -p "Press Enter to continue..."
            ;;
    esac
done