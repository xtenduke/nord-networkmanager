#!/bin/bash
set -e

NORD_OVPN_ZIP_URL=https://downloads.nordcdn.com/configs/archives/servers/ovpn.zip
NORD_OVPN_OUTPUT_PATH="./.download"
NETWORKMANAGER_PATH=/etc/NetworkManager/system-connections
START_DIR="$PWD"

clear_cache() {
    echo "Clearning cache"
    rm -rf "$NORD_OVPN_OUTPUT_PATH"
}

download_config() {
    mkdir "$NORD_OVPN_OUTPUT_PATH"
    curl "$NORD_OVPN_ZIP_URL" --output "$NORD_OVPN_OUTPUT_PATH/ovpn.zip"
    cd "$NORD_OVPN_OUTPUT_PATH"
    unzip ovpn.zip
    cd -
}

if [[ -f "$NORD_OVPN_OUTPUT_PATH/ovpn.zip" ]]; then
    read -p "Update config? [y/n] " yesno
    case "$yesno" in
        [yY] ) echo "Downloading";
            clear_cache
            download_config
            ;;
        [nN] ) echo "Using existing files";;
        * ) echo "Invalid input";
            exit
            ;;
    esac
else
    echo "No cache - downloading"
    download_config
fi

# Should have files here
cd "$NORD_OVPN_OUTPUT_PATH"
read -p "TCP or UDP? [t/u] " tcpudp
case "$tcpudp" in
    [tT] ) echo "UDP";
        cd ovpn_tcp
        ;;
    [uU] ) echo "UDP";
        cd ovpn_udp
        ;;
    * ) echo "Invalid input";
        exit
        ;;
esac

read -p "Enter a region code. e.g. \"us\" or nothing to display all regions: " region
files=("$region"*.ovpn)
index=-1
for f in "${files[@]}"; do
   index=$((index + 1))
   echo \["$index"\] "$f"
done

read -p "Enter a number corresponding to the server configuration you want to add [0 - $index]: " selected_index
selected_filename=${files[$selected_index]}
vpn_name=${selected_filename%.*}
echo "$vpn_name"

# CA Cert contents
# /home/<user>/.cert/nm-openvpn/<
ca_key_contents="$(sed -n "/<ca>/,/<\/ca>/p" "$selected_filename" | sed '1d;$d')"
export CONNECTION_CA_PATH=/home/"$USER"/.cert/nm-openvpn/"$vpn_name"-ca.pem
echo "$ca_key_contents" > "$CONNECTION_CA_PATH"
chmod 600 "$CONNECTION_CA_PATH"

# Auth cert contents
ta_key_contents="$(sed -n "/<tls-auth>/,/<\/tls-auth>/p" "$selected_filename" | sed '1d;$d')"
export CONNECTION_AUTH_KEY_PATH=/home/"$USER"/.cert/nm-openvpn/"$vpn_name"-tls-auth.pem
echo "$ta_key_contents" > "$CONNECTION_AUTH_KEY_PATH"
chmod 600 "$CONNECTION_AUTH_KEY_PATH"

if [ -z "$NORDVPN_USERNAME" ]; then
    read -p "Enter nordvpn service username. Or set NORDVPN_USERNAME in your env: " NORDVPN_USERNAME
    export NORDVPN_USERNAME
fi

export CONNECTION_ID="$vpn_name"
export CONNECTION_UUID=$(uuidgen)
export CONNECTION_AUTH="$(sed -n 's/^auth //p' $selected_filename)"
export CONNECTION_CA_CIPHER="$(sed -n 's/^cipher //p' $selected_filename)"
export CONNECTION_IPPORT="$(sed -n 's/^remote //p' $selected_filename | tr -s ' ' ':')"
export CONNECTION_CA_NAME="$(sed -n 's/^verify-x509-name //p' $selected_filename)"

cd $START_DIR
CONFIG_FILE_PATH="$NETWORKMANAGER_PATH/$CONNECTION_ID-$CONNECTION_UUID.nmconnection"
touch tmp.nmconnection
envsubst < nmconnection.template >> tmp.nmconnection
sudo mv tmp.nmconnection "$CONFIG_FILE_PATH"
sudo chmod 600 "$CONFIG_FILE_PATH"
sudo chown root "$CONFIG_FILE_PATH"
sudo nmcli connection load "$CONFIG_FILE_PATH"
echo "DONE"
