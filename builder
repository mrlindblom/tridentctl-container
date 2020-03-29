#!/usr/bin/env bash
set -e 

TRIDENT_JSON=$(curl -s https://api.github.com/repos/NetApp/trident/releases/latest)
TRIDENT_VERSION=$(echo $TRIDENT_JSON | jq -rc .name)
PRERELEASE=$(echo $TRIDENT_JSON | jq -rc .prerelease)
TRIDENT_URL=$(echo $TRIDENT_JSON | jq -cr .assets[0].browser_download_url)

mkdir -p ./build/lib64
mkdir -p ./build/lib/x86_64-linux-gnu/

cp /lib64/ld-linux-x86-64.so.2 ./build/lib64/ld-linux-x86-64.so.2
cp /lib/x86_64-linux-gnu/libc.so.6 ./build/lib/x86_64-linux-gnu/libc.so.6
cp /lib/x86_64-linux-gnu/libpthread.so.0 ./build/lib/x86_64-linux-gnu/libpthread.so.0

wget -O trident-installer.tar.gz $TRIDENT_URL --quiet
tar -zxvf trident-installer.tar.gz -C ./build/ trident-installer/tridentctl --strip-components 1 
chmod +x ./build/tridentctl

docker build . -t mrlindblom/tridentctl:$TRIDENT_VERSION
docker push mrlindblom/tridentctl:$TRIDENT_VERSION

rm -rf ./build
rm -f ./trident-installer.tar.gz

