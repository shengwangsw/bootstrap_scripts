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
fi

echo "updating and fixing locale..."
export LANGUAGE=en_GB.UTF-8
export LANG=en_GB.UTF-8
export LC_ALL=en_GB.UTF-8
sudo locale-gen en_GB.UTF-8

echo "'apt udpate and apt upgrade'ing..."
sudo apt update -y > /dev/null 2>&1
sudo apt upgrade -y > /dev/null 2>&1

echo "Installing git..."
sudo apt-get install git -y

echo "Do you want to install oh-my-zsh (manual step can be found in https://www.seeedstudio.com/blog/2020/03/06/prettify-raspberry-pi-shell-with-oh-my-zsh/) [y/N]:"
read zsh_option
if [ "$zsh_option" = "y" ] || [ "$zsh_option" = "Y" ]; then
  echo "Installing zsh..."
  sudo apt-get install zsh -y
  echo "Installing oh-my-zsh"
  sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
  git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  echo "plugins=(git zsh-autosuggestions autojump zsh-syntax-highlighting)" >> ~/.zshrc
else
  echo "oh-my-zsh is skipped!"
fi

echo "Do you want to install docker and docker-compose [y/N]:"
read docker_option
if [ "$docker_option" = "y" ] || [ "$docker_option" = "Y" ]; then
echo "Installing docker and docker-compose..."
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker ${USER}

sudo apt-get install -y libffi-dev libssl-dev
sudo apt install -y python3-dev
sudo apt-get install -y python3 python3-pip

sudo pip3 install docker-compose

echo "Enabling docker as start at the bootstrap..."
sudo systemctl enable docker
else
  echo "Docker is skipped!"
fi

echo "Insert email for ssh key:"
read email
# https://stackoverflow.com/a/30712224
echo | ssh-keygen -t rsa -b 4096 -C "$email" -P ''
echo "public ssh key is:"
cat ~/.ssh/id_rsa.pub

echo "Do you want to enable SSH authentication with key [y/N]:"
read option
if [ "$option" = "y" ] || [ "$option" = "Y" ]; then
  setupSshAuth
  echo "Insert key:"
  read key
  echo "$key" > ~/.ssh/authorized_keys
  while [ "$option" = "y" ] || [ "$option" = "Y" ]; do
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
if [ "$(grep "raspberry" /etc/hosts)" ] \
&& [ "$(grep "raspberry" /etc/hostname)" ]; then
  # server name need to be changed at the end, otherwise, apt won't work
  echo "Insert server name:"
  read servername
  echo "Updating server name to $servername"
  sudo sed -i "s/raspberry/$servername/g" '/etc/hostname'
  sudo sed -i "s/raspberry/$servername/g" '/etc/hosts'
else
  echo "/etc/hosts or /etc/hostname was changed, skip change server name"
fi

if which zsh &> /dev/null; then
  echo "set zsh as default (requires user password)"
  chsh -s /bin/zsh
fi

echo "Please confirm that you can login and then reboot!"

exit 0
