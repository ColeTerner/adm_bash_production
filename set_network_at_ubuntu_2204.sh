#!/bin/bash
echo "Input ip-address netmask gateway and nameserver as arguments to the script"
#scriptname ip mask gateway dns

net_config="/etc/network/interfaces"
dns_config="/etc/systemd/resolved.conf"

#Removing NETWORK_MANAGER
apt-get -y remove network-manager
rm -R /etc/NetworkManager/system-connections

#Disabling service NETWORKING
systemctl stop networking
systemctl disable networking

#Ediding /etc/network/interfaces
content=( "auto lo" "iface lo inet loopback" "auto ens38" "iface ens38 inet static" "	address $1" "	netmask $2" "	gateway $3" "	nameserver $4" )

echo "#editing" | tee $net_config

for ix in ${!content[*]}
do
	printf "	%s\n" "${content[$ix]}" | tee -a $net_config
done

#Editing  DNS settings
echo "DNS=$4" | tee -a $dns_config

#Restart of service systemd-resolved.service
systemctl restart systemd-resolved.service

#Start networking
systemctl enable networking
systemctl start networking

#reboot of the system
reboot
