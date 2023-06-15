<a id="anchor"></a>
# SAO testnet guide



<p align="right">
  <a href="https://discord.com/invite/q58XsnQqQF"><img src="https://img.shields.io/badge/Discord-7289DA?style=for-the-badge&logo=discord&logoColor=white" /></a> &nbsp;
  <a href="https://twitter.com/SAONetwork"><img src="https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white" /></a> &nbsp;
  <a href="https://medium.com/@saonetwork"><img src="https://img.shields.io/badge/Medium-12100E?style=for-the-badge&logo=medium&logoColor=white" /></a> &nbsp;
</p>

|Sections|Description|
|-----------------------:|------------------------------------------:|
| [Install the basic environment](#go) | Install golang. Command to check the version|
| [Install other necessary environments](#necessary) | Clone repository. Compilation project |
| [Run Node](#run) |  Initialize node. Create configuration files. Check logs & sync status. |
| [Create Validator](#validator) |  Create valdator & wallet, check your balance. |
| <a href="https://explorer.nodestake.top/sao-testnet/staking">Explorer</a> |  Check whether your validator is created successfully |


 <p align="center"><a href="https://0ww.sao.network/#Docs"><img align="right"width="100px"alt="SAO" src="https://i.ibb.co/s9MdT2Q/k-V74-EMrg-400x400.jpg"></p</a>

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
git clone https://github.com/SaoNetwork/sao-consensus.git
cd sao-consensus
git checkout v0.1.6
make install
saod version
```
After the installation is complete, you can run `saod version` to check whether the installation is successful.

Display should be v0.1.6
<a id="run"></a>
### -Run node

#### Initialize node

```
moniker=YOUR_MONIKER_NAME
saod init $moniker --chain-id=sao-testnet1
saod config chain-id sao-testnet1
```

#### Download the Genesis file

```
curl -s https://raw.githubusercontent.com/SAONetwork/sao-consensus/testnet0/network/testnet0/config/genesis.json -O genesis.json > ~/.sao/config/genesis.json
```

#### Set peer and seed

```
SEEDS="4e6df8dcc080b8c73929fc513443ecd5e0a424f0@sao-testnet-seed.itrocket.net:19656"
PEERS="08d8f8ae761177ecf95159281d08bca622c7e578@sao-testnet-peer.itrocket.net:19656,4fa89d8492cdef5b7f887c4002b3df70d1283063@65.21.134.202:15756,1667f1737eca69c487c114a03c0a058dd9cf8c02@194.163.168.62:19656,8ea46db77d6698c2e9509a5dd9ca4436436676cc@43.156.118.116:26656,028d522954c744b095fea1b9f1f475509b82d700@8.222.210.19:26656,d99aa1b6ab12faaee47ab1f8bfa59187b0bab588@65.109.89.18:19656,4db9aa492b13137d048af1ac554e8a6c09f80fcf@75.119.154.212:26656,195eb1c0b2b6c52f690cb9500bbc93c855616d50@120.226.39.104:26656,8a6983c4b3402c0a25c110eee8a9d0ca369b45c9@65.21.131.215:15756,4b05fcf7f3bb8766a7a7f9838cb13f4e8fbdfaeb@207.180.251.220:17656,5b1a021a6ed3274dc2c855490ad8fe45e03ace99@65.108.75.107:21656"
sed -i 's|^seeds *=.*|seeds = "'$SEEDS'"|; s|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.sao/config/config.toml
```
[Up to sections ↑](#anchor)

#### Pruning settings
```
sed -i 's|^pruning *=.*|pruning = "custom"|g' $HOME/.sao/config/app.toml
sed -i 's|^pruning-keep-recent  *=.*|pruning-keep-recent = "100"|g' $HOME/.sao/config/app.toml
sed -i 's|^pruning-interval *=.*|pruning-interval = "10"|g' $HOME/.sao/config/app.toml
sed -i 's|^snapshot-interval *=.*|snapshot-interval = 2000|g' $HOME/.sao/config/app.toml
  
 sed -i 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.0sao"|g' $HOME/.sao/config/app.toml
sed -i 's|^prometheus *=.*|prometheus = true|' $HOME/.sao/config/config.toml
```
#### Start node 
```
sudo tee <<EOF >/dev/null /etc/systemd/system/saod.service
[Unit]
Description=saod daemon
After=network-online.target
[Service]
User=$USER
ExecStart=$(which saod) start
Restart=on-failure
RestartSec=3
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload && \
sudo systemctl enable saod && \
sudo systemctl start saod 
```
___

#### Show log
```
sudo journalctl -u saod -f
```
#### Check sync status
```
curl -s localhost:26657/status | jq .result | jq .sync_info
```
The display `"catching_up":` shows `false` that it has been synchronized. Synchronization takes a while, maybe half an hour to an hour. If the synchronization has not started, it is usually because there are not enough peers. You can consider adding a Peer or using someone else's addrbook.

[Up to sections ↑](#anchor)
#### Replace addrbook
```
wget -O $HOME/.saod/config/addrbook.json "https://raw.githubusercontent.com/GalaxyNode/Testnets-guides/main/SAO/addrbook.json"
```
<a id="validator"></a>
### Create a validator
#### Create wallet
```
saod keys add WALLET_NAME
```
----
## `Note please save the mnemonic and priv_validator_key.json file! If you don't save it, you won't be able to restore it later.`
----
### Receive test coins
#### Go to sao discord https://discord.com/invite/q58XsnQqQF
[Up to sections ↑](#anchor)
#### Sent in #faucet channel
```
$request WALLET_ADDRESS
```
#### Can be used later
```
saod query bank balances WALLET_ADDRESS
```
#### Query the test currency balance.
#### Create a validator
`After enough test coins are obtained and the node is synchronized, a validator can be created. Only validators whose pledge amount is in the top 100 are active validators.`
```
daemon=saod
denom=usao
moniker=MONIKER_NAME
chainid=sao-testnet1
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

#### After that, you can go to the block [explorer](https://explorer.nodestake.top/sao-testnet/staking) to check whether your validator is created successfully.
----

  <h4 align="center"> More information </h4>
  
<table width="400px" align="center">
    <tbody>
        <tr valign="top">
          <td>
            <a href="https://www.sao.network/#/" target="site">Official website</a> </td>
          <td><a href="https://twitter.com/sao_network" target="twitt">Official twitter</a> </td> 
          <td><a href="https://discord.com/invite/q58XsnQqQF" target="discord">Discord</a></td> 
          <td><a href="https://github.com/SAONetwork" target="git">Github</a> </td>
          <td><a href="https://www.sao.network/#Docs" target="doc">Documentation</a></td>   </tr>
    </tbody>
</table> 


### [Up to sections ↑](#anchor)



