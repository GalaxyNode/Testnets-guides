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
echo export CHAIN_ID="35-C" >> $HOME/.bash_profile
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
git clone https://github.com/dymensionxyz/dymension.git --branch v0.2.0-beta
cd dymension
make install

dymd init $NODENAME --chain-id $CHAIN_ID
cd $HOME/.Dymension/config
curl -s https://raw.githubusercontent.com/obajay/nodes-Guides/main/Dymension/genesis.json > ~/.Dymension/config/genesis.json
wget -O $HOME/.Dymension/config/addrbook.json "https://raw.githubusercontent.com/GalaxyNode/Testnets-guides/main/Dymension/addrbook.json"



sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0udym\"/;" ~/.Dymension/config/app.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/.Dymension/config/config.toml
external_address=$(wget -qO- eth0.me)
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:26656\"/" $HOME/.Dymension/config/config.toml
peers="ebc272824924ea1a27ea3183dd0b9ba713494f83@dymension-testnet-peer.autostake.net:27086,9111fd409e5521470b9b33a46009f5e53c646a0d@178.62.81.245:45656,f8a0d7c7db90c53a989e2341746b88433f47f980@209.182.238.30:30657,1bffcd1690806b5796415ff72f02157ce048bcdd@144.76.67.53:2580,c17a4bcba59a0cbb10b91cd2cee0940c610d26ee@95.217.144.107:20556,e6ea3444ac85302c336000ac036f4d86b97b3d3e@38.146.3.199:20556,b473a649e58b49bc62b557e94d35a2c8c0ee9375@95.214.53.46:36656,db0264c412618949ce3a63cb07328d027e433372@146.19.24.101:26646,281190aa44ca82fb47afe60ba1a8902bae469b2a@dymension.peers.stavr.tech:17806,290ec1fc5cc5667d4e072cf336758d744d291ef1@65.109.104.118:60556,d8b1bcfc123e63b24d0ebf86ab674a0fc5cb3b06@51.159.97.212:26656,55f233c7c4bea21a47d266921ca5fce657f3adf7@168.119.240.200:26656,139340424dddf85e54e0a54179d06875013e1e39@65.109.87.88:24656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.Dymension/config/config.toml
seeds="f97a75fb69d3a5fe893dca7c8d238ccc0bd66a8f@dymension-testnet.seed.brocha.in:30584,ebc272824924ea1a27ea3183dd0b9ba713494f83@dymension-testnet-seed.autostake.net:27086,b78dd0e25e28ec0b43412205f7c6780be8775b43@dym.seed.takeshi.team:10356,babc3f3f7804933265ec9c40ad94f4da8e9e0017@testnet-seed.rhinostake.com:20556,c6cdcc7f8e1a33f864956a8201c304741411f219@3.214.163.125:26656"
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