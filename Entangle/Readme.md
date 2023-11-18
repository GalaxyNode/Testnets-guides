<a id="anchor"></a>
# Entangle testnet guide



<p align="right">
  <a href="https://discord.com/invite/entanglefi"><img src="https://img.shields.io/badge/Discord-7289DA?style=for-the-badge&logo=discord&logoColor=white" /></a> &nbsp;
  <a href="https://twitter.com/Entanglefi"><img src="https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white" /></a> &nbsp;
  <a href="https://medium.com/@entanglefi"><img src="https://img.shields.io/badge/Medium-12100E?style=for-the-badge&logo=medium&logoColor=white" /></a> &nbsp;
</p>

|Sections|Description|
|-----------------------:|------------------------------------------:|
| [Install the basic environment](#go) | Install golang. Command to check the version|
| [Install other necessary environments](#necessary) | Clone repository. Compilation project |
| [Run Node](#run) |  Initialize node. Create configuration files. Check logs & sync status. |
| [Create Validator](#validator) |  Create valdator & wallet, check your balance. |
| <a href="https://explorer.nodestake.top/entangle-testnet/staking" target="_explorer">Explorer</a> |  Check whether your validator is created successfully |


 <p align="center"><a href="https://entangle-protocol.gitbook.io/welcome/"><img align="right"width="100px"alt="Entangle" src="https://i.ibb.co/t8ZjBTh/Entangle-Logo.jpg"></p</a>

| Minimum configuration                                                                                |
|------------------------------------------------------------------------------------------------------|
- 2 CPU                                                                                                
- 8 GB RAM
- 250GB SSD                                                                                            

---
## Auto install script
```
curl -s https://raw.githubusercontent.com/GalaxyNode/Testnets-guides/main/Entangle/Entangle.sh > entangle.sh && chmod +x entangle.sh && ./Entangle.sh
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
git clone https://github.com/Entangle-Protocol/entangle-blockchain.git
cd entangle-blockchain
git checkout ce539b81e760a3e75acd7fde9038c21fbe7b7baa
make install
```
After the installation is complete, you can run `entangled version` to check whether the installation is successful.

Display should ce539b81e760a3e75acd7fde9038c21fbe7b7baa
<a id="run"></a>
### -Run node

#### Initialize node

```
moniker=YOUR_MONIKER_NAME
entangled init $moniker --chain-id=entangle_33133-1
entangled config chain-id entangle_33133-1
```

#### Download the Genesis file

```
curl -s https://ss-t.entangle.nodestake.top/genesis.json > ~/.entangled/config/genesis.json
```

#### Set peer and seed

```
SEEDS=""
PEERS="fe1635c374fad39f2098f615ac0141bd6947738a@64.227.24.223:26656,67eca0ca25a05e2508019224e92613bfd5ed0643@144.126.219.151:20356,9041405fc5bba5971fbe32c00cc923291ce3dfc4@207.180.229.221:26656,522b38535aec49c2f431e960c126f06d171507b0@65.108.141.109:61656,beaaef818c0f36169babf1d52fb514280060e323@134.209.73.245:26656,98019d6208be1bcd6500fa7f68d1b242f7f2c269@95.217.199.12:26604,6ab753ca242b9bb83af3786a94583640355cf1e2@65.109.70.45:11656"
sed -i 's|^seeds *=.*|seeds = "'$SEEDS'"|; s|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.entangled/config/config.toml
```
[Up to sections ↑](#anchor)

#### Pruning settings
```
sed -i 's|^pruning *=.*|pruning = "custom"|g' $HOME/.entangled/config/app.toml
sed -i 's|^pruning-keep-recent  *=.*|pruning-keep-recent = "100"|g' $HOME/.entangled/config/app.toml
sed -i 's|^pruning-interval *=.*|pruning-interval = "10"|g' $HOME/.entangled/config/app.toml
sed -i 's|^snapshot-interval *=.*|snapshot-interval = 2000|g' $HOME/.entangled/config/app.toml
  
 sed -i 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.000aNGL"|g' $HOME/.entangled/config/app.toml
sed -i 's|^prometheus *=.*|prometheus = true|' $HOME/.entangled/config/config.toml
```
#### Start node 
```
sudo tee <<EOF >/dev/null /etc/systemd/system/entangled.service
[Unit]
Description=entangle daemon
After=network-online.target
[Service]
User=$USER
ExecStart=$(which entangled) start
Restart=on-failure
RestartSec=3
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload && \
sudo systemctl enable entangled && \
sudo systemctl start entangled 
```
___

#### Show log
```
sudo journalctl -u entangled -f
```
#### Check sync status
```
curl -s localhost:26657/status | jq .result | jq .sync_info
```
The display `"catching_up":` shows `false` that it has been synchronized. Synchronization takes a while, maybe half an hour to an hour. If the synchronization has not started, it is usually because there are not enough peers. You can consider adding a Peer or using someone else's addrbook.

[Up to sections ↑](#anchor)
#### Replace addrbook
```
wget -O $HOME/.entangled/config/addrbook.json "https://raw.githubusercontent.com/GalaxyNode/Testnets-guides/main/entangle/addrbook.json"
```
<a id="validator"></a>
### Create a validator
#### Create wallet
```
entangled keys add WALLET_NAME
```
----
## `Note please save the mnemonic and priv_validator_key.json file! If you don't save it, you won't be able to restore it later.`
----
### Receive test coins
#### Go to entangle discord https://discord.com/invite/entanglefi
[Up to sections ↑](#anchor)
#### Sent in #faucet channel
```
$request WALLET_ADDRESS
```
#### Can be used later
```
entangled query bank balances WALLET_ADDRESS
```
#### Query the test currency balance.
#### Create a validator
`After enough test coins are obtained and the node is synchronized, a validator can be created. Only validators whose pledge amount is in the top 100 are active validators.`
```
daemon=entangled
denom=aNGL
moniker=MONIKER_NAME
chainid=entangle_33133-1
$daemon tx staking create-validator \
    --amount=1000000$denom \
    --pubkey=$($daemon tendermint show-validator) \
    --moniker=$moniker \
    --chain-id=$chainid \
    --commission-rate=0.05 \
    --commission-max-rate=0.1 \
    --commission-max-change-rate=0.1 \
    --min-self-delegation=1000000 \
    --gas=500000 \
    --gas-prices="10aNGL" \
    --fees 0$denom \
    --from=WALLET_NAME\
    --yes
```

#### After that, you can go to the block [explorer](https://explorer.nodestake.top/entangle-testnet) to check whether your validator is created successfully.
----

  <h4 align="center"> More information </h4>
  
<table width="400px" align="center">
    <tbody>
        <tr valign="top">
          <td>
            <a href="https://entangle.fi/" target="site">Official website</a> </td>
          <td><a href="https://twitter.com/Entanglefi" target="twitt">Official twitter</a> </td> 
          <td><a href="https://discord.com/invite/entanglefi" target="discord">Discord</a></td> 
          <td><a href="https://github.com/entangle-labs/entangle" target="git">Github</a> </td>
          <td><a href="https://entangle-protocol.gitbook.io/welcome/" target="doc">Documentation</a></td>   </tr>
    </tbody>
</table> 


### [Up to sections ↑](#anchor)

