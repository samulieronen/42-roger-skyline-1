#!/bin/bash

apt-get install cron sudo openssh-server ufw portsentry fail2ban apache2 mailutils -y
apt-get update -y && apt-get upgrade -y
usermod -aG sudo seronen

#Configuring Static IP Addr

cp ~/roger/assets/static_ip/interfaces /etc/network/interfaces

#Configuing SSH
rm -rf /etc/ssh/sshd_config
cp ~/roger/assets/ssh/sshd_config /etc/ssh/
sudo mkdir /home/seronen/.ssh/
cp ~/roger/assets/ssh/authorized_keys /home/seronen/.ssh/

sudo service ssh restart
sudo service networking restart
sudo ifup eth0

#Fail2Ban setup
cp ~/roger/assets/fail2ban/jail.local /etc/fail2ban/
cp ~/roger/assets/fail2ban/http-get-dos.conf /etc/fail2ban/filter.d
cp ~/roger/assets/fail2ban/portscan.conf /etc/fail2ban/filter.d
sudo service fail2ban restart

#Firewall: UFW setup
sudo ufw enable
sudo ufw allow 50683/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw reload
sudo service ssh restart

#Setup Portsentry for protection against port scanning
rm -rf /etc/default/portsentry
cp ~/roger/assets/portsentry/portsentry /etc/default/
rm -rf /etc/portsentry/portsentry.conf
cp ~/roger/assets/portsentry/portsentry.conf /etc/portsentry/
sudo service portsentry restart

#Disable services not needed
sudo systemctl disable console-setup.service
sudo systemctl disable keyboard-setup.service
sudo systemctl disable apt-daily.timer
sudo systemctl disable apt-daily-upgrade.timer
sudo systemctl disable syslog.service
sudo systemctl disable wpa_supplicant
sudo systemctl disable anacron

#Setup scripts
cp -r ~/roger/assets/scripts/ ~/
cp -r ~/roger/assets/scripts/ /home/seronen/
chmod 755 ~/scripts/update.sh
chmod 755 ~/scripts/cronmonitor.sh
chmod 755 /home/seronen/scripts/update.sh
chmod 755 /home/seronen/scripts/cronmonitor.sh
{ crontab -l -u root; echo '0 4 * * SUN /root/scripts/update.sh'; } | crontab -u root -
{ crontab -l -u root; echo '@reboot sleep 60 && /root/scripts/update.sh'; } | crontab -u root -
{ crontab -l -u root; echo '0 0 * * * /root/scripts/monitor.sh'; } | crontab -u root -
{ crontab -l -u seronen; echo '0 4 * * SUN /home/seronen/scripts/update.sh'; } | crontab -u seronen -
{ crontab -l -u seronen; echo '@reboot sleep 60 && /home/seronen/scripts/update.sh'; } | crontab -u seronen -
{ crontab -l -u seronen; echo '0 0 * * * /home/seronen/scripts/monitor.sh'; } | crontab -u seronen -

#Apache2 setup
sudo systemctl enable apache2
rm -rf /var/www/html/
cp -r ~/roger/assets/apache2/ /var/www/html/

#SSL Setup
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/C=FI/ST=HEL/O=Hive/OU=roger-skyline-1/CN=192.168.1.2" -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt
cp ~/roger/assets/ssl/ssl-params.conf /etc/apache2/conf-available/ssl-params.conf
sudo cp /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf.old
rm /etc/apache2/sites-available/default-ssl.conf
cp ~/roger/assets/ssl/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf
rm /etc/apache2/sites-available/000-default.conf
cp ~/roger/assets/ssl/000-default.conf /etc/apache2/sites-available/000-default.conf
sudo a2enmod ssl
sudo a2enmod headers
sudo a2ensite default-ssl
sudo a2enconf ssl-params
systemctl reload apache2

#Now we should see a beautiful (lol) website! :)