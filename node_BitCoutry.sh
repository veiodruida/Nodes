#!/bin/bash
exists()
{
  command -v "$1" >/dev/null 2>&1
}
if exists curl; then
        echo ''
else
  sudo apt install curl -y < "/dev/null"
fi
bash_profile=$HOME/.bash_profile
if [ -f "$bash_profile" ]; then
    . $HOME/.bash_profile
fi
sleep 1 && curl -s https://api.nodes.guru/logo.sh | bash && sleep 3

function setupVars {
        if [ ! $BITCOUNTRY_NODENAME ]; then
                read -p "Enter node name: " BITCOUNTRY_NODENAME
                echo 'export BITCOUNTRY_NODENAME="'${BITCOUNTRY_NODENAME}' | Nodes_Satana"'  >> $HOME/.bash_profile
        fi
        echo -e '\n\e[42mYour node name:' $BITCOUNTRY_NODENAME '\e[0m\n'
        . $HOME/.bash_profile
        sleep 1
}

function setupSwap {
        echo -e '\n\e[42mSet up swapfile\e[0m\n'
        curl -s https://api.nodes.guru/swap4.sh | bash
}

function installRust {
        echo -e '\n\e[42mInstall Rust\e[0m\n' && sleep 1
        sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
        . $HOME/.cargo/env
}

function installDeps {
        echo -e '\n\e[42mPreparing to install\e[0m\n' && sleep 1
        cd $HOME
        sudo apt update
        sudo apt install cmake make clang pkg-config libssl-dev build-essential git jq libclang-dev -y < "/dev/null"
        installRust
}

function installSoftware {
        echo -e '\n\e[42mInstall software\e[0m\n' && sleep 1
        cd $HOME
