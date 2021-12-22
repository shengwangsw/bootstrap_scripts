#!/bin/sh

TO_INSTALL="git ssh zsh curl tmux rust vim"

# ohmyzsh
ohmyzshAndTmux() {
  # install ohmyzsh
  if ! which zsh &> /dev/null; then
    echo "zsh is not installed"
  else
    if [ -f "~/.oh-my-zsh" ]; then
      echo "ohmyzsh is already installed"
    else
      echo "Configuring ohmyzsh..."
      sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
      # intall Powerlevel10k for font
      git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
      mv ~/powerlevel10k ~/.powerlevel10k
      echo 'source ~/.powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc

      # update ohmyzsh
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
    fi
  fi

  # install tmux
  if ! which tmux &> /dev/null; then
    echo "tmux is not installed!"
  else
    if [ -f "~/.tmux" ]; then
      echo "tmux is already installed"
    else
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
    fi
  fi
}

# MacOS
macos()
{
  echo “Detect Mac OS”
  # install homebew
  if ! which brew &> /dev/null; then
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo “homebrew already installed”
  fi
  # new update and upgrade
  echo "Updating and upgrading..."
  brew update
  brew upgrade
  
  # install git and ssh
  for val in $TO_INSTALL; do
    # command -v or which 
    if ! which $val &> /dev/null; then
      brew install $val
      # outdated: brew install --build-from-source tmux
    else
      echo “$val already installed”
    fi
  done

  # configure
  ohmyzshAndTmux

  # install vscode
  if ! which code &> /dev/null; then
    brew install --cask visual-studio-code
  else
    echo "vscode already installed"
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

  # install git and ssh
  for val in $TO_INSTALL; do
    # command -v or which
    if ! which $val &> /dev/null; then
      sudo apt-get install $val -y
    else
      echo “$val already installed”
    fi
  done

  # configure to use vi
  echo "use vi on git commit"
  git config --global core.editor "vi"

  # configure
  ohmyzshAndTmux

  # install vscode
  if ! which code &> /dev/null; then
    sudo snap install --classic code
  else
    echo "vscode already installed"
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
