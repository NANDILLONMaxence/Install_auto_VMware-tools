#!/bin/bash

# Fonction pour exécuter une commande et vérifier son succès
run_command() {
  "$@"
  local status=$?
  if [ $status -eq 0 ]; then
    echo "Command \"$@\" completed successfully."
  else
    echo "Error executing command \"$@\". Error code : $status"
    exit $status
  fi
}

# Fonction pour vérifier si le répertoire /mnt/cdrom existe
check_mount_dir() {
  if [ -d "/mnt/cdrom" ]; then
    echo "The /mnt/cdrom directory already exists."
  else
    echo "The /mnt/cdrom directory does not exist. Creation in progress..."
    run_command mkdir -p /mnt/cdrom
  fi
}

# Fonction pour vérifier si l'image des VMware Tools est montée
check_image_mount() {
  if [[ $(lsblk -no MOUNTPOINT /dev/cdrom) == "/mnt/cdrom" ]]; then
    echo "The VMware Tools image is already mounted."
  else
    echo "The VMware Tools image is not mounted. Editing in progress..."
    run_command mount /dev/cdrom /mnt/cdrom
  fi
}

# Étape I : Vérifier si le répertoire /mnt/cdrom existe
run_command check_mount_dir

# Étape II : Vérifier si l'image des VMware Tools est montée
run_command check_image_mount

# Étape III : Extrayez les fichiers d'installation des VMware Tools
run_command cp /mnt/cdrom/VMwareTools-*.tar.gz /tmp/
run_command cd /tmp
run_command tar -zxvf VMwareTools-*.tar.gz
run_command cd ./vmware-tools-distrib/

# Étape IV : Installez les VMware Tools
echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
echo "|Default configuration is yes for the first question and enter for the next questions|"
echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
run_command ./vmware-install.pl

# Étape V : Supprimez les fichiers temporaires
run_command cd /tmp
run_command rm -f VMwareTools-*.tar.gz
run_command rm -rf /tmp/vmware-tools-distrib

# Fonction pour vérifier si le lecteur est monté
check_mounted() {
  if [[ $(lsblk -no MOUNTPOINT /dev/cdrom) == "/mnt/cdrom" ]]; then
    echo "The drive is mounted. Disassembly and removal in progress..."
    run_command umount /mnt/cdrom
	run_command rmdir /mnt/cdrom
  else 
	echo "The drive was automatically unmounted."
  fi
}

# Étape VI : Vérifier si le lecteur est monté
run_command check_mounted



echo "Installation of VMware Tools completed."
echo " "
service vmware-tools restart
service vmware-tools status
echo " "
echo "---------------------Version 2----------------------"
echo "------------Create by NANDILLON Maxence-------------"
echo "----------------------------------------------------"

