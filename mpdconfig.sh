#!/bin/bash

# This generates your personal mopidy config

mopidy="~/.config/mopidy/mopidy.conf"


echo "This script will create a config for Mopidy"

echo "Please enter a hostname for mopidy"
read hostname

while true; do
read -p "Do you want to use Spotify?(Y/N)" yn
    case $yn in
        [Yy]* ) echo -n "Enter your username and press [ENTER]: "
                read username
                echo -n "Enter your password and press [ENTER]: "
                read password
                break;;


        [Nn]* ) echo "Okay, no spotify"; break;;
        * ) echo "Please answer y or n.";;
    esac
done

echo "[mpd]" > $mopidy
echo "$hostname" >> $mopidy
echo "[spotify]" >> $mopidy
echo "username = $username" >> $mopidy
echo "password = $password" >> $mopidy

echo "Config succesfull"
exit 1
