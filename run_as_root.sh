#!/bin/bash
apt-get update -y && apt-get upgrade -y
apt-get install sudo openssh-server ufw portsentry fail2ban apache2 mailutils git -y
git clone <url to git> ./roger
rm -rf /etc/sudoers
cp roger/assets/sudo/sudoers /etc/