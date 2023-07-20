<a id="anchor"></a>
# Router testnet guide



<p align="right">
  <a href="https://discord.com/invite/yjM2fUUHvN"><img src="https://img.shields.io/badge/Discord-7289DA?style=for-the-badge&logo=discord&logoColor=white" /></a> &nbsp;
  <a href="https://twitter.com/routerprotocol"><img src="https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white" /></a> &nbsp;
  <a href="https://routerprotocol.medium.com/"><img src="https://img.shields.io/badge/Medium-12100E?style=for-the-badge&logo=medium&logoColor=white" /></a> &nbsp;
</p>

|Sections|Description|
|-----------------------:|------------------------------------------:|
| [Install the basic environment](#go) | Install golang. Command to check the version|
| [Install other necessary environments](#necessary) | Clone repository. Compilation project |
| [Run Node](#run) |  Initialize node. Create configuration files. Check logs & sync status. |
| [Create Validator](#validator) |  Create valdator & wallet, check your balance. |
| <a href="https://exp.nodeist.net/Router/staking">Explorer</a> |  Check whether your validator is created successfully |


 <p align="center"><a href="https://docs.routerprotocol.com/validators"><img align="right"width="100px"alt="routerd" src="https://i.ibb.co/g39DP8r/EKEAQ1-FJ-400x400.jpg"></p</a>

| Minimum configuration                                                                                |
|------------------------------------------------------------------------------------------------------|
- 4 CPU                                                                                                
- 8 GB RAM
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
#### Libwasm compatibility
```
sudo wget -P /usr/lib https://github.com/CosmWasm/wasmvm/raw/main/internal/api/libwasmvm.x86_64.so
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
cd || return
cd $HOME
wget https://ss.nodeist.net/t/router/routerd
chmod +x routerd
mv routerd $HOME/go/bin/
```
After the installation is complete, you can run `routerd version` to check whether the installation is successful.
<a id="run"></a>
### -Run node

#### Initialize node

```
moniker=YOUR_MONIKER_NAME
routerd init $moniker --chain-id=router_9601-1
routerd config chain-id router_9601-1
```

#### Download the Genesis file

```
curl -s https://ss-t.router.nodestake.top/genesis.json -O genesis.json > ~/.routerd/config/genesis.json
```

#### Set peer and seed

```
SEEDS="074d7d3c5d142cbec150093086055d73be0080cf@35.178.32.171:26656,840b426e3d5520dd9e5e15b1ac8efb85920f06d7@109.236.82.5:1076,38e859e63c114a87cb71c23977966bf24e68827a@148.251.2.19:26656,b6a858bf5bc231c54ba42a5cdbf59fbc35315f77@136.243.131.108:26656,5fb7234ba7fe56a0d6e8023daa46885c50c00f27@65.109.82.112:22256,7edf6ea9751dd5ced32f2dedf226d5215d3a907d@135.181.207.28:26656,ee6ff5cff02c5a0f9434e7f371adba548bf0f7c1@95.217.77.173:26656,6aaba24641cc075b6182ea6ca19b643504485e26@162.19.237.134:26656,16bc9a252c2cb82c6aefdc82826f7d7021114f0a@13.127.165.58:26656"
PEERS="074d7d3c5d142cbec150093086055d73be0080cf@35.178.32.171:26656,dbcba835b674b4a3836b6248b53c0cb5b377957e@136.243.88.91:3100,b6a858bf5bc231c54ba42a5cdbf59fbc35315f77@136.243.131.108:26656,38e859e63c114a87cb71c23977966bf24e68827a@148.251.2.19:26656,7edf6ea9751dd5ced32f2dedf226d5215d3a907d@135.181.207.28:26656,1b5ce2602d27bfcd10eb10b265c5c894c5102c3d@65.109.82.112:22256,ee6ff5cff02c5a0f9434e7f371adba548bf0f7c1@95.217.77.173:26656,453304deaaaeca1a7c5f832007ef8d6ffdb10d56@47.245.25.38:26656,36eb478177e691b3389cdc60ed618c57f2a4acd7@13.127.150.80:26656,eff6bceb2eefaba044b402560bac1ea11c491252@43.204.10.128:26656,caf968dcf05f1ae505948ee22c78e5ba8724e1b3@3.111.32.194:26656,16bc9a252c2cb82c6aefdc82826f7d7021114f0a@13.127.165.58:26656,d43d5666e06f0906e2871e7a2dd78769237e5ce9@5.78.92.110:22256"
sed -i 's|^seeds *=.*|seeds = "'$SEEDS'"|; s|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.routerd/config/config.toml
```
[Up to sections ↑](#anchor)

#### Pruning settings
```
sed -i 's|^pruning *=.*|pruning = "custom"|g' $HOME/.routerd/config/app.toml
sed -i 's|^pruning-keep-recent  *=.*|pruning-keep-recent = "100"|g' $HOME/.routerd/config/app.toml
sed -i 's|^pruning-interval *=.*|pruning-interval = "10"|g' $HOME/.routerd/config/app.toml
sed -i 's|^snapshot-interval *=.*|snapshot-interval = 2000|g' $HOME/.routerd/config/app.toml
  
 sed -i 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.0route"|g' $HOME/.routerd/config/app.toml
sed -i 's|^prometheus *=.*|prometheus = true|' $HOME/.routerd/config/config.toml
```
#### Start node 
```
sudo tee <<EOF >/dev/null /etc/systemd/system/routerd.service
[Unit]
Description=routerd daemon
After=network-online.target
[Service]
User=$USER
ExecStart=$(which routerd) start
Restart=on-failure
RestartSec=3
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload && \
sudo systemctl enable routerd && \
sudo systemctl start routerd 
```
___

#### Show log
```
sudo journalctl -u routerd -f
```
#### Check sync status
```
curl -s localhost:26657/status | jq .result | jq .sync_info
```
The display `"catching_up":` shows `false` that it has been synchronized. Synchronization takes a while, maybe half an hour to an hour. If the synchronization has not started, it is usually because there are not enough peers. You can consider adding a Peer or using someone else's addrbook.

[Up to sections ↑](#anchor)
#### Replace addrbook
```
wget -O $HOME/.routerd/config/addrbook.json "https://raw.githubusercontent.com/GalaxyNode/Testnets-guides/main/routerd/addrbook.json"
```
<a id="validator"></a>
### Create a validator
#### Create wallet
```
routerd keys add WALLET_NAME
```
----
## `Note please save the mnemonic and priv_validator_key.json file! If you don't save it, you won't be able to restore it later.`
----
### Receive test coins
#### Go to faucet website https://faucet.routerprotocol.com/
[Up to sections ↑](#anchor)
```
routerd query bank balances WALLET_ADDRESS
```
#### Query the test currency balance.
#### Create a validator
`After enough test coins are obtained and the node is synchronized, a validator can be created. Only validators whose pledge amount is in the top 100 are active validators.`
```
daemon=routerd
denom=route
moniker=MONIKER_NAME
chainid=router_9601-1
$daemon tx staking create-validator \
    --amount=1000000$denom \
    --pubkey=$($daemon tendermint show-validator) \
    --moniker=$moniker \
    --chain-id=$chainid \
    --commission-rate=0.05 \
    --commission-max-rate=0.1 \
    --commission-max-change-rate=0.1 \
    --min-self-delegation=1 \
    --fees 0$denom \
    --from=WALLET_NAME\
    --yes
```

#### After that, you can go to the block [explorer](https://explorer.nodestake.top/routerd-testnet/staking) to check whether your validator is created successfully.
----

  <h4 align="center"> More information </h4>
  
<table width="400px" align="center">
    <tbody>
        <tr valign="top">
          <td>
            <a href="https://www.routerd.network/#/" target="site">Official website</a> </td>
          <td><a href="https://twitter.com/routerd_network" target="twitt">Official twitter</a> </td> 
          <td><a href="https://discord.com/invite/q58XsnQqQF" target="discord">Discord</a></td> 
          <td><a href="https://github.com/routerdNetwork" target="git">Github</a> </td>
          <td><a href="https://www.routerd.network/#Docs" target="doc">Documentation</a></td>   </tr>
    </tbody>
</table> 


### [Up to sections ↑](#anchor)



