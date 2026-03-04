#!/bin/bash
set -euo pipefail

# disable password auth and enable ssh auth
setupSshAuth() {
  echo "PubkeyAuthentication yes" | sudo tee -a /etc/ssh/sshd_config
  echo "PasswordAuthentication no" | sudo tee -a /etc/ssh/sshd_config
}

if [[ "$(uname -a)" == "Linux raspberry"* || "$(cat /proc/device-tree/model)" == "Raspberry Pi"* ]]; then
  echo "This is a raspberry pi, continue setup"
else
  # https://tldp.org/LDP/abs/html/exitcodes.html
  echo "This is not a raspberry pi"
  exit 2
fi

echo "updating and fixing locale..."
export LANGUAGE=en_GB.UTF-8
export LANG=en_GB.UTF-8
export LC_ALL=en_GB.UTF-8
sudo locale-gen en_GB.UTF-8

echo "'apt update and apt upgrade'ing..."
sudo apt update -y
sudo apt upgrade -y

echo "Do you want to install oh-my-zsh (manual step can be found in https://www.seeedstudio.com/blog/2020/03/06/prettify-raspberry-pi-shell-with-oh-my-zsh/) [y/N]:"
read -r zsh_option
if [ "$zsh_option" = "y" ] || [ "$zsh_option" = "Y" ]; then
  echo "Installing git..."
  sudo apt-get install git -y
  echo "Installing zsh..."
  sudo apt-get install zsh -y
  echo "Installing oh-my-zsh"
  export ZSH="$HOME/.oh-my-zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
  if [ -d "$HOME/.oh-my-zsh" ]; then
    ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    if [ -f "$HOME/.zshrc" ] && ! grep -q "zsh-autosuggestions" "$HOME/.zshrc" 2>/dev/null; then
      echo "plugins=(git zsh-autosuggestions autojump zsh-syntax-highlighting)" >> "$HOME/.zshrc"
    fi
  fi
else
  echo "oh-my-zsh is skipped!"
fi

echo "Do you want to install docker and docker-compose [y/N]:"
read -r docker_option
if [ "$docker_option" = "y" ] || [ "$docker_option" = "Y" ]; then
  echo "Installing docker and docker-compose..."
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker "${USER}"

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
read -r email
# https://stackoverflow.com/a/30712224
echo | ssh-keygen -t rsa -b 4096 -C "$email" -P ''
echo "public ssh key is:"
cat ~/.ssh/id_rsa.pub

echo "Do you want to enable SSH authentication with key [y/N]:"
read -r option
if [ "$option" = "y" ] || [ "$option" = "Y" ]; then
  setupSshAuth
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
  echo "Insert key:"
  read -r key
  echo "$key" > ~/.ssh/authorized_keys
  chmod 600 ~/.ssh/authorized_keys
  while [ "$option" = "y" ] || [ "$option" = "Y" ]; do
    option="N"
    echo "Do you want add one more key [y/N]"
    read -r option
    if [ "$option" = "y" ] || [ "$option" = "Y" ]; then
      echo "Insert key:"
      read -r key
      echo "$key" >> ~/.ssh/authorized_keys
      chmod 600 ~/.ssh/authorized_keys
    fi
  done
else
  echo "SSH authentication is skipped!"
fi

echo "Restart ssh"
sudo systemctl restart sshd
current_hostname=$(hostname 2>/dev/null || echo "")
if [ "$current_hostname" = "raspberrypi" ] || [ "$current_hostname" = "raspberry" ]; then
  echo "Insert server name:"
  read -r servername
  echo "Updating server name to $servername"
  echo "$servername" | sudo tee /etc/hostname >/dev/null
  sudo sed -i "s/$current_hostname/$servername/g" /etc/hosts
else
  echo "Hostname already changed, skip change server name"
fi

if command -v zsh >/dev/null 2>&1; then
  echo "set zsh as default (requires user password)"
  chsh -s /bin/zsh
fi

echo "Please confirm that you can login and then reboot!"

exit 0
