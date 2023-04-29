<a id="anchor"></a>
# Dymension testnet guide



<p align="right">
  <a href="https://discord.gg/dymension"><img src="https://img.shields.io/badge/Discord-7289DA?style=for-the-badge&logo=discord&logoColor=white" /></a> &nbsp;
  <a href="https://twitter.com/dymensionXYZ"><img src="https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white" /></a> &nbsp;
  <a href="https://medium.com/@dymensionXYZ"><img src="https://img.shields.io/badge/Medium-12100E?style=for-the-badge&logo=medium&logoColor=white" /></a> &nbsp;
</p>

|Sections|Description|
|-----------------------:|------------------------------------------:|
| [Install the basic environment](#go) | Install golang. Command to check the version|
| [Install other necessary environments](#necessary) | Clone repository. Compilation project |
| [Run Node](#run) |  Initialize node. Create configuration files. Check logs & sync status. |
| [Create Validator](#validator) |  Create valdator & wallet, check your balance. |
| <a href="https://dymension.explorers.guru/" target="_explorer">Explorer</a> |  Check whether your validator is created successfully |


 <p align="center"><a href="https://docs.dymension.xyz/"><img align="right"width="100px"alt="dymension" src="https://i.ibb.co/BNfwS6g/NGd-T4-O2k-400x400.jpg"></p</a>

| Minimum configuration                                                                                |
|------------------------------------------------------------------------------------------------------|
- 4 CPU                                                                                                
- 8 GB RAM
- 160GB SSD                                                                                            

---
## Auto install script
```
curl -s https://raw.githubusercontent.com/GalaxyNode/Testnets-guides/main/Dymension/Dymension.sh > Dymension.sh && chmod +x Dymension.sh && ./Dymension.sh
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
cd $HOME
git clone https://github.com/dymensionxyz/dymension.git --branch v0.2.0-beta
cd dymension
make install
```
After the installation is complete, you can run `dymd version` to check whether the installation is successful.

Display should be v0.2.0-beta
<a id="run"></a>
### -Run node

#### Initialize node

```
moniker=YOUR_MONIKER_NAME
dymd init $moniker --chain-id=35-C
dymd config chain-id 35-C
```

#### Download the Genesis file

```
curl -s https://raw.githubusercontent.com/obajay/nodes-Guides/main/Dymension/genesis.json > ~/.dymension/config/genesis.json
```

#### Set peer and seed

```
SEEDS="f97a75fb69d3a5fe893dca7c8d238ccc0bd66a8f@dymension-testnet.seed.brocha.in:30584,ebc272824924ea1a27ea3183dd0b9ba713494f83@dymension-testnet-seed.autostake.net:27086,b78dd0e25e28ec0b43412205f7c6780be8775b43@dym.seed.takeshi.team:10356,babc3f3f7804933265ec9c40ad94f4da8e9e0017@testnet-seed.rhinostake.com:20556,c6cdcc7f8e1a33f864956a8201c304741411f219@3.214.163.125:26656"
PEERS="ebc272824924ea1a27ea3183dd0b9ba713494f83@dymension-testnet-peer.autostake.net:27086,9111fd409e5521470b9b33a46009f5e53c646a0d@178.62.81.245:45656,f8a0d7c7db90c53a989e2341746b88433f47f980@209.182.238.30:30657,1bffcd1690806b5796415ff72f02157ce048bcdd@144.76.67.53:2580,c17a4bcba59a0cbb10b91cd2cee0940c610d26ee@95.217.144.107:20556,e6ea3444ac85302c336000ac036f4d86b97b3d3e@38.146.3.199:20556,b473a649e58b49bc62b557e94d35a2c8c0ee9375@95.214.53.46:36656,db0264c412618949ce3a63cb07328d027e433372@146.19.24.101:26646,281190aa44ca82fb47afe60ba1a8902bae469b2a@dymension.peers.stavr.tech:17806,290ec1fc5cc5667d4e072cf336758d744d291ef1@65.109.104.118:60556,d8b1bcfc123e63b24d0ebf86ab674a0fc5cb3b06@51.159.97.212:26656,55f233c7c4bea21a47d266921ca5fce657f3adf7@168.119.240.200:26656,139340424dddf85e54e0a54179d06875013e1e39@65.109.87.88:24656"
sed -i 's|^seeds *=.*|seeds = "'$SEEDS'"|; s|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.dymension/config/config.toml
```
[Up to sections ↑](#anchor)

#### Pruning settings
```
sed -i 's|^pruning *=.*|pruning = "custom"|g' $HOME/.dymension/config/app.toml
sed -i 's|^pruning-keep-recent  *=.*|pruning-keep-recent = "100"|g' $HOME/.dymension/config/app.toml
sed -i 's|^pruning-interval *=.*|pruning-interval = "10"|g' $HOME/.dymension/config/app.toml
sed -i 's|^snapshot-interval *=.*|snapshot-interval = 2000|g' $HOME/.dymension/config/app.toml
  
 sed -i 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.000udym"|g' $HOME/.dymension/config/app.toml
sed -i 's|^prometheus *=.*|prometheus = true|' $HOME/.dionymens/config/config.toml
```
#### Start node 
```
sudo tee <<EOF >/dev/null /etc/systemd/system/dymd.service
[Unit]
Description=dymd daemon
After=network-online.target
[Service]
User=$USER
ExecStart=$(which dymd) start
Restart=on-failure
RestartSec=3
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload && \
sudo systemctl enable dymd && \
sudo systemctl start dymd 
```
___

#### Show log
```
sudo journalctl -u dymd -f
```
#### Check sync status
```
curl -s localhost:26657/status | jq .result | jq .sync_info
```
The display `"catching_up":` shows `false` that it has been synchronized. Synchronization takes a while, maybe half an hour to an hour. If the synchronization has not started, it is usually because there are not enough peers. You can consider adding a Peer or using someone else's addrbook.

[Up to sections ↑](#anchor)
#### Replace addrbook
```
wget -O $HOME/.dionymens/config/addrbook.json "https://raw.githubusercontent.com/GalaxyNode/Testnets-guides/main/Dymension/addrbook.json"
```
<a id="validator"></a>
### Create a validator
#### Create wallet
```
dymd keys add WALLET_NAME
```
----
## `Note please save the mnemonic and priv_validator_key.json file! If you don't save it, you won't be able to restore it later.`
----
### Receive test coins
#### Go to dymension discord https://discord.gg/dymension
[Up to sections ↑](#anchor)
#### Sent in #faucet channel
```
$request WALLET_ADDRESS
```
#### Can be used later
```
dymd query bank balances WALLET_ADDRESS
```
#### Query the test currency balance.
#### Create a validator
`After enough test coins are obtained and the node is synchronized, a validator can be created. Only validators whose pledge amount is in the top 100 are active validators.`
```
daemon=dymd
denom=udym
moniker=MONIKER_NAME
chainid=35-C
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

#### After that, you can go to the block [explorer](https://dymension.explorers.guru/) to check whether your validator is created successfully.
----

  <h4 align="center"> More information </h4>
  
<table width="400px" align="center">
    <tbody>
        <tr valign="top">
          <td>
            <a href="https://dymension.xyz/" target="site">Official website</a> </td>
          <td><a href="https://twitter.com/dymensionXYZ" target="twitt">Official twitter</a> </td> 
          <td><a href="https://discord.gg/dymension" target="discord">Discord</a></td> 
          <td><a href="https://github.com/dymensionxyz" target="git">Github</a> </td>
          <td><a href="https://docs.dymension.xyz/" target="doc">Documentation</a></td>   </tr>
    </tbody>
</table> 


### [Up to sections ↑](#anchor)


