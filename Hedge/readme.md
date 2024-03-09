<a id="anchor"></a>
# Hedge testnet guide

<p align="right">
  <a href="https://discord.gg/fxmUNYTayQ"><img src="https://img.shields.io/badge/Discord-7289DA?style=for-the-badge&logo=discord&logoColor=white" /></a> &nbsp;
  <a href="https://twitter.com/hedgeblockio"><img src="https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white" /></a> &nbsp;
  <a href="https://medium.com/@hedgeblockio"><img src="https://img.shields.io/badge/Medium-12100E?style=for-the-badge&logo=medium&logoColor=white" /></a> &nbsp;
</p>

|Sections|Description|
|-----------------------:|------------------------------------------:|
| [Install the basic environment](#go) | Install golang. Command to check the version|
| [Install other necessary environments](#necessary) | Clone repository. Compilation project |
| [Run Node](#run) |  Initialize node. Create configuration files. Check logs & sync status. |
| [Create Validator](#validator) |  Create valdator & wallet, check your balance. |
| <a href="https://testnet.itrocket.net/elys/staking" target="_explorer">Explorer</a> |  Check whether your validator is created successfully |


 <p align="center"><a href="https://docs.hedgeblock.io/"><img align="right"width="100px"alt="Hedge" src="https://i.ibb.co/DzYMMcN/Hedge.jpg"></p</a>

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
cd
git clone https://github.com/hedgeblock/testnets/
wget -O hedged https://github.com/hedgeblock/testnets/releases/download/v0.1.0/hedged_linux_amd64_v0.1.0
chmod +x hedged
mv $HOME/hedged /usr/local/bin
```

### -Run node

#### Initialize node

```
moniker=YOUR_MONIKER_NAME
hedged init $moniker --chain-id=berberis-1
hedged config chain-id berberis-1
```

#### Download the Genesis file

```
wget -O $HOME/.hedge/config/genesis.json "https://raw.githubusercontent.com/NodeValidatorVN/GuideNode/main/Hedge/genesis.json"
```

#### Set peer and seed

```
SEEDS=""7879005ab63c009743f4d8d220abd05b64cfee3d@54.92.167.150:26656"
PEERS=""
sed -i 's|^seeds *=.*|seeds = "'$SEEDS'"|; s|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.hedge/config/config.toml
```
[Up to sections ↑](#anchor)

#### Pruning settings
```
pruning="custom" && \
pruning_keep_recent="100" && \
pruning_keep_every="0" && \
pruning_interval="10" && \
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.hedge/config/app.toml && \
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.hedge/config/app.toml && \
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.hedge/config/app.toml && \
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.hedge/config/app.toml
```
#### State-sync
```
sudo systemctl stop hedged
hedged tendermint unsafe-reset-all --home ~/.hedge/ --keep-addr-book
SNAP_RPC="https://hedge-rpc.validatorvn.com:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" ~/.hedge/config/config.toml
more ~/.hedge/config/config.toml | grep 'rpc_servers'
more ~/.hedge/config/config.toml | grep 'trust_height'
more ~/.hedge/config/config.toml | grep 'trust_hash'

sudo systemctl restart hedged && journalctl -u hedged -f -o cat
``` 
[Up to sections ↑](#anchor)
#### Start node 
```
sudo tee <<EOF >/dev/null /etc/systemd/system/hedged.service
[Unit]
Description=hedged daemon
After=network-online.target
[Service]
User=$USER
ExecStart=$(which hedged) start
Restart=on-failure
RestartSec=3
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload && \
sudo systemctl enable hedged && \
sudo systemctl start hedged
```
___

#### Show log
```
sudo journalctl -u hedged -f
```
#### Check sync status
```
curl -s localhost:26657/status | jq .result | jq .sync_info
```
The display `"catching_up":` shows `false` that it has been synchronized. Synchronization takes a while, maybe half an hour to an hour. If the synchronization has not started, it is usually because there are not enough peers. You can consider adding a Peer or using someone else's addrbook.

[Up to sections ↑](#anchor)
#### Replace addrbook
```
wget -O $HOME/.elys/config/addrbook.json "https://raw.githubusercontent.com/GalaxyNode/Testnets-guides/main/Hedge/addrbook.json"
```
<a id="validator"></a>
### Create a validator
#### Create wallet
```
hedged keys add WALLET_NAME
```
----
## `Note please save the mnemonic and priv_validator_key.json file! If you don't save it, you won't be able to restore it later.`
----
### Receive test coins
#### Go to Elys discord https://discord.gg/5E4WswKHNB
[Up to sections ↑](#anchor)
#### Sent in #faucet channel
```
$request WALLET_ADDRESS
```
#### Can be used later
```
hedged query bank balances WALLET_ADDRESS
```
#### Query the test currency balance.
#### Create a validator
`After enough test coins are obtained and the node is synchronized, a validator can be created. Only validators whose pledge amount is in the top 100 are active validators.`
```
daemon=hedged
denom=uhedge
moniker=MONIKER_NAME
chainid=berberis-1
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

#### After that, you can go to the block [explorer](https://berberis.hedgescan.io/validators) to check whether your validator is created successfully.
----

  <h4 align="center"> More information </h4>
  
<table width="400px" align="center">
    <tbody>
        <tr valign="top">
          <td>
            <a href="https://hedgeblock.io/" target="site">Official website</a> </td>
          <td><a href="https://twitter.com/hedgeblockio" target="twitt">Official twitter</a> </td> 
          <td><a href="https://discord.gg/fxmUNYTayQ" target="discord">Discord</a></td> 
          <td><a href="https://github.com/hedgeblock/" target="git">Github</a> </td>
          <td><a href="https://docs.hedgeblock.io/" target="doc">Documentation</a></td>   </tr>
    </tbody>
</table> 


### [Up to sections ↑](#anchor)
