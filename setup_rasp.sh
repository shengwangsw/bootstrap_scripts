#!/bin/bash

# disable password auth and enable ssh auth
setupSshAuth() {
  echo "PubkeyAuthentication yes" | sudo tee -a /etc/ssh/sshd_config
  echo "PasswordAuthentication no" | sudo tee -a /etc/ssh/sshd_config
}

if [[ "$(uname -a)" != "Linux raspberry"* ]]; then
  # https://tldp.org/LDP/abs/html/exitcodes.html
  echo "This is not a raspbian"
  exit 2
elif [ "$(cat /etc/hosts | grep raspberrypi)" = "raspberrypi" ] \
&& [ "$(cat /etc/hostname | grep raspberrypi)" = *"raspberrypi" ]; then
  echo "Make sure that you didn't change /etc/hosts or /etc/hostname"
  exit 2
fi

echo "updating and fixing locale..."
export LANGUAGE=en_GB.UTF-8
export LANG=en_GB.UTF-8
export LC_ALL=en_GB.UTF-8
sudo locale-gen en_GB.UTF-8

echo "'apt udpate and apt upgrade'ing..."
sudo apt update -y > /dev/null 2>&1
sudo apt upgrade -y > /dev/null 2>&1

echo "installing git..."
sudo apt-get install git -y

echo "Installing docker and docker-compose..."
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker ${USER}

sudo apt-get install -y libffi-dev libssl-dev
sudo apt install -y python3-dev
sudo apt-get install -y python3 python3-pip

sudo pip3 install docker-compose

echo "Enabling docker as start at the bootstrap..."
sudo systemctl enable docker

echo "Insert email for ssh key:"
read email
# https://stackoverflow.com/a/30712224
echo | ssh-keygen -t rsa -b 4096 -C "$email" -P ''
echo "public ssh key is:"
cat ~/.ssh/id_rsa.pub

echo "Do you want to enable SSH authentication with key [y/N]:"
read option
if [ "$option" = "y" ] || [ "&option" = "Y" ]; then
  setupSshAuth
  echo "Insert key:"
  read key
  echo "$key" > ~/.ssh/authorized_keys
  while [ "$option" = "y" ] || [ "&option" = "Y" ]; do
    option="N"
    echo "Do you want add one more key [y/N]"
    read option
    echo "Insert key:"
    read key
    echo "$key" >> ~/.ssh/authorized_keys 
  done
else
  echo "SSH authentication is skipped!"
fi

echo "Restart ssh"
sudo systemctl restart sshd

# server name need to be changed at the end, otherwise, apt won't work
echo "Insert server name:"
read servername
sudo sed -i "s/raspberrypi/$servername/g" '/etc/hostname'
sudo sed -i "s/raspberrypi/$servername/g" '/etc/hosts'

echo "Please confirm that you can login and then reboot!"

exit 0
