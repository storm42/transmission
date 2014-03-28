#!/bin/bash -
#title           :transmission.sh
#description     :Installing and configurating transmission-daemon.
#author          :Max
#date            :20130911
#version         :1.1 Release
#usage           :chmod +x transmission.sh ; bash transmission.sh
#bash_version    :4.1.5(1)-release
#==============================================================================


# Config

# You can define here the port of your client.
# Change only if you know what you are doing.

# Choosing port. Do not use ports such as 21, 22, 80. Choose a port superior to 1000.
# The port is what your server will use to set his web interface at http://serveraddress:PORT/
port=4242

# Choosing download folder. If it does not exist, it will be created.
download_dir=/home/transmission-downloads/


# Sudoing the script
echo "You must be root to install this tool."
sudo echo "Installation launched" ; clear

if [ 1000 -gt $port ]
then
    echo "Error."
    echo ""
    echo "Port error. Please choose a port superior to 1000"
    exit
fi

if [ $1 == "-r" ]
then
    echo "Removing transmission-daemon..."
    echo ""
    sleep 3
    sudo apt-get remove transmission-daemon --purge
    echo ""
    echo ""
    printf "Do you want to keep your downloaded files (Y/n) ? " ; read -r keep
    if [ $keep == 'n' ]
    then
	echo "Deleting downloads folder ($download_dir)..."
	sleep 3
	sudo rm -rf $download_dir
	rm -f ~/transmission-downloads
    else
	echo "Download files will be kept"
    fi
    echo ""
    echo ""
    echo "Transmission-daemon vient d'être supprimé"
    
elif [ $1 == "-h" ]
then
    echo "Transmission-daemon 2.51 installer"
    echo "Easily install or uninstall transmission-daemon"
    echo ""
    echo "Usage : $0 [options]"
    echo ""
    echo "Options :"
    echo " -i         Install your seedbox"
    echo " -r         Removes transmission daemon from your server"
    echo " -h         Display this help page and exit"
    echo ""
    echo ""
    
else
    
    clear
    
# Installing packet
    echo "Installing transmission-daemon..."
    sleep 3
sudo apt-get install transmission-daemon

# Beginning configurations
echo "Stopping the Daemon"
sudo /etc/init.d/transmission-daemon stop
sudo mkdir -p $download_dir
sudo mkdir -p $download_dir/incomplete
sudo chmod 777 -R $download_dir
touch tmp
# Uncomment next line if you want a symbolic link in your home.
#ln -s $download_dir ~/transmission-downloads

# User configuration
printf "\n\n"
echo "########## Please create your download account ##########"
printf "Please choose a login : " ; read -r login
printf "Please choose a password : " ; read -s password
echo ""
echo "########## Account is creating on transmission ##########"
echo ""
echo ""
# Creating configuration file
echo "Generating configuration file"


echo "
{
    \"alt-speed-down\": 50,
    \"alt-speed-enabled\": false,
    \"alt-speed-time-begin\": 540,
    \"alt-speed-time-day\": 127,
    \"alt-speed-time-enabled\": false,
    \"alt-speed-time-end\": 1020,
    \"alt-speed-up\": 50,
    \"bind-address-ipv4\": \"0.0.0.0\",
    \"bind-address-ipv6\": \"::\",
    \"blocklist-enabled\": false,
    \"cache-size-mb\": 4,
    \"dht-enabled\": true,
    \"blocklist-url\": \"http://www.example.com/blocklist\",
    \"download-dir\": \"$download_dir\",
    \"download-limit\": 100,
    \"download-limit-enabled\": 0,
    \"download-queue-enabled\": true,
    \"download-queue-size\": 5,
    \"encryption\": 2,
    \"idle-seeding-limit\": 300,
    \"idle-seeding-limit-enabled\": false,
    \"incomplete-dir\": \"/home/transmission-downloads/incomplete\",
    \"incomplete-dir-enabled\": false,
    \"lpd-enabled\": false,
    \"max-peers-global\": 200,
    \"message-level\": 2,
    \"peer-congestion-algorithm\": \"\",
    \"peer-limit-global\": 240,
    \"peer-limit-per-torrent\": 60,
    \"peer-port\": 51413,
    \"peer-port-random-high\": 65535,
    \"peer-port-random-low\": 49152,
    \"peer-port-random-on-start\": false,
    \"peer-socket-tos\": \"default\",
    \"pex-enabled\": true,
    \"port-forwarding-enabled\": false,
    \"preallocation\": 1,
    \"prefetch-enabled\": 1,
    \"queue-stalled-enabled\": true,
    \"queue-stalled-minutes\": 30,
    \"ratio-limit\": 2,
    \"ratio-limit-enabled\": false,
    \"rename-partial-files\": true,
    \"rpc-authentication-required\": true,
    \"rpc-bind-address\": \"0.0.0.0\",
    \"rpc-enabled\": true,
    \"rpc-url\": \"/transmission/\",
    \"rpc-whitelist\": \"127.0.0.1\",
    \"rpc-whitelist-enabled\": false,
    \"scrape-paused-torrents-enabled\": true,
    \"script-torrent-done-enabled\": false,
    \"script-torrent-done-filename\": \"\",
    \"seed-queue-enabled\": false,
    \"seed-queue-size\": 10,
    \"speed-limit-down\": 100,
    \"speed-limit-down-enabled\": false,
    \"speed-limit-up\": 100,
    \"speed-limit-up-enabled\": false,
    \"start-added-torrents\": true,
    \"trash-original-torrent-files\": false,
    \"umask\": 18,
    \"upload-limit\": 100,
    \"upload-limit-enabled\": 0,
    \"upload-slots-per-torrent\": 14,
    \"utp-enabled\": true,
" >> ./tmp

# Setting up variables
echo "\"rpc-username\": \"$login\"," >> ./tmp
echo "\"rpc-password\": \"$password\"," >> ./tmp
echo "\"rpc-port\": $port," >> ./tmp
echo "\"download-dir\": \"$download_dir\"" >> ./tmp
echo "}" >> ./tmp

# Moving the configuration file
sudo cp ./tmp /etc/transmission-daemon/settings.json
sudo cp ./tmp /var/lib/transmission-daemon/info/settings.json

# Ending configuration
sudo rm ./tmp

# Starting the server
echo "Starting the server"
sudo /etc/init.d/transmission-daemon start

printf "\n\n"
echo "You can now connect on your client at http://serveraddress:$port/"
echo "Login : "$login
echo "Password : ********"
echo ""
echo ""
echo "Thanks for installing transmission-daemon."
echo "Once downloaded, your files will be on $download_dir"

fi

#EOF