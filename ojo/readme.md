<a id="anchor"></a>
# Ojo testnet guide



<p align="right">
  <a href="https://discord.gg/4DwPGFtVb6"><img src="https://img.shields.io/badge/Discord-7289DA?style=for-the-badge&logo=discord&logoColor=white" /></a> &nbsp;
  <a href="https://twitter.com/ojo_network"><img src="https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white" /></a> &nbsp;
  <a href=""><img src="https://img.shields.io/badge/Medium-12100E?style=for-the-badge&logo=medium&logoColor=white" /></a> &nbsp;
</p>

|Sections|Description|
|-----------------------:|------------------------------------------:|
| [Install the basic environment](#go) | Install golang. Command to check the version|
| [Install other necessary environments](#necessary) | Clone repository. Compilation project |
| [Run Node](#run) |  Initialize node. Create configuration files. Check logs & sync status. |
| [Create Validator](#validator) |  Create valdator & wallet, check your balance. |
| <a href="https://ojo.explorers.guru/validators">Explorer</a> |  Check whether your validator is created successfully |


 <p align="center"><a href="https://docs.ojo.network/"><img align="right"width="100px"alt="defund" src="https://i.ibb.co/GfZ5vbc/h-Q4-S0c-A0-400x400.jpg"></p</a>

| Minimum configuration                                                                                |
|------------------------------------------------------------------------------------------------------|
- 4 CPU                                                                                                
- 8 GB RAM
- 200GB SSD                                                                                            

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
git clone https://github.com/ojo-network/ojo
cd ojo
git checkout v0.1.2
make install
```
After the installation is complete, you can run `defundd version` to check whether the installation is successful.

Display should be v0.1.2
<a id="run"></a>
### -Run node

#### Initialize node

```
moniker=YOUR_MONIKER_NAME
ojod init $moniker --chain-id=ojo-devnet
ojod config chain-id ojo-devnet
```

#### Download the Genesis file

```
curl -s https://raw.githubusercontent.com/obajay/nodes-Guides/main/Ojo/genesis.json > ~/.Ojo/config/genesis.json
```

#### Set peer and seed

```
SEEDS="83c547ae2fb272ccec4ea7cc90376e293d8df112@138.201.203.134:35656"
PEERS="a23cc4cbb09108bc9af380083108262454539aeb@35.215.116.65:26656"
sed -i 's|^seeds *=.*|seeds = "'$SEEDS'"|; s|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.Ojo/config/config.toml
```
[Up to sections ↑](#anchor)

#### Pruning settings
```
sed -i 's|^pruning *=.*|pruning = "custom"|g' $HOME/.Ojo/config/app.toml
sed -i 's|^pruning-keep-recent  *=.*|pruning-keep-recent = "100"|g' $HOME/.Ojo/config/app.toml
sed -i 's|^pruning-interval *=.*|pruning-interval = "10"|g' $HOME/.Ojo/config/app.toml
sed -i 's|^snapshot-interval *=.*|snapshot-interval = 2000|g' $HOME/.Ojo/config/app.toml
  
 sed -i 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.0uojo"|g' $HOME/.Ojo/config/app.toml
sed -i 's|^prometheus *=.*|prometheus = true|' $HOME/.Ojo/config/config.toml
```
#### Start node 
```
sudo tee <<EOF >/dev/null /etc/systemd/system/ojod.service
[Unit]
Description=ojod daemon
After=network-online.target
[Service]
User=$USER
ExecStart=$(which ojod) start
Restart=on-failure
RestartSec=3
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload && \
sudo systemctl enable ojod && \
sudo systemctl start ojod 
```
___

#### Show log
```
sudo journalctl -u ojod -f
```
#### Check sync status
```
curl -s localhost:26657/status | jq .result | jq .sync_info
```
The display `"catching_up":` shows `false` that it has been synchronized. Synchronization takes a while, maybe half an hour to an hour. If the synchronization has not started, it is usually because there are not enough peers. You can consider adding a Peer or using someone else's addrbook.

[Up to sections ↑](#anchor)
#### Replace addrbook
```
wget -O $HOME/.ojod/config/addrbook.json "https://raw.githubusercontent.com/GalaxyNode/Testnets-guides/main/ojo/addrbook.json"
```
<a id="validator"></a>
### Create a validator
#### Create wallet
```
ojod keys add WALLET_NAME
```
----
## `Note please save the mnemonic and priv_validator_key.json file! If you don't save it, you won't be able to restore it later.`
----
### Receive test coins
#### Go to Ojo discord https://discord.gg/4DwPGFtVb6
[Up to sections ↑](#anchor)
#### Sent in #faucet channel
```
$request WALLET_ADDRESS
```
#### Can be used later
```
ojod query bank balances WALLET_ADDRESS
```
#### Query the test currency balance.
#### Create a validator
`After enough test coins are obtained and the node is synchronized, a validator can be created. Only validators whose pledge amount is in the top 100 are active validators.`
```
daemon=ojod
denom=uojo
moniker=MONIKER_NAME
chainid=ojo-devnet
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

#### After that, you can go to the block [explorer](https://ojo.explorers.guru/validators) to check whether your validator is created successfully.
----

  <h4 align="center"> More information </h4>
  
<table width="400px" align="center">
    <tbody>
        <tr valign="top">
          <td>
            <a href="https://ojo.network/" target="site">Official website</a> </td>
          <td><a href="https://twitter.com/ojo_network" target="twitt">Official twitter</a> </td> 
          <td><a href="https://discord.gg/4DwPGFtVb6" target="discord">Discord</a></td> 
          <td><a href="https://github.com/ojo-network/ojo" target="git">Github</a> </td>
          <td><a href="https://docs.ojo.network/" target="doc">Documentation</a></td>   </tr>
    </tbody>
</table> 


### [Up to sections ↑](#anchor)



