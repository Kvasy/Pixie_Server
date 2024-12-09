#!/bin/bash

#Exit the script immediately if a command fails.
set -e

#Check that argument was provided otherwise, exit
if [ "$#" -ne 1 ]; then
	echo "Usage: $0 <path-to-USB>"
	exit 1
fi

usb_path=$1

#Validate USB Path
if [ ! -d "$usb_path" ]; then
    echo "Error: Path '$usb_path' is not a valid directory."
    exit 1
fi

echo "Path to USB is set as: $usb_path"

#Validate Pixie Exists on USB Path
if [ ! -d "$usb_path/Pixie" ]; then
    echo "Error: Path '$usb_path/Pixie' is not a valid directory."
    exit 1
fi

#Start with System Configuration by installing relevant packages
echo "Establishing current user..."
if [[ $USER ]]

#Navigate to USB Path
pxe_folder="$usb_path/Pixie"
cd "$pxe_folder"

#Establish folders for files to transfer into
mkdir -p /data/burnin
mkdir -p /tftp
mkdir -p /var/www/html/




#Create relevant directories
mkdir -p "$pxe_folder/tftp" "$pxe_folder/NFS/" "$pxe_folder/fonts" "$pxe_folder/dnsmasq_conf" "$pxe_folder/exports" "$pxe_folder/sshd_config" "$pxe_folder/burnin_logs_folders"

echo "Target folder structure created on $usb_path"

echo "Dumping Current DPKG list..."
sudo dpkg --get-selections > "$pxe_folder/dpkg_list.txt" || {
    echo "Error: Failed to dump DPKG list."
    exit 1
}

echo "Beginning file synchronization..."
rsync -av --progress "$pxe_folder/tftp/" /tftp/  || echo "Error syncing /tftp/"
rsync -av --progress "$pxe_folder/NFS/" /var/www/html/ || echo "Error syncing /var/www/html/"
rsync -av --progress "$pxe_folder/fonts/" /usr/share/fonts/otf/NERDFONTS/RobotoMono || echo "Error syncing /usr/share/fonts/otf/NERDFONTS/RobotoMono"
rsync -av --progress "$pxe_folder/dnsmasq_conf/" /etc/dnsmasq.conf || echo "Error syncing /etc/dnsmasq.conf"
rsync -av --progress "$pxe_folder/exports/" /etc/exports  || echo "Error syncing /etc/exports/"
rsync -av --progress "$pxe_folder/sshd_config/" /etc/ssh/sshd_config || echo "Error syncing /etc/ssh/sshd_config"
rsync -av --progress "$pxe_folder/burnin_logs_folders/" /data/burnin/ || echo "Error syncing /data/burnin/"

echo "Files copied successfully."

echo "Cloning Terminal look and feel..."
cd "$pxe_folder"

#Add logic to extract the GNOME UUID and inject the Monokai Profile
stripUUID() {
	UUID=$(dconf list /org/gnome/terminal/legacy/profiles:/)
	sliced_UUID="${UUID:1:36}"
	echo "sliced_UUID"
}
UUID=$(stripUUID)
dconf load /org/gnome/terminal/legacy/profiles:/"$UUID"/ < fake_monokai_terminal.dconf || echo "Error loading Monokai Terminal Profile"
echo "'Fake MonoKai' and NerdFont RobotoMono 14 copied successfully."
echo "Terminal Setup Complete..."

echo "Please eject the USB and insert it into the newly installed Linux Mint machine."
echo "Pixie Establishment completed."
echo "

