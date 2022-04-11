#!/bin/sh

TO_INSTALL="git ssh gpg zsh curl tmux vim"

# ohmyzsh
ohmyzshAndTmux() {
  # install ohmyzsh if zsh is installed
  if hash zsh 2> /dev/null; then
    # if ~/.oh-my-zsh does not exist, then we assume that it is not configured
    if [ -f "~/.oh-my-zsh" ]; then
      echo "Do you want to install oh-my-zsh [y/N]:"
      read zsh_option
      if [ "$zsh_option" = "y" ] || [ "$zsh_option" = "Y" ]; then
        echo "Configuring ohmyzsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

        # intall Powerlevel10k for font
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
        mv ~/powerlevel10k ~/.powerlevel10k
        echo 'source ~/.powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc

        # set theme to agnoster
        sed 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' ~/.zshrc
        if grep -q "ZSH_THEME=\"robbyrussell\"" ~/.zshrc; then
          sed 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' ~/.zshrc > zshrc.txt
          cp zshrc.txt ~/.zshrc
          rm zshrc.txt
        else 
          echo "failed updating zsh theme, not existing line: ZSH_THEME=\"robbyrussell\""
        fi
        # permission issues https://github.com/ohmyzsh/ohmyzsh/issues/6835#issuecomment-390216875
        echo "skip fixing permission issues..."
        #echo "ZSH_DISABLE_COMPFIX=true" >> ~/.zshrc
        # TODO the variable must be before oh-my-zsh.sh is sourced.
      else
        echo "Skip to configure ohmyzsh"
      fi
    else
      echo "ohmyzsh is already installed and configured"
    fi
  else
    echo "zsh hadn't been installed! Skip configuration"
  fi

  # configure tmux if tmux is installed 
  if hash tmux 2> /dev/null; then
    # if ~/.tmux does not exist, then we assume that it is not configured
    if [ -f "~/.tmux" ]; then
      echo "Do you want to configure tmux [y/N]:"
      read tmux_option
      if [ "$tmux_option" = "y" ] || [ "$tmux_option" = "Y" ]; then
        echo "Configuring tmux..."
        git clone https://github.com/samoshkin/tmux-config.git
        ./tmux-config/install.sh

        # remove the project
        rm -rf tmux-config

        # fix bug (add backslash before {, } and \)
        if grep -q "unbind }    # swap-pane -D" ~/.tmux.conf; then
          sed 's/unbind }    # swap-pane -D/unbind \\}    # swap-pane -D/g' ~/.tmux.conf > tmux.txt
          cp tmux.txt ~/.tmux.conf
          rm tmux.txt
        else 
          echo "failed fixing, not existing line: unbind }    # swap-pane -D"
        fi
        if grep -q "unbind {    # swap-pane -U" ~/.tmux.conf; then
          sed 's/unbind {    # swap-pane -U/unbind \\{    # swap-pane -U/g' ~/.tmux.conf > tmux.txt
          cp tmux.txt ~/.tmux.conf
          rm tmux.txt
        else 
          echo "failed fixing, not existing line: unbind {    # swap-pane -U"
        fi
        if grep -q "bind \\\\ if" ~/.tmux.conf; then
          sed 's/bind \\ if/bind \\\\ if/g' ~/.tmux.conf > tmux.txt
          cp tmux.txt ~/.tmux.conf
          rm tmux.txt
        else 
          echo "failed fixing, not existing line: bind \\ if"
        fi
      else
        echo "Skip to configure tmux"
      fi
    else
      echo "tmux is already installed and configured"
    fi
  else
    echo "tmux hadn't been installed! Skip configuration"
  fi
}

# configure git
setup_git()
{
  if hash git 2> /dev/null; then
    echo "use vim on git commit"
    git config --global core.editor "vim"
    echo "Write here your git username:"
    read git_username
    git config --global user.name "$git_username"
    echo "Check your git username by executing: git config --global user.name"
    echo "Write here your git email:"
    read git_email
    git config --global user.email "$git_email"
    echo "Check your git email by executing: git config --global user.email"

    # setting up ssh key pair
    if hash ssh-keygen 2> /dev/null; then
      echo "Do you want to setup ssh keypair? [y/N]"
      read ssh_keypair
      if [ "$ssh_keypair" = "y" ] || [ "$ssh_keypair" = "Y" ]; then
        ssh-keygen -t rsa
        echo "Write here the path to your public key [e.g. ~/.ssh/id_rsa.pub]"
        read ssh_pub_key
        echo "copy the ssh public key to your git profile."
        cat "$ssh_pub_key"
        read -p "Press enter to continue"
        read to_continue
      else
        echo "skip setting up ssh key pair"
      fi
    else
      echo "ssh-keygen isn't installed"
    fi
    
    # setting up pgp key pair
    if hash gpg 2> /dev/null; then
      echo "Do you want to setup pgp keypair? [y/N]"
      read pgp_keypair
      if [ "$pgp_keypair" = "y" ] || [ "$pgp_keypair" = "Y" ]; then
        gpg --full-gen-key
        raw_signing_key=$(gpg --list-secret-keys --keyid-format LONG)
        pattern='sec.*\/([a-zA-Z0-9]+).*'
        [[ "$raw_signing_key" =~ $pattern ]]
        signingkey=${BASH_REMATCH[1]};
        gpg --export --armor "$signingkey"
        echo "copy the pgp public key to your git profile."
        read -p "Press enter to continue"
        read to_continue

        # setup in local machine
        git config --global user.signingkey "$signingkey"
        git config --global commit.gpgSign true
        git config --global tag.gpgSign true
      else
        echo "skip setting up pgp key pair"
      fi
    else
      echo "gpg isn't installed"
    fi

  else
    echo "git is not installed. Skip configuring git."
  fi
}

# MacOS
macos()
{
  echo “Detect Mac OS”
  # install homebew if it is not already installed
  if hash brew 2> /dev/null; then
    echo "homebrew already installed"
  else
    # usually curl is installed by default in MacOS
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    echo "At the end of installation you should received next steps:"
    echo "1. add line to profile file:"
    echo "    echo 'eval \"$(/opt/homebrew/bin/brew shellenv)\"' >> <path to profile file>"
    echo "2. evaluate the brew shellenv:"
    echo "    eval \"$(/opt/homebrew/bin/brew shellenv)\""
    echo "Did you received the above steps? [y/N]"
    read brew_steps
    if [ "$brew_steps" = "y" ] || [ "$brew_steps" = "Y" ]; then
      echo "Write here the <path to profile file>:"
      read profile_file_path
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$profile_file_path"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      echo "Do you want to exit the setup so you can do it manually? [y/N]"
      read do_it_manually
      if [ "$do_it_manually" = "y" ] || [ "$do_it_manually" = "Y" ]; then
        exit 0;
      fi
    fi
  fi
  # new update and upgrade
  echo "Updating and upgrading..."
  brew update
  brew upgrade
  
  for val in $TO_INSTALL; do
    if hash $val 2> /dev/null; then
      echo "$val already installed"
    else
      echo "Do you want to install $val [y/N]:"
      read val_option
      if [ "$val_option" = "y" ] || [ "$val_option" = "Y" ]; then
        brew install $val
      else
        echo "Skip to install $val"
      fi
    fi
  done

  # configure
  ohmyzshAndTmux
  setup_git

  # install vscode
  if hash code 2> /dev/null; then
    echo "vscode is already installed"
  else
    brew install --cask visual-studio-code
  fi
  echo "Finished"
}

# linux ubuntu
ubuntu()
{
  echo “Detect Linux Ubuntu”
  # update and upgrade
  echo "Updating and upgrading..."
  sudo apt-get update -y
  sudo apt-get upgrade -y

  for val in $TO_INSTALL; do
    if hash $val 2> /dev/null; then
      echo "$val already installed"
    else
      echo "Do you want to install $val [y/N]:"
      read val_option
      if [ "$val_option" = "y" ] || [ "$val_option" = "Y" ]; then
        sudo apt-get install $val -y
      else
        echo "Skip to install $val"
      fi
    fi
  done

  # configure
  ohmyzshAndTmux
  setup_git

  # install vscode
  if hash code 2> /dev/null; then
    echo "vscode is already installed"
  else
    sudo snap install --classic code
  fi
  echo "Finished"
}

# if macos
if [[ "$OSTYPE" == "darwin"* ]]; then
  macos
  exit 0
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  ubuntu
  exit 0
fi
