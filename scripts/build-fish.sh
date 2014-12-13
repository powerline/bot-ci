#!/bin/sh
. scripts/common/main.sh

mkdir -p deps/fish
mkdir -p build

git clone --depth=1 https://github.com/fish-shell/fish-shell build/fish

cd build/fish
autoconf
./configure --prefix=/opt/fish
make
./fish --version
sudo make install

tar czf "$ROOT/deps/fish/fish.tar.gz" -C /opt fish
cd "$ROOT/deps"
git add fish/fish.tar.gz
git commit fish/fish.tar.gz -m "Update fish

git head:

$(cd "$ROOT/build/fish" && git log --show --no-patch HEAD | indent)"
