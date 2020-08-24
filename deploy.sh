#!/bin/bash

apt-get update -y && apt-get upgrade -y
apt-get install cron sudo openssh-server ufw portsentry fail2ban apache2 mailutils -y
usermod -aG sudo seronen

#Configuring Static IP Addr

cp ~/roger/assets/static_ip/interfaces /etc/network/interfaces

#Configuing SSH
rm -rf /etc/ssh/sshd_config
cp ~/roger/assets/ssh/sshd_config /etc/ssh/
sudo mkdir /home/seronen/.ssh/
sudo cat ~/roger/assets/ssh/authorized_keys > /home/seronen/.ssh/

sudo service ssh restart
sudo service sshd restart
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
sudo service sshd restart
sudo service ssh restart

#Disable services not needed
sudo systemctl disable console-setup.service
sudo systemctl disable keyboard-setup.service
sudo systemctl disable apt-daily.timer
sudo systemctl disable apt-daily-upgrade.timer
sudo systemctl disable syslog.service

