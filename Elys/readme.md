<a id="anchor"></a>
# Elys testnet guide

<p align="right">
  <a href="https://discord.gg/elysnetwork"><img src="https://img.shields.io/badge/Discord-7289DA?style=for-the-badge&logo=discord&logoColor=white" /></a> &nbsp;
  <a href="https://twitter.com/elys_network"><img src="https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white" /></a> &nbsp;
  <a href="https://elysnetwork.medium.com/"><img src="https://img.shields.io/badge/Medium-12100E?style=for-the-badge&logo=medium&logoColor=white" /></a> &nbsp;
</p>

|Sections|Description|
|-----------------------:|------------------------------------------:|
| [Install the basic environment](#go) | Install golang. Command to check the version|
| [Install other necessary environments](#necessary) | Clone repository. Compilation project |
| [Run Node](#run) |  Initialize node. Create configuration files. Check logs & sync status. |
| [Create Validator](#validator) |  Create valdator & wallet, check your balance. |
| <a href="https://testnet.itrocket.net/elys/staking" target="_explorer">Explorer</a> |  Check whether your validator is created successfully |


 <p align="center"><a href="https://elys-network.gitbook.io/"><img align="right"width="100px"alt="elys" src="https://i.ibb.co/2g6RkX5/Elys-Network-Logo.jpg"></p</a>

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
git clone https://github.com/elys-network/elys elys
cd elys
git checkout v0.26.0
make install
```
After the installation is complete, you can run `elysd version` to check whether the installation is successful.

Display should be v0.26.0
<a id="run"></a>
### -Run node

#### Initialize node

```
moniker=YOUR_MONIKER_NAME
elysd init $moniker --chain-id=elystestnet-1
elysd config chain-id elystestnet-1
```

#### Download the Genesis file

```
curl -s https://github.com/elys-network/elys/blob/main/chain/genesis.json | jq -r .result.genesis > $HOME/.elys/config/genesis.json
```

#### Set peer and seed

```
SEEDS=""ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@testnet-seeds.polkachu.com:22056,ae7191b2b922c6a59456588c3a26    2df518b0d130@elys-testnet-seed.itrocket.net:38656"
PEERS=""
sed -i 's|^seeds *=.*|seeds = "'$SEEDS'"|; s|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.elysd/config/config.toml
```
[Up to sections ↑](#anchor)

#### Pruning settings
```
sed -i 's|^pruning *=.*|pruning = "custom"|g' $HOME/.elys/config/app.toml
sed -i 's|^pruning-keep-recent  *=.*|pruning-keep-recent = "100"|g' $HOME/.elys/config/app.toml
sed -i 's|^pruning-interval *=.*|pruning-interval = "10"|g' $HOME/.elys/config/app.toml
sed -i 's|^snapshot-interval *=.*|snapshot-interval = 2000|g' $HOME/.elys/config/app.toml
  
 sed -i 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.0001uelys"|g' $HOME/.elys/config/app.toml
sed -i 's|^prometheus *=.*|prometheus = true|' $HOME/.elys/config/config.toml
```
#### State-sync
```
sudo systemctl stop elysd

cp $HOME/.elys/data/priv_validator_state.json $HOME/.elys/priv_validator_state.json.backup
elysd tendermint unsafe-reset-all --home $HOME/.elys

peers="0977dd5475e303c99b66eaacab53c8cc28e49b05@elys-testnet-peer.itrocket.net:38656,cfc73dafa6b1fe5674fc1253d4de1cd74610bbd1@65.109.52.162:26688,98143b5dca162ba726536d07a6af6500d3e6fe1e@65.108.200.40:38656,a346d8325a9c3cd40e32236eb6de031d1a2d895e@95.217.107.96:26156,0858f2d75bb04f9ea877cb24f30537fcff582002@65.109.92.240:10126,60939e5760138c1db7cd3c587780ab6a643638e1@65.109.104.111:56102,8458b882cd16e2e23c010103956a06e9370b246e@65.109.61.113:32140,501767323c5223bfe138d916189cb5427f7e3931@104.193.254.42:27656,8cc16cba9ccb2e1a555acb29bf53a9198ecae7ce@209.126.2.211:53656,9a43ae2763fbeb8006c136e1209ff9552ca14bf4@38.242.237.5:38656,bbf8ef70a32c3248a30ab10b2bff399e73c6e03c@65.21.198.100:21256"  
SNAP_RPC="https://elys-testnet-rpc.itrocket.net:443"

sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.elys/config/config.toml 

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height);
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000));
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash) 

echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH && sleep 2

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ;
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ;
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ;
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"| ;
s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"\"|" $HOME/.elys/config/config.toml

mv $HOME/.elys/priv_validator_state.json.backup $HOME/.elys/data/priv_validator_state.json

sudo systemctl restart elysd && sudo journalctl -u elysd -f
``` 
[Up to sections ↑](#anchor)
#### Start node 
```
sudo tee <<EOF >/dev/null /etc/systemd/system/elysd.service
[Unit]
Description=elysd daemon
After=network-online.target
[Service]
User=$USER
ExecStart=$(which elysd) start
Restart=on-failure
RestartSec=3
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload && \
sudo systemctl enable elysd && \
sudo systemctl start elysd
```
___

#### Show log
```
sudo journalctl -u elysd -f
```
#### Check sync status
```
curl -s localhost:26657/status | jq .result | jq .sync_info
```
The display `"catching_up":` shows `false` that it has been synchronized. Synchronization takes a while, maybe half an hour to an hour. If the synchronization has not started, it is usually because there are not enough peers. You can consider adding a Peer or using someone else's addrbook.

[Up to sections ↑](#anchor)
#### Replace addrbook
```
wget -O $HOME/.elys/config/addrbook.json "https://raw.githubusercontent.com/GalaxyNode/Testnets-guides/main/Elys/addrbook.json"
```
<a id="validator"></a>
### Create a validator
#### Create wallet
```
elysd keys add WALLET_NAME
```
----
## `Note please save the mnemonic and priv_validator_key.json file! If you don't save it, you won't be able to restore it later.`
----
### Receive test coins
#### Go to Elys discord https://discord.gg/elysnetwork
[Up to sections ↑](#anchor)
#### Sent in #faucet channel
```
$request WALLET_ADDRESS
```
#### Can be used later
```
elysd query bank balances WALLET_ADDRESS
```
#### Query the test currency balance.
#### Create a validator
`After enough test coins are obtained and the node is synchronized, a validator can be created. Only validators whose pledge amount is in the top 100 are active validators.`
```
daemon=elysd
denom=uelys
moniker=MONIKER_NAME
chainid=elystestnet-1
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

#### After that, you can go to the block [explorer](https://testnet.itrocket.net/elys/staking) to check whether your validator is created successfully.
----

  <h4 align="center"> More information </h4>
  
<table width="400px" align="center">
    <tbody>
        <tr valign="top">
          <td>
            <a href="https://elys.network/" target="site">Official website</a> </td>
          <td><a href="https://twitter.com/elys_network" target="twitt">Official twitter</a> </td> 
          <td><a href="https://discord.gg/elysnetwork" target="discord">Discord</a></td> 
          <td><a href="https://github.com/elys-network" target="git">Github</a> </td>
          <td><a href="https://elys-network.gitbook.io/docs/nodes-and-validators/elys-network-validators" target="doc">Documentation</a></td>   </tr>
    </tbody>
</table> 


### [Up to sections ↑](#anchor)
