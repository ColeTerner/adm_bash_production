#!/bin/bash

#1)Selecting the network interface
echo "1.Selecting network interface for setting up..."

ip a
echo "Select the network interface which you want to set up:"
read net_interface

#2)Creating file of config

echo "2.Creating file of config..."
sudo touch /etc/sysconfig/network-scripts/ifcfg-$net_interface

#3)Filling it up

echo "3.Filling up the file of config - /etc/sysconfig/network-scripts/ifcfg-$net_interface..."

echo "Input IP-address:"
read ip_addr
echo "Input mask prefix(like 24):"
read mask
echo "Input gateway:"
read gateway
echo "Input dns1:"
read dns1
echo "Input dns2:"
read dns2
echo "Input domain:"
read domain

config_parameters=('TYPE = "Ethernet"' 'IPV4_FAILURE_FATAL="yes"' 'IPV6INIT="yes"' 'IPV6_AUTOCONF="yes"' "NAME=\"$net_interface\"" "DEVICE=\"$net_interface\"" 'ONBOOT="yes"' "IPADDR=\"$ip_addr\"" "PREFIX=\"$mask\"" "GATEWAY=\"$gateway\"" "DNS1=\"$dns1\"" "DNS2=\"$dns2\"" "DOMAIN=\"$domain\"")

for ((i=0;i<${#config_parameters[@]};i++)); do
	echo ${config_parameters[${i}]} | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-$net_interface
done

#4)Restarting NETWORK service

echo "4.Restarting NETWORK-service..."
sudo systemctl restart network


