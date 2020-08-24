#!/bin/bash

#Configuing SSH
rm -rf /etc/ssh/sshd_config
cp roger/assets/sshd/sshd_config /etc/ssh/
sudo mkdir /home/seronen/.ssh/
sudo mkdir /home/seronen/.ssh/authorized_keys
sudo mv ~/roger/assets/ssh/id_rsa.pub > /home/seronen/.ssh/authorized_keys

sudo service ssh restart
sudo service sshd restart
sudo service networking restart
sudo ifup enp0s3

#Fail2Ban setup
cp ~/roger/assets/fail2ban/jail.local /etc/fail2ban/jail.local
cp ~/roger/assets/fail2ban/http-sget-dos.conf /etc/fail2ban/filter.d
cp ~/roger/assets/fail2ban/portscan.conf /etc/fail2ban/filter.d
sudo service fail2ban restart

#Firewall: UFW setup
sudo ufw enable
sudo ufw allow 50683/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw reload
sudo ssh service sshd restart

#Disable services not needed
sudo systemctl disable console-setup.service
sudo systemctl disable keyboard-setup.service
sudo systemctl disable apt-daily.timer
sudo systemctl disable apt-daily-upgrade.timer
sudo systemctl disable syslog.service

