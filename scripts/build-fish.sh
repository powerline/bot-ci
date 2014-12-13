#!/bin/sh
. scripts/common/main.sh

prepare_build fish git https://github.com/fish-shell/fish-shell

cd build/fish
autoconf
./configure --prefix=/opt/fish
make
./fish --version
sudo make install

tar czf "$ROOT/deps/fish/fish.tar.gz" -C /opt fish
cd "$ROOT/deps"
git add fish/fish.tar.gz
git commit -m "Update fish
$COMMIT_MESSAGE_FOOTER"
