<a id="anchor"></a>
# pryzm testnet guide

<p align="right">
  <a href="https://discord.gg/mx4kjVG7zN"><img src="https://img.shields.io/badge/Discord-7289DA?style=for-the-badge&logo=discord&logoColor=white" /></a> &nbsp;
  <a href="https://twitter.com/pryzm_zone"><img src="https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white" /></a> &nbsp;
  <a href="https://pryzm.medium.com/"><img src="https://img.shields.io/badge/Medium-12100E?style=for-the-badge&logo=medium&logoColor=white" /></a> &nbsp;
</p>

|Sections|Description|
|-----------------------:|------------------------------------------:|
| [Install the basic environment](#go) | Install golang. Command to check the version|
| [Install other necessary environments](#necessary) | Clone repository. Compilation project |
| [Run Node](#run) |  Initialize node. Create configuration files. Check logs & sync status. |
| [Create Validator](#validator) |  Create valdator & wallet, check your balance. |
| <a href="https://testnet.itrocket.net/pryzm/staking" target="_explorer">Explorer</a> |  Check whether your validator is created successfully |


 <p align="center"><a href="https://pryzm-network.gitbook.io/"><img align="right"width="100px"alt="pryzm" src="https://i.ibb.co/SyZqzzy/PRYZM-Logo.jpg"></p</a>

| Minimum configuration                                                                                |
|------------------------------------------------------------------------------------------------------|
- 4 CPU                                                                                                
- 16 GB RAM (The requirements written in the official tutorial are too high, the actual 8GB+ is enough) 
- 160GB SSD                                                                                            

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
cd $HOME
wget -O pryzmd https://storage.googleapis.com/pryzm-zone/core/0.11.1/pryzmd-0.11.1-linux-amd64
chmod +x $HOME/pryzmd
mv pryzmd /root/go/bin/
```
After the installation is complete, you can run `pryzmd version` to check whether the installation is successful.

Display should be 0.11.1
<a id="run"></a>
### -Run node

#### Initialize node

```
moniker=YOUR_MONIKER_NAME
pryzmd init $moniker --chain-id=indigo-1
pryzmd config chain-id indigo-1
```

#### Download the Genesis file

```
curl -s https://snapshots.synergynodes.com/genesis/pryzm_testnet/genesis.json | jq -r .result.genesis > $HOME/.pryzm/config/genesis.json
```

#### Set peer and seed

```
SEEDS="ff17ca4f46230306412ff5c0f5e85439ee5136f0@testnet-seed.pryzm.zone:26656"
PEERS="8acc64034c3805a09581c4359f0c1e8b28c73873@178.128.225.129:26656,c778da65696e032ff92375c9b3a296d54fa89126@195.201.245.178:56076,8978a749557b044feb7ea659af71f09a561470de@23.88.5.169:30656,470bf421c6887def16e65dfe05cf1344826be06b@95.214.53.187:32656,3cb6bf28cde7571fff7f5536f7441993789eff38@178.62.75.58:26656,2d8296b0e85fdb22e2a6bb7f85d91b5e96ba021e@37.27.58.171:26656,37210f7727961f7f50f92878183c8e105590f4c9@154.53.46.181:26656,7c743b507ec3b67bc790c826ec471d2635c992f7@88.99.3.158:24656,d0e9239f982e1df5919290557280cf8bc78706e8@2a01:4f9:1a:9462::7:26656,8b13facd07099883a2275db870834390109ded62@92.243.27.215:27656,835c7f8a5ba11a53244ca9346ea5324c3a4ba3ed@188.40.66.173:24656"
sed -i 's|^seeds *=.*|seeds = "'$SEEDS'"|; s|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.pryzm/config/config.toml
```
[Up to sections ↑](#anchor)

#### Pruning settings
```
sed -i 's|^pruning *=.*|pruning = "custom"|g' $HOME/.pryzm/config/app.toml
sed -i 's|^pruning-keep-recent  *=.*|pruning-keep-recent = "100"|g' $HOME/.pryzm/config/app.toml
sed -i 's|^pruning-interval *=.*|pruning-interval = "10"|g' $HOME/.pryzm/config/app.toml
sed -i 's|^snapshot-interval *=.*|snapshot-interval = 2000|g' $HOME/.pryzm/config/app.toml
  
 sed -i 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.020upryzm"|g' $HOME/.pryzm/config/app.toml
sed -i 's|^prometheus *=.*|prometheus = true|' $HOME/.pryzm/config/config.toml
```
#### State-sync
```
sudo systemctl stop pryzmd
cp $HOME/.pryzm/data/priv_validator_state.json $HOME/.pryzm/priv_validator_state.json.backup
pryzmd tendermint unsafe-reset-all --home $HOME/.pryzm

STATE_SYNC_RPC=https://rpc-testnet-pryzm.nodeist.net:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 1000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i   -e "s|^enable *=.*|enable = true|"   -e "s|^rpc_servers *=.*|rpc_servers = "$STATE_SYNC_RPC,$STATE_SYNC_RPC"|"   -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|"   -e "s|^trust_hash *=.*|trust_hash = "$SYNC_BLOCK_HASH"|"   $HOME/.pryzm/config/config.toml

mv $HOME/.pryzm/priv_validator_state.json.backup $HOME/.pryzm/data/priv_validator_state.json

sudo systemctl restart pryzmd && sudo journalctl -fu pryzmd -o cat
``` 
[Up to sections ↑](#anchor)
#### Start node 
```
sudo tee <<EOF >/dev/null /etc/systemd/system/pryzmd.service
[Unit]
Description=pryzmd daemon
After=network-online.target
[Service]
User=$USER
ExecStart=$(which pryzmd) start
Restart=on-failure
RestartSec=3
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload && \
sudo systemctl enable pryzmd && \
sudo systemctl start pryzmd
```
___

#### Show log
```
sudo journalctl -u pryzmd -f
```
#### Check sync status
```
curl -s localhost:26657/status | jq .result | jq .sync_info
```
The display `"catching_up":` shows `false` that it has been synchronized. Synchronization takes a while, maybe half an hour to an hour. If the synchronization has not started, it is usually because there are not enough peers. You can consider adding a Peer or using someone else's addrbook.

[Up to sections ↑](#anchor)
#### Replace addrbook
```
wget -O $HOME/.pryzm/config/addrbook.json "https://raw.githubusercontent.com/GalaxyNode/Testnets-guides/main/pryzm/addrbook.json"
```
<a id="validator"></a>
### Create a validator
#### Create wallet
```
pryzmd keys add WALLET_NAME
```
----
## `Note please save the mnemonic and priv_validator_key.json file! If you don't save it, you won't be able to restore it later.`
----
### Receive test coins
#### Go to pryzm discord https://discord.gg/mx4kjVG7zN
[Up to sections ↑](#anchor)
#### Sent in #faucet channel
```
$request WALLET_ADDRESS
```
#### Can be used later
```
pryzmd query bank balances WALLET_ADDRESS
```
#### Query the test currency balance.
#### Create a validator
`After enough test coins are obtained and the node is synchronized, a validator can be created. Only validators whose pledge amount is in the top 100 are active validators.`
```
daemon=pryzmd
denom=upryzm
moniker=MONIKER_NAME
chainid=indigo-1
$daemon tx staking create-validator \
    --amount=1000000$denom \
    --pubkey=$($daemon tendermint show-validator) \
    --moniker=$moniker \
    --chain-id=$chainid \
    --commission-rate=0.05 \
    --commission-max-rate=0.1 \
    --commission-max-change-rate=0.1 \
    --min-self-delegation=1000000 \
    --fees 5000$denom \
    --from=WALLET_NAME\
    --yes
```

#### After that, you can go to the block [explorer](https://testnets.cosmosrun.info/pryzm-indigo-1) to check whether your validator is created successfully.
----

  <h4 align="center"> More information </h4>
  
<table width="400px" align="center">
    <tbody>
        <tr valign="top">
          <td>
            <a href="https://pryzm.zone/" target="site">Official website</a> </td>
          <td><a href="https://twitter.com/pryzm_zone" target="twitt">Official twitter</a> </td> 
          <td><a href="https://discord.gg/mx4kjVG7zN" target="discord">Discord</a></td> 
          <td><a href="https://github.com/pryzm-finance" target="git">Github</a> </td>
          <td><a href="https://docs.pryzm.zone/" target="doc">Documentation</a></td>   </tr>
    </tbody>
</table> 


### [Up to sections ↑](#anchor)
