#!/bin/bash

sudo apt-get update
sudo ufw enable
sudo ufw allow 22
sudo ufw allow 443
sudo ufw allow 80