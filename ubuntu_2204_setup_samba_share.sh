#!/bin/bash

#1)Installing samba
echo "1.Installing samba..."
sudo apt-get install samba -y

#2)Create/set share
echo "2.Creating/setting SHARE folder"

echo "Input the name of new group which be given access to samba-share"
read samba_group
echo "Input existing user on this host who will join the samba-share group"
read samba_user
echo "Input the local path on the samba-server(this) to make it SHARE-PATH"
read samba_path
echo "Input your domain"
read samba_domain
echo "Input name of your share folder"
read samba_folder_name
sudo groupadd $samba_group   #creating new group of users

sudo groupadd $samba_group
sudo mkdir -p $samba_path

#Add new users into the group
while [ true ]; do
	echo "Add another user to your samba group(or exit for stopping)"
	read u
	if [ $u = 'exit' ]; then
		break
	fi
	sudo usermod -aG $samba_group $u
done


sudo chown -R $samba_user:$samba_group $samba_path  #ownership on the share

sudo chmod -R g+rw $samba_path	#ACL rights on samba-group to read-write

#3)Setting samba config
echo "3.Editing samba config /etc/samba/smb.conf..."

#Change the existing setting - workgroup
sudo sed -i "s/WORKGROUP/$samba_domain/" /etc/samba/smb.conf

#Add server protocol support
cd /mnt
sudo touch support.txt
echo "server min protocol = NT1" | sudo tee -a /mnt/support.txt
sudo sed -i '24r /mnt/support.txt' /etc/samba/smb.conf

#Adding SHARE-folder options to the end of config
arr=("[$samba_folder_name]" "path = $samba_path" "valid users = @$samba_group" "browsable = yes" "writable = yes" "read only = no")
elems=${#arr[@]}

for (( i=0;i<$elems;i++)); do
	echo ${arr[${i}]} | sudo tee -a /etc/samba/smb.conf
done

#4)Setting UFW RULES
echo "4.Setting UFW allow-rules for incoming SAMBA-connection..."

sudo ufw disable
sudo ufw allow Samba
sudo ufw enable

#5)Restart of the samba service
echo "5.Restarting smbd.service..."
sudo systemctl restart smbd

