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
echo export CHAIN_ID="ojo-devnet" >> $HOME/.bash_profile
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
git clone https://github.com/ojo-network/ojo
cd ojo
git checkout v0.1.2
make install

ojod init $NODENAME --chain-id $CHAIN_ID
cd $HOME/.ojo/config
curl -s https://snapshots.polkachu.com/testnet-genesis/ojo/genesis.json > ~/.ojo/config/genesis.json
wget -O $HOME/.ojo/config/addrbook.json "https://raw.githubusercontent.com/GalaxyNode/Testnets-guides/main/ojo/addrbook.json"



sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0uojo\"/;" ~/.ojo/config/app.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/.ojo/config/config.toml
external_address=$(wget -qO- eth0.me)
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:26656\"/" $HOME/.ojo/config/config.toml
peers="8f414276a2cb7a97d37a3e126c186972e1968039@65.108.4.233:56656,315350f9d96426d4a025dbdecae84ceca64d1638@95.217.40.230:56656,fc923db882093b31d0c5c37093764ec1fbbc4d09@144.91.102.95:34956,7bf4e4a18bf2006f79f50c79903f77d4e2a5a303@65.21.77.175:33307,6e5726d52ed6c854cc0625b32981dd93c01b54d7@135.181.183.62:17656,fe8c46222c3a013115797176623597aafc16e33a@173.212.203.238:46656,c0ee71c74858b339787320596b805ed631c48ebb@213.133.100.172:27433,978cf9aca38f819fd8189272379fc3c2ae2682a8@213.239.218.210:56656,0465032114df76df206c9983968f2d229b3a50d6@88.198.32.17:39656,d6b0791afd2d41c47bce8c152174b40c230988ba@138.201.225.104:47756,a2f93d0c45075b5c0a1791b729270f857f2517a2@128.140.86.47:26656,ba99038e9de54698765e47316c1d778aeb390a46@95.217.57.232:26656,dacdb802de389deb5ccf9100e049209f55f62854@188.40.98.169:29656,ff4bfdc2cc802b702355e90ff3e8258ce37dd16f@173.249.50.126:50656,a245b789aa5b8fcbbe681374bb954fdf6d3f5fd2@146.190.40.139:15056,2155de2f62e75c9a5b0c013c756420dd23f59914@142.132.209.236:21656,98e18386fb46ab8412e996caf93c782b4a9fc1cb@85.239.243.210:26656,0621bb73d18724cae4eb411e6b96765f95a3345e@178.63.8.245:61356,250b808db1d806a282314a3eca7f3e83ca2a839f@128.140.60.175:26656,5acc5ccc09dc10f5bc12c4ba4468a03c3df9d1ea@65.108.8.28:61356,d74d31e60a0c03e135a455d82006148b30a23e3c@65.109.154.182:31656,855fc154f9054ce4055719e09ce6f7f1d0ecd9fb@85.10.198.171:36656,fbeb2b37fe139399d7513219e25afd9eb8f81f4f@65.21.170.3:38656,7831b3b3d625757c749d17569c6730f6589d35fe@65.109.48.181:29656,3d11a6c7a5d4b3c5752be0c252c557ed4acc2c30@167.235.57.142:36656,1f4686345fbb19f91bfef4545b7b3742ad8a15d6@65.108.71.92:55756,84074bf78b0a18d2020c3549457f389d7c69ace5@65.108.98.125:60756,4f3ae90ab38c9c327654084a4f1ac9a89b097fc3@51.81.208.203:26656,d1c5c6bf4641d1800e931af6858275f08c20706d@23.88.5.169:18656,4ffdad68a6c6302168e0951766ffa1921c9b19a4@199.175.98.136:26656,8617d456081aab4798ea323193b07b9b434b5e49@146.190.132.147:15056,66b140833cba7cadd92d544088d735e219adbf01@65.108.226.183:21656,7afbf90f6ea9639c783ed38a2628a402bf3d912b@109.205.180.81:56656,256000ae8b93e9e29028c904f0b3a763202d1747@85.10.192.146:21656,1786d7d18b39d5824cae23e8085c87883ed661e6@65.109.147.57:36656,315f12823e9d2b886bfcb5d956ad65acb1a38393@176.9.121.109:41756,23830179727e6e38933e95000cb84ece4112f78c@185.155.97.74:18656,72fea84e5b91f18eb64b160091108348e77227d7@95.217.3.251:26656,339f7c6b966b25401c3862aa731351b77dc8076d@65.108.98.41:60656,98a552530acb9b0e81a834c2f514ee962da2bddf@65.109.70.45:16656,c43c0b1197f60cde53cb94b18d05a8d64d71a72a@162.55.245.219:50656,bcd047fefd23bbf2db1ea5c46859d105613163bc@81.25.51.158:26656,ed12aee3273baaaf01e357574c1692f12776446d@65.109.117.165:50656,174e741215a8957222d8be785072dd81b1634ec7@178.159.5.176:51656,48a295d04bc52f8a061632917ee53e27f40a53f3@86.48.16.205:50656,4bfc6d62d115a2440f9e5dc10c21d302dbdf5c64@34.220.136.165:26656,a876f7cda5f1ddd16aa271ec43cba750c0ba32c4@77.37.176.99:26656,4b54b62848bc09a68fc2cacb354fc6fcd10c8472@49.12.123.97:56656,1def3a4dac9577cdef31c975a0cdd9d653719e7c@167.172.188.16:26656,affee2f485ca15c68c302ad98e8de41fcd0e71ba@162.19.238.49:26656,02f12e71d5150b49c39123e4e979999b1a08e99d@5.9.79.121:62656,e54b02d103f1fcf5189a86abe542670979d2029d@65.109.85.170:58656,41d974f9a97209a401546a61ea2638a0f8071d79@178.18.252.10:26656,c2f1a2474219cdd314e271429b415732261ebaa3@148.251.19.197:26666,1d671a390989d5141fc51b231c50eaf69a1371b6@5.9.59.220:17656,97a388be825fc69fca40a8a3de75aa5794602abb@95.217.225.212:36656,17a5fad48064ee3da42f435925f7bbe055e6348d@65.108.233.102:37656,f87f249b14f96739406a460d3ccbb0df50a177ee@168.138.190.118:28656,8036aed2d37890ddf245e7288b4fc724a301d728@65.109.117.23:50656,e5c648f7434a98c5d135cff80b2ebbcd794eb073@154.53.40.197:26656,29e037b09affba860b34f0e41336378063860cca@158.178.246.147:28656,83a0043b2a2bfff38c3725c70f4c0305c760dfef@213.239.207.175:47656,ffe2d5ecb614762d5a1723f5f8b00d3feb6eb091@5.9.13.234:26686,e27836973284ea7c16dbdc23556bac489042cd8d@37.187.142.41:26656,0a91fe09ff049bf1c7b3d05e45f7a9628e2263eb@78.47.71.39:26656,4ed547a43ec424b8e126e9477911378b97db7ccc@161.97.73.64:28656,f63f353c1e8b47b6fe1cbbda91b5a91673c155b3@89.163.132.156:36656,4609153f2b095b6c7f98b9cd3d079fe8fcd992db@95.216.14.58:61356,045bc97a0d5b7e2943941faaa411f3ce7301372a@65.108.43.58:26656,46be755bb7f34a6f4722713e40c9786266654396@38.242.237.125:26656,c4e53142cafc7a7f2951979c041bc8e7b64553f1@38.242.250.87:28656,7d6706d7ee674e2b2c38d3eb47d85ec6e376c377@49.12.123.87:56656,371f313df7f79b34d65f026769a3e0c3e77127eb@45.137.67.238:26656,0d4dc8d9e80df99fdf7fbb0e44fbe55e0f8dde28@65.108.205.47:14756,ada8843784f5000c71fb391de5fb3ad26fece081@185.246.87.174:26656,54e4441673f17af9e5370fc6722c4da607c7947f@129.148.50.22:15056,ac5089a8789736e2bc3eee0bf79ca04e22202bef@162.55.80.116:29656,0ac9841750afe017b882768b0e29e72b8296d6b0@104.194.8.68:46656,202dfd7cac388fb02f7d722db6353636edad25c1@51.159.220.202:26656,a654bbc2b27134da4eb1fcc08f07a2c9ea0deec7@51.79.77.103:12656,d5519e378247dfb61dfe90652d1fe3e2b3005a5b@65.109.68.190:15056,b0dac6c4a34dff86d3a77665c61bd08b4a5007cf@65.108.224.156:26656,f616a5d02454f0d80460896a0b7d8dfba8bdbac9@173.249.21.248:26656,7714e2597934998802b7806439d92799fcd9f4b4@89.116.29.176:26656,9dc1f555bd37d6840237f32a2cd4d79ba1c80cb5@65.108.227.112:31656,9ea0473b3684dbf1f2cf194f69f746566dab6760@78.46.99.50:22656,fee808fc235e2f345caaaee1d65f818d710f6433@213.137.237.201:26656,f6d6e625759814e157457a5889961e02dba26ba6@65.109.92.240:37096,4c66c9cd1bd73a2e8ff7fde84292850f9002efdc@65.109.92.148:26656,3eb009ef71c5b27a62e2d7b69d6f0913e9d515c9@65.109.82.112:2626,68e1063796738a21620b38be0996b1c7f5822036@207.180.211.71:26656,7ee8ece35c778418302ac085817d835b67043871@116.203.245.212:26656,b33500a3aaeb7fa116bdbddbe9c91c3158f38f8d@128.199.18.172:26656,20d9bb13b09c054c30f1b48fbd276aa255af5a34@65.108.238.147:37656,69774d64905bb33ea805228ac875835aea09f25a@185.217.198.141:26656,90823c2a23f30ea161ca5ad4d34bbcc8f98c86e5@89.117.55.108:28656,659c9e2bd0fad9bad57c72b425233fd672898a9c@65.21.225.10:41656,3e2d9912684b16ad98d25b46535c24c496749277@185.144.99.81:26656,5a4b066bfd61af1dc759bf84920c792983b82aa4@167.235.252.89:26656,74f353fabb92c1e03ed3c81b7067ac9d615297e2@134.249.108.5:28656,5c2a752c9b1952dbed075c56c600c3a79b58c395@95.214.52.139:27226,e3d56e1538e41115bccdcb0b83a734407d59d2b9@185.219.142.216:50656,b133dde2713a216a017399920419fcb1e084cdb2@136.243.88.91:7330,58f192f7c6aebe881f54bd133e9b8abf82bc3b20@65.108.13.154:36656,5d9be9cf3d5161e4891b96a956c3c83de6c0ae49@5.78.75.124:26656,de7b4ad0c51f84ff8dd826e2e85af2e00c05360c@157.97.108.38:26656,0f8af8f8c82b7dd5a2e827753b0381b34f600eb1@5.161.75.168:26656,1626881c604cba71cbbc8cddd0fb5a5cb2adf2f0@87.106.114.73:33656,da9e028814ff30ec24e94bec6887f4686f692b86@173.212.222.167:30656,6e0b45d32722df1a612d723e289e59ede65a9dd1@65.109.61.113:24214,59954989ec7cb0c12ec55128d142db1a274b4465@135.181.221.186:26656,1b70500fde59305c11143a9142529e928574fd71@65.109.112.20:50656,ed367ee00b2155c743be6f5b635de6e7ea5acc64@149.202.73.104:11356,0ae4649c788cd2e86fc1ee0a45dc245c6716004e@95.214.55.25:35656,67e95aeec46d7c5840f9685ca2b4cd725841b814@16.163.74.176:26636,cb706ebe1d7a1f1d3e281bf46a78d84251f50810@95.217.58.111:26656,3652286ee39c2713d06cf286b932f9c88f1a0794@65.108.235.209:18656,b4c7205397045d22fe762c8d2021fa4ce6d7ea1e@162.55.39.159:36656,8fbfa810cb666ddef1c9f4405e933ef49138f35a@65.108.199.120:54656,02d8606b275dc0ff0487e04ce5ec3b545376356b@38.242.251.198:28656,340f0623e9338a5c93baf2d8a8825718a86d3e8b@195.3.223.196:26656,7186f24ace7f4f2606f56f750c2684d387dc39ac@65.108.231.124:12656,d18abe07d27a732e913a782d31b691087a76078d@88.99.164.158:37096,b314955720069e8c98acf1cf1e896b68a3e306f9@65.108.4.161:27656,9aa8a73ea9364aa3cf7806d4dd25b6aed88d8152@190.2.136.144:11556"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.ojo/config/config.toml
seeds="ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@testnet-seeds.polkachu.com:21656"
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.ojo/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 100/g' $HOME/.ojo/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 100/g' $HOME/.ojo/config/config.toml



# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.ojo/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.ojo/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.ojo/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.ojo/config/app.toml
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.ojo/config/config.toml


sudo tee /etc/systemd/system/ojod.service > /dev/null <<EOF
[Unit]
Description=ojod
After=network-online.target
[Service]
User=$USER
ExecStart=$(which ojod) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF


# start service
sudo systemctl daemon-reload
sudo systemctl enable ojod
sudo systemctl restart ojod

echo '=============== SETUP FINISHED ==================='
echo -e 'Congratulations:        \e[1m\e[32mSUCCESSFUL NODE INSTALLATION\e[0m'
echo -e 'To check logs:        \e[1m\e[33mjournalctl -u ojod -f -o cat\e[0m'
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
ojod keys add $Wallet
echo -e "Save your mnemonic phrase"

break
;;
"Check node logs")
sudo journalctl -u ojod -f -o cat

break
;;
"Delete Node")
sudo systemctl stop ojod && \
sudo systemctl disable ojod && \
rm /etc/systemd/system/ojod.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf ojo && \
rm -rf .ojo && \
rm -rf $(which ojod)

break
;;
"Exit")
exit
esac
done
done