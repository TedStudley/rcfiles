# !/usr/bin/env bash

function main() {
  # Use colors if possible.
  if which tput >/dev/null 2>&1; then
    ncolors=$(tput colors)
  fi
  if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    BOLD="$(tput bold)"
    NORMAL="$(tput sgr0)"
  else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    NORMAL=""
  fi

  # Enable exit-on-error
  set -e

  # Repo from which to pull RCFiles
  if [ -z "$REPO_URI" ]; then
    REPO_URI="https://github.com/TedStudley/rcfiles.git"
  fi

  if [ -z "$RCFILES_DIR" ]; then
    RCFILES_DIR="$HOME/.rcfiles"
  fi

  if [ -d "${RCFILES_DIR}" ]; then
    printf "${YELLOW}You've already bootstrapped RCFiles into '${RCFILES_DIR}'!${NORMAL}\n"
    printf "You'll need to remove the directory if you want to completely reinstall.\n"
    exit
  fi

  printf "${BLUE}Cloning RCFiles...${NORMAL}\n"
  command -v git > /dev/null 2>&1 || {
    echo "Error: git is not installed"
    exit 1
  }

  env git clone --depth=1 "${REPO_URI}" "${RCFILES_DIR}" || {
    echo "${RED}Error: git clone of RCFiles repo failed${NORMAL}\n"
    exit 1
  }

  printf "${BLUE}Installing Oh-My-ZSH...${NORMAL}\n"
  command sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" || {
    echo "${RED}Error: Oh-My-ZSH installation failed${NORMAL}\n"
    exit 1
  }

  printf "${BLUE}Looking for an existing zsh config...${NORMAL}\n"
  if [ -f ~/.zshrc ] || [ -h ~/.zshrc ]; then
    printf "${YELLOW}Found ~/.zshrc.${NORMAL} ${GREEN}Backing up to ~/.zshrc.pre-rcfiles${NORMAL}\n";
    mv ~/.zshrc ~/.zshrc.pre-rcfiles;
  fi

  printf "${BLUE}Using the RCFiles template and adding it to ~/.zshrc${NORMAL}\n"
  cp -f ${RCFILES_DIR}/templates/zshrc ~/.zshrc


  printf "${BLUE}Installing Vundle...${NORMAL}\n"
  env git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim || {
    echo "${RED}Error: git clone of Vundle repo failed${NORMAL}\n"
    exit 1
  }

  printf "${BLUE}Looking for an existing VIM config...${NORMAL}\n"
  if [ -f ~/.vimrc ] || [ -h ~/.vimrc ]; then
    printf "${YELLOW}Found ~/.vimrc.${NORMAL} ${GREEN}Backing up to ~/.vimrc.pre-rcfiles${NORMAL}\n";
    mv ~/.vimrc ~/.vimrc.pre-rcfiles;
  fi

  printf "${BLUE}Using the RCFiles template and adding it to ~/.vimrc${NORMAL}\n"
  cp -f ${RCFILES_DIR}/templates/vimrc ~/.vimrc

  printf "${BLUE}Creating ~/.rcfiles.d for local configuration${NORMAL}\n"
  mkdir -p ~/.rcfiles.d || {
    echo "${RED}Error: unable to create rcfiles local configuration directory${NORMAL}\n"
    exit 1
  }

  exit $current_status
}

main

# vim:ft=sh:
