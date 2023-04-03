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
git checkout v0.0.5
cd sge
go mod tidy
make install
```
After the installation is complete, you can run `defundd version` to check whether the installation is successful.

Display should be v0.2.6
<a id="run"></a>
### -Run node

#### Initialize node

```
moniker=YOUR_MONIKER_NAME
sged init $moniker --chain-id=sge-network-2
sged config chain-id sge-network-2
```

#### Download the Genesis file

```
curl -s https://raw.githubusercontent.com/sge-network/networks/master/sge-network-2/genesis.json > ~/.sge/config/genesis.json
```

#### Set peer and seed

```
SEEDS=""
PEERS="62b76a24869829fb3be53c25891ba37eca5994bd@95.217.224.252:26656,b29612454715a6dc0d1f0c42b426bf30f1d27738@78.46.99.50:24656,14823c9230ac2eb50fd48b7313e8ddd4c13207c6@94.130.219.37:26000,cfa86646e5eb05e111e7dde27750ff8ebe67d165@89.117.56.126:23956,43b05a6bab7ca735397e9fae2cb0ad99977cf482@34.83.191.67:26656,ddcd5fda167e6b45208faed8fd7e2f0640b4185c@52.44.14.245:26656,a05353fe9ae39dd0edbfa6341634dec781d84a5c@65.108.105.48:17756,1168931936c638e92ea6d93e2271b3fe5faee6d1@135.125.247.228:26656,27f0b281ea7f4c3db01fdb9f4cf7cc910ad240a6@209.34.205.57:26656,b4f800aa8ff11d0d7ab3f5ce19230f049dfebe4b@38.242.199.160:26656,8c74885d4310f606986c88e9613f5e48c9e154dd@65.108.2.41:56656,a13512dbb3def06f91aef81afb397db63d78b25c@51.195.89.114:20656,bbf84e77c0defea82d389e1bd0940d7718f0ee34@103.230.84.4:26656,3e644c24129e14d457e82bab3b5a16c510b12927@50.19.180.153:26656,d200a21e2b3edab24679d4544fea48471515098f@65.108.225.158:17756,dc831d440c18c4a4f72250806cd03e5b240f8935@3.15.209.96:26656"
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
chainid=sge-network-2
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

#### After that, you can go to the block [explorer](https://explorer.ppnv.space/sge) to check whether your validator is created successfully.
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


