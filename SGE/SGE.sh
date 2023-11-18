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
echo export CHAIN_ID="orbit-alpha-1" >> $HOME/.bash_profile
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
git clone https://github.com/sge-network/sge
git clone https://github.com/sge-network/networks
cd sge
git fetch --tags
git checkout v1.1.0
cd sge
go mod tidy
make install

sged init $NODENAME --chain-id $CHAIN_ID
cd $HOME/.sge/config
curl -s https://raw.githubusercontent.com/sge-network/networks/master/mainnet/sgenet-1/genesis.json > ~/.sge/config/genesis.json
wget -O $HOME/.sge/config/addrbook.json "https://raw.githubusercontent.com/GalaxyNode/Testnets-guides/main/SGE/addrbook.json"



sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0usge\"/;" ~/.sge/config/app.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/.sge/config/config.toml
external_address=$(wget -qO- eth0.me)
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:26656\"/" $HOME/.sge/config/config.toml
peers="05628e99f42eb2fbacfd1f0402f96f46b88dfe6b@146.59.52.137:17756,fe527359b6b6c5ad9cc6e2f6ed3af46018b29e15@136.243.36.60:17756,7258d8c7880167fca502592b8d64110d60e99a6b@65.108.232.180:17756,752bc8c7508affd7e2af494a6bf44bcb66cf84ea@65.108.39.140:17756,88f341a9670494c3d529934dc578eec1b00f4aa1@141.94.168.85:26656,59c71e1ae0267da913d8460c10bbbb86f8003d12@85.10.201.125:36656,6c1cbeb621f04886029c7b222041f7fdb307c579@94.130.14.54:17756,0aa028990c5a135e89447e88daf65a8a590257f4@136.243.67.44:17756,4078d8f702a2ee25c8da93938940748276652696@94.130.13.186:17756,304535618b71c2fe217fe771c745443ea3d7815e@65.108.0.94:17756,ad1dce877d93f9de0d3a5c0b0f28d114242c1d3b@64.185.227.122:17756,8f4ca666d56fc883328b1aa0796342c1c1602099@64.185.226.202:17756,401a4986e78fe74dd7ead9363463ba4c704d8759@38.146.3.183:17756,a6a3ef121282dbf6d9ac70a83cba02780a6b4a5c@67.209.54.93:17756,ba0a167567c7e08f4bb1e25ec24e42a85b07a0c5@148.113.20.208:17756,8fb88c54a8175908bab4dc4122652e7480988d97@3.37.63.177:26656,cca02db11dd1c59c91d355a72c702ccb26a9f99f@3.39.189.46:26656,3fc703341935b9356addfe7b3aad8991d9c8a923@148.113.20.207:17756,e55fe14a534f8cb9a8b8fb1b4a626d867bf642bb@162.19.69.49:52656,bf01fb9d4eab9e007a47c0c3d3b423c5fb426207@65.109.108.47:17756,11a44cfe807274df4ddbce7ee61c111bcecba6f0@65.109.82.87:17756"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.sge/config/config.toml
seeds=""
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.sge/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 100/g' $HOME/.sge/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 100/g' $HOME/.sge/config/config.toml



# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.sge/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.sge/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.sge/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.sge/config/app.toml
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.sge/config/config.toml


sudo tee /etc/systemd/system/sged.service > /dev/null <<EOF
[Unit]
Description=sge
After=network-online.target
[Service]
User=$USER
ExecStart=$(which sged) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF


# start service
sudo systemctl daemon-reload
sudo systemctl enable sged
sudo systemctl restart sged

echo '=============== SETUP FINISHED ==================='
echo -e 'Congratulations:        \e[1m\e[32mSUCCESSFUL NODE INSTALLATION\e[0m'
echo -e 'To check logs:        \e[1m\e[33mjournalctl -u sged -f -o cat\e[0m'
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
sged keys add $Wallet
echo -e "Save your mnemonic phrase"

break
;;
"Check node logs")
sudo journalctl -u sged -f -o cat

break
;;
"Delete Node")
sudo systemctl stop sged && \
sudo systemctl disable sged && \
rm /etc/systemd/system/sged.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf sge && \
rm -rf .sged && \
rm -rf $(which sged)

break
;;
"Exit")
exit
esac
done
done