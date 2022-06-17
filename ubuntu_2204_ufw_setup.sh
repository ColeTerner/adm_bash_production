#!/bin/bash

#DISABLING FIREWALL
ufw disable

#1)CHECK the UFW config for IPv6 ENABLE (string IPV6=yes inside a file /etc/default/ufw)

ufw_ipv6=false
while IFS= read -r line
do
	if [ "$line" = "IPV6=yes" ]; then
		echo "$line" && ufw_ipv6=true
		echo "IPv6 is already set inside a file /etc/default/ufw"
		break
	fi
done <  /etc/default/ufw

echo "$ufw_ipv6"

if [ $ufw_ipv6 == false ]; then
	echo 'IPV6=yes' | tee -a /etc/default/ufw
fi


#2)SETTING DEFAULT POLICIES (deny - incoming, allow - outgoing)

ufw default deny incoming
ufw default allow outgoing

#3)SSH setting

echo "Do you need SSH enabled at your server?(y/n)"

read answer_ssh

if [ $answer_ssh = "y" ]; then
	ufw allow 22
else
	echo "SSH IS NOT ENABLED"
fi

#4)HTTP/HTTPS setting

echo "How do you prefer to configure HTTP/HTTPS?"
echo "1) HTTP only"
echo "2) HTTPS only"
echo "3) HTTP/HTTPS ON"
echo "4) HTTP/HTTPS OFF"
echo "5) Nothing"

read choice

case $choice in
	1) ufw allow 80;;
	2) ufw allow 443;;
	3) ufw allow 80 && ufw allow 443;;
	4) ufw deny 80 && ufw deny 443;;
	5) exit
esac

#5)Opening other TCP ports

echo "Do you wish to open any TCP ports at your server?"
echo "Enter exit for stopping in the FIRST PORT"

while [ true ]; do
	echo "Input first port:"
	read tcp_port1
	if [ $tcp_port1 = "exit" ]; then
		break
	fi
	ufw allow $tcp_port1/tcp
	echo "Input second port(only for ranges):"
	read tcp_port2
	if [ $tcp_port2 ]; then
		ufw allow $tcp_port1:$tcp_port2/tcp
	fi
done


#6)Opening other UDP ports

echo "Do you wish to open any UDP ports at your server?"
echo "Enter exit for stopping in the FIRST PORT"

while [ true ]; do
	echo "Input first port:"
	read udp_port1
	if [ $udp_port1 = "exit" ]; then
		break
	fi
	ufw allow $udp_port1/udp
	echo "Input second port(only for ranges):"
	read udp_port2
	if [ $udp_port2 ]; then
		ufw allow $udp_port1:$udp_port2/udp
	fi
done

#7)Allowing/denying traffic from conrete IP addresses

echo "ALLOWING/DENYING TRAFFIC FROM CONCRETE IP-ADDRESSES/NETS"
echo "1.CHOOSE allow/deny"
echo "2.PICK ip-address(or net - 203.0.113.0/24)"
echo "3.CHOOSE port(which will be blocked only)- OPTIONAL"
echo "P.S. Print exit in the type of rule  if you wanna stop the process"

while [ true ]; do
	echo "Choose allow/deny/exit"
	read type_of_rule
	if [ $type_of_rule = "exit" ]; then
		break
	fi
	echo "Set ip-address/net"
	read ip
	echo "Set port(optional)"
	read port
	if [ $port ]; then
		ufw $type_of_rule from $ip to any port $port
	else
		ufw $type_of_rule from $ip
	fi
done

#8)Allowing/denying traffic for concrete NETWORK INTERFACES

function set_ufw_rules_for_interfaces {
	echo "ALLOWING/DENYING TRAFFIC FOR SPECIFIC INTERFACES"
	echo "1.Choose the action - allow/deny/exit"
	echo "2.Choose name of the network interface(like en3p0s...)"
	echo "3.Choose port number which the rule will be applied to"
	echo "P.S. Print exit if you wanna skip that"

	ip a

	#input's data
	echo "Choose the type of rule"
	read type_of_interface_rule
	echo "Input the name of network interface:"
	read interface
	echo "Input the specific port:"
	read interface_port
	
	#managing rules
	ufw $type_of_interface_rule in on $interface to any port $interface_port
}

#Call of the function with interfaces
while [ true ]; do
	echo "Do you need to set additional rules for network interfaces?(y/n)"
	read answer
	if [ $answer = "n" ]; then
		break
	fi
	set_ufw_rules_for_interfaces
done

#9)FINAL CHECK OF TOTAL LIST OF RULES + THEIR DELETION IF NECESSARY

function delete_rule {
	ufw enable
	echo "HERE IS A LIST OF YOUR UFW-firewall RULES?"
	ufw status numbered
	echo "Input the number of rule which must be deleted?"
	read number_of_rule
	ufw -f delete $number_of_rule
}

while [ true ]; do
	ufw enable
	ufw status numbered
	echo "Do you wish to delete any rules?(y/n)"
	read del_ack
	if [ $del_ack = "n" ]; then
		break
	else
		delete_rule
	fi
done
