#!/bin/bash

while true
do

# Menu

PS3='Select an action: '
options=(
"Install Node"
"Create wallet"
"Check node logs"
"Delete Node"
"Exit")
select opt in "${options[@]}"
do
case $opt in

"Install Node")
echo "============================================================"
echo "Install start"
echo "============================================================"
echo "Setup NodeName:"
echo "============================================================"
read NODENAME
echo "============================================================"
echo export NODENAME=${NODENAME} >> $HOME/.bash_profile
echo export CHAIN_ID="froopyland_100-1" >> $HOME/.bash_profile
source ~/.bash_profile

#UPDATE APT
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev libleveldb-dev jq build-essential bsdmainutils git make ncdu htop screen unzip bc fail2ban htop -y

#INSTALL GO
ver="1.19" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile && \
go version

#INSTALL
cd $HOME
ggit clone https://github.com/dymensionxyz/dymension.git --branch v1.0.2-beta
cd dymension
make install

dymd init $NODENAME --chain-id $CHAIN_ID
cd $HOME/.Dymension/config
curl -s https://raw.githubusercontent.com/dymensionxyz/testnets/main/dymension-hub/froopyland/genesis.json > ~/.Dymension/config/genesis.json
wget -O $HOME/.Dymension/config/addrbook.json "https://raw.githubusercontent.com/GalaxyNode/Testnets-guides/main/Dymension/addrbook.json"



sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0udym\"/;" ~/.Dymension/config/app.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/.Dymension/config/config.toml
external_address=$(wget -qO- eth0.me)
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:26656\"/" $HOME/.Dymension/config/config.toml
peers="e7857b8ed09bd0101af72e30425555efa8f4a242@148.251.177.108:20556,3410e9bc9c429d6f35e868840f6b7a0ccb29020b@46.4.5.45:20556"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.Dymension/config/config.toml
seeds="ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@testnet-seeds.polkachu.com:20556"
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.Dymension/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 100/g' $HOME/.Dymension/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 100/g' $HOME/.Dymension/config/config.toml



# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.Dymension/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.Dymension/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.Dymension/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.Dymension/config/app.toml
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.Dymension/config/config.toml


sudo tee /etc/systemd/system/dymd.service > /dev/null <<EOF
[Unit]
Description=dymd
After=network-online.target
[Service]
User=$USER
ExecStart=$(which dymd) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF


# start service
sudo systemctl daemon-reload
sudo systemctl enable dymd
sudo systemctl restart dymd

echo '=============== SETUP FINISHED ==================='
echo -e 'Congratulations:        \e[1m\e[32mSUCCESSFUL NODE INSTALLATION\e[0m'
echo -e 'To check logs:        \e[1m\e[33mjournalctl -u dymd -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[35mcurl -s localhost:26657/status\e[0m"

break
;;
"Create wallet")
echo "========================================================================================================================"
echo -e "Your wallet name"
echo "========================================================================================================================"
read Wallet
echo export Wallet=${Wallet} >> $HOME/.bash_profile
source ~/.bash_profile
dymd keys add $Wallet
echo -e "Save your mnemonic phrase"

break
;;
"Check node logs")
sudo journalctl -u dymd -f -o cat

break
;;
"Delete Node")
sudo systemctl stop dymd && \
sudo systemctl disable dymd && \
rm /etc/systemd/system/dymd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf dymension && \
rm -rf .dymension && \
rm -rf $(which dymd)

break
;;
"Exit")
exit
esac
done
done