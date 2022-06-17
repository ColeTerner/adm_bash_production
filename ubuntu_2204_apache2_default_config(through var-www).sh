								#APACHE CONFIG
#1)Updating Linux packages before the installation APACHE

echo "1.UPGRADING LINUX PACKAGES..."
sudo apt update
sudo apt -y upgrade

#2)Installing APACHE2

echo "2.INSTALLING APACHE2..."
sudo apt install apache2 -y

#3)Setting UFW firewall

echo "3.SETTING UFW-firewall RULES..."
sudo ufw enable
sudo ufw app list
sudo ufw allow 'Apache Full'
sudo ufw status verbose

#4)Creating virtual host( setting's profile of apache for your domain) instead of the default one

echo "4.CREATING VIRTUAL HOST(config profile for your domain)..."

echo "Input your desirable domain name?(like uraic.ru...)"
read domain_name
cd /var/www
sudo mkdir -p /var/www/$domain_name
sudo chown -R www-data:www-data /var/www/$domain_name

#5)Creating test index.html(tested starting page of the web-server apache)

echo "5.CREATING index.html - tested starting page of APACHE2..."

sudo touch /var/www/$domain_name/index.html

#editing file
arr=('<html>' '	<head>' '	<title>Welcome to TESTING_PAGE</title>' ' <head>' ' <body>' '		<h1>Success! The tutorial server block is working!</h1>' ' </body>' '</html>' )
arr_elements=${#arr[@]}

for (( i=0;i<$arr_elements;i++ )); do
	echo ${arr[${i}]} | sudo tee -a /var/www/$domain_name/index.html
done


#6)Creating  config file for virtual host of your domain

echo "6.CREATING CONFIG APACHE2 FOR YOUR DOMAIN PROFILE..."

sudo touch /etc/apache2/sites-available/$domain_name.conf

arr=("<VirtualHost *:80>" "	ServerAdmin webmaster@localhost" "	ServerName $domain_name" "	ServerAlias www.$domain_name" "		DocumentRoot /var/www/$domain_name" "	ErrorLog ${APACHE_LOG_DIR}/error.log" "	CustomLog ${APACHE_LOG_DIR}/access.log combined" "</VirtualHost>")
arr_elems=${#arr[@]}

for (( i=0;i<$arr_elems;i++ )); do
	echo ${arr[${i}]} | sudo tee -a /etc/apache2/sites-available/$domain_name.conf
done


#7)Enabling virtual host(your personal config)

echo "7.ENABLING YOUR PERSONAL CONFIG(virtual host..."

sudo a2dissite 000-default.conf - #disabling the default one
sudo apache2ctl configtest
sudo a2ensite $domain_name.conf

#8)Restarting apache2 service

echo "8.RESTARTING APACHE2 service..."

systemctl restart apache2


#8)Setting ACLs on files of the webserver - inside the /var/www/<domain name>

sudo find /var/www/$domain_name/ -type d -exec chmod 755 "{}" \;	#subdirectories rights
sudo find /var/www/$domain_name/ -type f -exec chmod 644 "{}" \;	#subfiles rights


