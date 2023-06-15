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
echo export CHAIN_ID="sao-testnet1" >> $HOME/.bash_profile
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
git clone https://github.com/SaoNetwork/sao-consensus.git
cd sao-consensus
git checkout v0.1.6
make install

saod init $NODENAME --chain-id $CHAIN_ID
cd $HOME/.sao/config
curl -s https://raw.githubusercontent.com/SAONetwork/sao-consensus/testnet0/network/testnet0/config/genesis.json > ~/.sao/config/genesis.json
wget -O $HOME/.sao/config/addrbook.json "https://raw.githubusercontent.com/GalaxyNode/Testnets-guides/main/SAO/addrbook.json"



sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0sao\"/;" ~/.sao/config/app.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/.sao/config/config.toml
external_address=$(wget -qO- eth0.me)
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:26656\"/" $HOME/.sao/config/config.toml
peers="08d8f8ae761177ecf95159281d08bca622c7e578@sao-testnet-peer.itrocket.net:19656,4fa89d8492cdef5b7f887c4002b3df70d1283063@65.21.134.202:15756,1667f1737eca69c487c114a03c0a058dd9cf8c02@194.163.168.62:19656,8ea46db77d6698c2e9509a5dd9ca4436436676cc@43.156.118.116:26656,028d522954c744b095fea1b9f1f475509b82d700@8.222.210.19:26656,d99aa1b6ab12faaee47ab1f8bfa59187b0bab588@65.109.89.18:19656,4db9aa492b13137d048af1ac554e8a6c09f80fcf@75.119.154.212:26656,195eb1c0b2b6c52f690cb9500bbc93c855616d50@120.226.39.104:26656,8a6983c4b3402c0a25c110eee8a9d0ca369b45c9@65.21.131.215:15756,4b05fcf7f3bb8766a7a7f9838cb13f4e8fbdfaeb@207.180.251.220:17656,5b1a021a6ed3274dc2c855490ad8fe45e03ace99@65.108.75.107:21656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.sao/config/config.toml
seeds="4e6df8dcc080b8c73929fc513443ecd5e0a424f0@sao-testnet-seed.itrocket.net:19656"
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.sao/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 100/g' $HOME/.sao/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 100/g' $HOME/.sao/config/config.toml



# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.sao/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.sao/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.sao/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.sao/config/app.toml
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.sao/config/config.toml


sudo tee /etc/systemd/system/saod.service > /dev/null <<EOF
[Unit]
Description=saod
After=network-online.target
[Service]
User=$USER
ExecStart=$(which saod) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF


# start service
sudo systemctl daemon-reload
sudo systemctl enable saod
sudo systemctl restart saod

echo '=============== SETUP FINISHED ==================='
echo -e 'Congratulations:        \e[1m\e[32mSUCCESSFUL NODE INSTALLATION\e[0m'
echo -e 'To check logs:        \e[1m\e[33mjournalctl -u saod -f -o cat\e[0m'
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
saod keys add $Wallet
echo -e "Save your mnemonic phrase"

break
;;
"Check node logs")
sudo journalctl -u saod -f -o cat

break
;;
"Delete Node")
sudo systemctl stop saod && \
sudo systemctl disable saod && \
rm /etc/systemd/system/saod.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf sao && \
rm -rf .sao && \
rm -rf $(which saod)

break
;;
"Exit")
exit
esac
done
done