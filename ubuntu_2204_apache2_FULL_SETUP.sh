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

#Config main directory for your APACHE(requires changing of 2 files - /etc/apache2/apach2.conf and /etc/apache2/sites-available/<domain_name>.conf
echo "Input the FULL PATH of main directory for your APACHE2 server(that will change /etc/apache2/apach2.conf)"
read main_apache_directory
echo "Input root folder of the full path  - like mnt"
read root_folder
echo "Input root subfolder of the full path -like html"
read root_subfolder
echo "Input your desirable domain name?(like uraic.ru...)"
read domain_name
echo "Input your username for controlling apache?"
read $user

cd $main_apache_directory
sudo mkdir -p $main_apache_directory/$domain_name
sudo chown -R $user:$user $main_apache_directory/$domain_name

#5)Creating test index.html(tested starting page of the web-server apache)

echo "5.CREATING index.html - tested starting page of APACHE2..."

sudo touch $main_apache_directory/$domain_name/index.html

#editing file
arr=('<html>' '	<head>' '	<title>Welcome to TESTING_PAGE</title>' ' <head>' ' <body>' '		<h1>Success! The tutorial server block is working!</h1>' ' </body>' '</html>' )
arr_elements=${#arr[@]}

for (( i=0;i<$arr_elements;i++ )); do
	echo ${arr[${i}]} | sudo tee -a $main_apache_directory/$domain_name/index.html
done


#6)Editing the MAIN CONFIG of APACHE2 - /etc/apache2/apache2.conf

echo "6.EDITING the MAIN CONFIG of APACHE2..- /etc/apache2/apache2.conf"

sudo mkdir -p $main_apache_directory	#creating the path

#Replacing string inside the apache config - /etc/apache2/apache2.conf
sudo sed -i "s/var/$root_folder/" /etc/apache2/apache2.conf
sudo sed -i "s/www/$root_subfolder/" /etc/apache2/apache2.conf


#7)Creating your personal virtual host(config profile for your domain) - /etc/apache2/sites-available/<domain_name>.conf

echo "7.CREATING CONFIG APACHE2 FOR YOUR DOMAIN PROFILE...-/etc/apache2/sites-available/<domain_name>.conf"

sudo touch /etc/apache2/sites-available/$domain_name.conf

arr=("<VirtualHost *:80>" "	ServerAdmin webmaster@localhost" "	ServerName $domain_name" "	ServerAlias www.$domain_name" "		DocumentRoot $main_apache_directory/$domain_name" "	ErrorLog ${APACHE_LOG_DIR}/error.log" "	CustomLog ${APACHE_LOG_DIR}/access.log combined" "</VirtualHost>")
arr_elems=${#arr[@]}

for (( i=0;i<$arr_elems;i++ )); do
	echo ${arr[${i}]} | sudo tee -a /etc/apache2/sites-available/$domain_name.conf
done


#8)Enabling virtual host(your personal config)

echo "8.ENABLING YOUR PERSONAL CONFIG(virtual host)..."

sudo a2dissite 000-default.conf - #disabling the default one
sudo apache2ctl configtest
sudo a2ensite $domain_name.conf


#9)Setting ACLs on files of the webserver - inside the /var/www/<domain name>

echo "9.SETTING ACL's right on webserver's folders..."
sudo find $main_apache_directory/$domain_name/ -type d -exec chmod 755 "{}" \;	#subdirectories rights
sudo find $main_apache_directory/$domain_name/ -type f -exec chmod 644 "{}" \;	#subfiles rights


#10)Restarting apache2 service

echo "10.RESTARTING APACHE2 service..."
systemctl restart apache2
