#!/bin/bash

set -e

INSTALL_LOCATION="$HOME/.local/share/nordnetworkmanager"
FILENAME="nord-add.sh"

echo "Installing to $INSTALL_LOCATION"

if [ -d "$INSTALL_LOCATION" ]; then
  echo "Deleting existing installation"
  rm -rf "$INSTALL_LOCATION"
fi

mkdir "$INSTALL_LOCATION"
# Download
curl "https://raw.githubusercontent.com/xtenduke/nord-networkmanager/main/$FILENAME" -o "$INSTALL_LOCATION/$FILENAME"

# permission
chmod +x "$INSTALL_LOCATION/$FILENAME"

echo "Now add the following to your shell profile and reload shell."
echo alias nord-add=\""$INSTALL_LOCATION/$FILENAME"\"
echo "Then you can run the script as 'nord-add'"
echo "Now is a good time to read the readme https://github.com/xtenduke/nord-networkmanager/blob/main/README.md"
