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
echo export CHAIN_ID="entangle_33133-1" >> $HOME/.bash_profile
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
git clone https://github.com/Entangle-Protocol/entangle-blockchain.git
cd entangle-blockchain
git checkout ce539b81e760a3e75acd7fde9038c21fbe7b7baa
make install

entangled init $NODENAME --chain-id $CHAIN_ID
cd $HOME/.entangle/config
curl -s https://ss-t.entangle.nodestake.top/genesis.json > ~/.entangle/config/genesis.json
wget -O $HOME/.entangle/config/addrbook.json "https://raw.githubusercontent.com/GalaxyNode/Testnets-guides/main/entangle/addrbook.json"



sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0aNGL\"/;" ~/.entangle/config/app.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/.entangle/config/config.toml
external_address=$(wget -qO- eth0.me)
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:26656\"/" $HOME/.entangle/config/config.toml
peers="fe1635c374fad39f2098f615ac0141bd6947738a@64.227.24.223:26656,67eca0ca25a05e2508019224e92613bfd5ed0643@144.126.219.151:20356,9041405fc5bba5971fbe32c00cc923291ce3dfc4@207.180.229.221:26656,522b38535aec49c2f431e960c126f06d171507b0@65.108.141.109:61656,beaaef818c0f36169babf1d52fb514280060e323@134.209.73.245:26656,98019d6208be1bcd6500fa7f68d1b242f7f2c269@95.217.199.12:26604,6ab753ca242b9bb83af3786a94583640355cf1e2@65.109.70.45:11656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.entangle/config/config.toml
seeds=""
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.entangle/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 100/g' $HOME/.entangle/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 100/g' $HOME/.entangle/config/config.toml



# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.entangle/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.entangle/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.entangle/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.entangle/config/app.toml
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.entangle/config/config.toml


sudo tee /etc/systemd/system/entangled.service > /dev/null <<EOF
[Unit]
Description=entangle
After=network-online.target
[Service]
User=$USER
ExecStart=$(which entangled) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF


# start service
sudo systemctl daemon-reload
sudo systemctl enable entangled
sudo systemctl restart entangled

echo '=============== SETUP FINISHED ==================='
echo -e 'Congratulations:        \e[1m\e[32mSUCCESSFUL NODE INSTALLATION\e[0m'
echo -e 'To check logs:        \e[1m\e[33mjournalctl -u entangled -f -o cat\e[0m'
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
entangled keys add $Wallet
echo -e "Save your mnemonic phrase"

break
;;
"Check node logs")
sudo journalctl -u entangled -f -o cat

break
;;
"Delete Node")
sudo systemctl stop entangled && \
sudo systemctl disable entangled && \
rm /etc/systemd/system/entangled.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf entangle && \
rm -rf .entangled && \
rm -rf $(which entangled)

break
;;
"Exit")
exit
esac
done
done