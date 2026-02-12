#!/bin/bash

# Download this file with : 
#   curl -O https://raw.githubusercontent.com/Iron-Wolf/script/refs/heads/master/minecraft/get_file.sh



URL="https://github.com/ajermakovics/jvm-mon/releases/download/1.3/jvm-mon-linux-x64.tgz"
FILENAME=$(basename "$URL")

echo "Downloading $FILENAME..."
curl -L -o "$FILENAME" "$URL" || exit 1

echo "Uncompress..."
tar -xzf "$FILENAME" || exit 1

echo "Done !"
