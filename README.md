nm## nord-networkmanager

Script to fetch and add vpn configurations from NordVPN to Gnome NetworkManager
Avoid downloading NordVPN client

Tested on:
- Fedora 37 - Gnome 43 - nmcli 1.40.2-1.fc37
- Fedora 38 - Gnome 44.3 - nmcli 1.42.8-1.fc38

### Installing
Download the install script from [here](https://raw.githubusercontent.com/xtenduke/nord-networkmanager/main/install.sh)

OR
```
curl https://raw.githubusercontent.com/xtenduke/nord-networkmanager/main/install.sh | bash
```


### Getting nordvpn credentials
The bottom section of this guide explains how to get nordvpn service credentials from your nord account
https://support.nordvpn.com/Connectivity/Linux/1047409422/Connect-to-NordVPN-using-Linux-Terminal.htm

Every time you add a new VPN connection, you will be asked for your nord account service password,
This is managed entirely by Gnome network-manager, away from this script.



## Sample
![image](demo.gif)


![image](https://github.com/xtenduke/nord-networkmanager/assets/5002212/9dced2a9-fe63-4a8a-96ca-b3d942d58cb1)