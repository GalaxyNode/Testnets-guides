<a id="anchor"></a>
# SGE testnet guide



<p align="right">
  <a href="https://discord.gg/J7QuxwbW"><img src="https://img.shields.io/badge/Discord-7289DA?style=for-the-badge&logo=discord&logoColor=white" /></a> &nbsp;
  <a href="https://twitter.com/SixSigmaSports"><img src="https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white" /></a> &nbsp;
  <a href="http://sixsigmasports.medium.com/"><img src="https://img.shields.io/badge/Medium-12100E?style=for-the-badge&logo=medium&logoColor=white" /></a> &nbsp;
</p>

|Sections|Description|
|-----------------------:|------------------------------------------:|
| [Install the basic environment](#go) | Install golang. Command to check the version|
| [Install other necessary environments](#necessary) | Clone repository. Compilation project |
| [Run Node](#run) |  Initialize node. Create configuration files. Check logs & sync status. |
| [Create Validator](#validator) |  Create valdator & wallet, check your balance. |
| <a href="https://explorer.ppnv.space/sge" target="_explorer">Explorer</a> |  Check whether your validator is created successfully |


 <p align="center"><a href="https://six-sigma-sports.gitbook.io/documentation-1/"><img align="right"width="100px"alt="defund" src="https://i.ibb.co/5MgSQ0Q/Izhq-Hzk-M-400x400.jpg"></p</a>

| Minimum configuration                                                                                |
|------------------------------------------------------------------------------------------------------|
- 4 CPU                                                                                                
- 8 GB RAM
- 150GB SSD                                                                                            

---
## Auto install script
```
curl -s https://raw.githubusercontent.com/GalaxyNode/Testnets-guides/main/SGE/SGE.sh > SGE.sh && chmod +x SGE.sh && ./SGE.sh
```
---

--- 
### -Install the basic environment
#### The system used in this tutorial is Ubuntu20.04, please adjust some commands of other systems by yourself. It is recommended to use a foreign VPS.
<a id="go"></a>
#### Install golang
```
sudo rm -rf /usr/local/go;
curl https://dl.google.com/go/go1.20.1.linux-amd64.tar.gz | sudo tar -C/usr/local -zxvf - ;
cat <<'EOF' >>$HOME/.profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
source $HOME/.profile
```
#### After the installation is complete, run the following command to check the version

```
go version
```
<a id="necessary"></a>
[Up to sections ↑](#anchor)
### -Install other necessary environments

#### Update apt
```
sudo apt update && sudo apt full-upgrade -y
sudo apt list --upgradable
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```

```
cd
git clone https://github.com/sge-network/sge
git clone https://github.com/sge-network/networks
cd sge
git fetch --tags
git checkout v1.1.0
cd sge
go mod tidy
make install
```
After the installation is complete, you can run `defundd version` to check whether the installation is successful.

Display should be v1.1.0
<a id="run"></a>
### -Run node

#### Initialize node

```
moniker=YOUR_MONIKER_NAME
sged init $moniker --chain-id=sgenet-1
sged config chain-id sgenet-1
```

#### Download the Genesis file

```
curl -s https://raw.githubusercontent.com/sge-network/networks/master/mainnet/sgenet-1/genesis.json > ~/.sge/config/genesis.json
```

#### Set peer and seed

```
SEEDS=""
PEERS="05628e99f42eb2fbacfd1f0402f96f46b88dfe6b@146.59.52.137:17756,fe527359b6b6c5ad9cc6e2f6ed3af46018b29e15@136.243.36.60:17756,7258d8c7880167fca502592b8d64110d60e99a6b@65.108.232.180:17756,752bc8c7508affd7e2af494a6bf44bcb66cf84ea@65.108.39.140:17756,88f341a9670494c3d529934dc578eec1b00f4aa1@141.94.168.85:26656,59c71e1ae0267da913d8460c10bbbb86f8003d12@85.10.201.125:36656,6c1cbeb621f04886029c7b222041f7fdb307c579@94.130.14.54:17756,0aa028990c5a135e89447e88daf65a8a590257f4@136.243.67.44:17756,4078d8f702a2ee25c8da93938940748276652696@94.130.13.186:17756,304535618b71c2fe217fe771c745443ea3d7815e@65.108.0.94:17756,ad1dce877d93f9de0d3a5c0b0f28d114242c1d3b@64.185.227.122:17756,8f4ca666d56fc883328b1aa0796342c1c1602099@64.185.226.202:17756,401a4986e78fe74dd7ead9363463ba4c704d8759@38.146.3.183:17756,a6a3ef121282dbf6d9ac70a83cba02780a6b4a5c@67.209.54.93:17756,ba0a167567c7e08f4bb1e25ec24e42a85b07a0c5@148.113.20.208:17756,8fb88c54a8175908bab4dc4122652e7480988d97@3.37.63.177:26656,cca02db11dd1c59c91d355a72c702ccb26a9f99f@3.39.189.46:26656,3fc703341935b9356addfe7b3aad8991d9c8a923@148.113.20.207:17756,e55fe14a534f8cb9a8b8fb1b4a626d867bf642bb@162.19.69.49:52656,bf01fb9d4eab9e007a47c0c3d3b423c5fb426207@65.109.108.47:17756,11a44cfe807274df4ddbce7ee61c111bcecba6f0@65.109.82.87:17756"
sed -i 's|^seeds *=.*|seeds = "'$SEEDS'"|; s|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.sge/config/config.toml
```
[Up to sections ↑](#anchor)

#### Pruning settings
```
sed -i 's|^pruning *=.*|pruning = "custom"|g' $HOME/.sge/config/app.toml
sed -i 's|^pruning-keep-recent  *=.*|pruning-keep-recent = "100"|g' $HOME/.sge/config/app.toml
sed -i 's|^pruning-interval *=.*|pruning-interval = "10"|g' $HOME/.sge/config/app.toml
sed -i 's|^snapshot-interval *=.*|snapshot-interval = 2000|g' $HOME/.sge/config/app.toml
  
 sed -i 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.0001usge"|g' $HOME/.sge/config/app.toml
sed -i 's|^prometheus *=.*|prometheus = true|' $HOME/.sge/config/config.toml
```
#### Start node 
```
sudo tee <<EOF >/dev/null /etc/systemd/system/sged.service
[Unit]
Description=sged daemon
After=network-online.target
[Service]
User=$USER
ExecStart=$(which sged) start
Restart=on-failure
RestartSec=3
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload && \
sudo systemctl enable sged && \
sudo systemctl start sged 
```
___

#### Show log
```
sudo journalctl -u sged -f
```
#### Check sync status
```
curl -s localhost:26657/status | jq .result | jq .sync_info
```
The display `"catching_up":` shows `false` that it has been synchronized. Synchronization takes a while, maybe half an hour to an hour. If the synchronization has not started, it is usually because there are not enough peers. You can consider adding a Peer or using someone else's addrbook.

[Up to sections ↑](#anchor)
#### Replace addrbook
```
wget -O $HOME/.defund/config/addrbook.json "https://raw.githubusercontent.com/GalaxyNode/Testnets-guides/main/SGE/addrbook.json"
```
<a id="validator"></a>
### Create a validator
#### Create wallet
```
sged keys add WALLET_NAME
```
----
## `Note please save the mnemonic and priv_validator_key.json file! If you don't save it, you won't be able to restore it later.`
----
### Receive test coins
#### Go to SGE discord https://discord.gg/J7QuxwbW
[Up to sections ↑](#anchor)
#### Sent in #faucet channel
```
$request WALLET_ADDRESS
```
#### Can be used later
```
sged query bank balances WALLET_ADDRESS
```
#### Query the test currency balance.
#### Create a validator
`After enough test coins are obtained and the node is synchronized, a validator can be created. Only validators whose pledge amount is in the top 100 are active validators.`
```
daemon=sged
denom=usge
moniker=MONIKER_NAME
chainid=sgenet-1
$daemon tx staking create-validator \
    --amount=1000000$denom \
    --pubkey=$($daemon tendermint show-validator) \
    --moniker=$moniker \
    --chain-id=$chainid \
    --commission-rate=0.05 \
    --commission-max-rate=0.1 \
    --commission-max-change-rate=0.1 \
    --min-self-delegation=1000000 \
    --fees 0$denom \
    --from=WALLET_NAME\
    --yes
```

#### After that, you can go to the block [explorer](https://explorer.stavr.tech/Sge-Mainnet) to check whether your validator is created successfully.
----

  <h4 align="center"> More information </h4>
  
<table width="400px" align="center">
    <tbody>
        <tr valign="top">
          <td>
            <a href="https://sgenetwork.io/" target="site">Official website</a> </td>
          <td><a href="https://twitter.com/SixSigmaSports" target="twitt">Official twitter</a> </td> 
          <td><a href="https://discord.gg/J7QuxwbW" target="discord">Discord</a></td> 
          <td><a href="" target="git">Github</a> </td>
          <td><a href="https://six-sigma-sports.gitbook.io/documentation-1/" target="doc">Documentation</a></td>   </tr>
    </tbody>
</table> 


### [Up to sections ↑](#anchor)


