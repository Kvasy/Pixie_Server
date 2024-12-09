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


#Navigate to USB Path
cd "$usb_path"
#Create Pixie top level folder
mkdir -p Pixie

#Alt var to change into Pixie Folder on USB
pxe_folder="$usb_path/Pixie"

#Create relevant directories
mkdir -p "$pxe_folder/tftp" "$pxe_folder/NFS/" "$pxe_folder/fonts" "$pxe_folder/dnsmasq_conf" "$pxe_folder/exports" "$pxe_folder/sshd_config" "$pxe_folder/burnin_logs_folders"

echo "Target folder structure created on $usb_path"

echo "Dumping Current DPKG list..."
sudo dpkg --get-selections > "$pxe_folder/dpkg_list.txt" || {
    echo "Error: Failed to dump DPKG list."
    exit 1
}

echo "Beginning file synchronization..."
rsync -av --progress /tftp/ "$pxe_folder/tftp/" || echo "Error syncing /tftp/"
rsync -av --progress /var/www/html/ "$pxe_folder/NFS/" || echo "Error syncing /var/www/html/"
rsync -av --progress /usr/share/fonts/otf/NERDFONTS/RobotoMono "$pxe_folder/fonts/" || echo "Error syncing /usr/share/fonts/otf/NERDFONTS/RobotoMono"
rsync -av --progress /etc/dnsmasq.conf "$pxe_folder/dnsmasq_conf/" || echo "Error syncing /etc/dnsmasq.conf"
rsync -av --progress /etc/exports "$pxe_folder/exports/" || echo "Error syncing /etc/exports/"
rsync -av --progress /etc/ssh/sshd_config "$pxe_folder/sshd_config/" || echo "Error syncing /etc/ssh/sshd_config"
rsync -av --progress /data/burnin/ "$pxe_folder/burnin_logs_folders/" || echo "Error syncing /data/burnin/"

echo "Files copied successfully."

echo "Cloning Terminal look and feel..."
cd "$pxe_folder"
dconf dump /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ > fake_monokai_terminal.dconf || echo "Error dumping Monokai Terminal Profile"
echo "'Fake MonoKai' and NerdFont RobotoMono 14 copied successfully."

echo "Please eject the USB and insert it into the newly installed Linux Mint machine."
echo "Then run: Establish_Pixie.sh on the new machine."
