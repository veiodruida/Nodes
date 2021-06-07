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
		echo 'export BITCOUNTRY_NODENAME="'${BITCOUNTRY_NODENAME}' | Nodes_Satana"' >> $HOME/.bash_profile
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
	git clone https://github.com/bit-country/Bit-Country-Blockchain.git
	cd Bit-Country-Blockchain
	git checkout bfece87795f3b4bd4be225989af2ed717fbf9f8c
	./scripts/init.sh
	cargo build --release --features=with-bitcountry-runtime
}

function installService {
echo -e '\n\e[42mRunning\e[0m\n' && sleep 1
echo -e '\n\e[42mCreating a service\e[0m\n' && sleep 1

echo "[Unit]
Description=Bit.Country Node
After=network.target
[Service]
User=root
WorkingDirectory=$HOME
ExecStart=$HOME/Bit-Country-Blockchain/target/release/bitcountry-node --chain tewai --validator --name '${BITCOUNTRY_NODENAME}' --bootnodes /ip4/13.239.118.231/tcp/30344/p2p/12D3KooW9rDqyS5S5F6oGHYsmFjSdZdX6HAbTD88rPfxYfoXJdNU --telemetry-url 'wss://telemetry.polkadot.io/submit/ 0' --pruning archive
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
" > $HOME/bitcountryd.service
sudo mv $HOME/bitcountryd.service /etc/systemd/system
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
echo -e '\n\e[42mRunning a service\e[0m\n' && sleep 1
sudo systemctl enable bitcountryd
sudo systemctl restart bitcountryd

echo -e '\n\e[42mCheck node status\e[0m\n' && sleep 1
if [[ `service bitcountryd status | grep active` =~ "running" ]]; then
  echo -e "Your BitCountry node \e[32minstalled and works\e[39m!"
  echo -e "You can check node status by the command \e[7mservice bitcountryd status\e[0m"
  echo -e "Press \e[7mQ\e[0m for exit from status menu"
else
  echo -e "Your BitCountry node \e[31mwas not installed correctly\e[39m, please reinstall."
fi
. $HOME/.bash_profile
}

function deleteBitcountry {
	sudo systemctl disable bitcountryd
	sudo systemctl stop bitcountryd
}

PS3='Please enter your choice (input your option number and press enter): '
options=("Install" "Upgrade" "Delete" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Install")
            echo -e '\n\e[42mYou choose install...\e[0m\n' && sleep 1
			setupVars
			setupSwap
			installDeps
			installSoftware
			installService
			break
            ;;
        "Upgrade")
            echo -e '\n\e[33mYou choose upgrade...\e[0m\n' && sleep 1
			installSoftware
			installService
			echo -e '\n\e[33mYour node was upgraded!\e[0m\n' && sleep 1
			break
            ;;
		"Delete")
            echo -e '\n\e[31mYou choose delete...\e[0m\n' && sleep 1
			deleteBitcountry
			echo -e '\n\e[42mBITCOUNTRY was deleted!\e[0m\n' && sleep 1
			break
            ;;
        "Quit")
            break
            ;;
        *) echo -e "\e[91minvalid option $REPLY\e[0m";;
    esac
done