#!/bin/sh
. scripts/common/main.sh
mkdir -p deps/libvterm
mkdir -p build/
bzr checkout --lightweight http://bazaar.leonerd.org.uk/c/libvterm/ build/libvterm
cd build/libvterm
make
make test
cp -L .libs/libvterm.so $ROOT/deps/libvterm
cd $ROOT/deps
git add libvterm/libvterm.so
git commit libvterm/libvterm.so -m "Update libvterm.so

bzr head:

$(cd $ROOT/build/libvterm && bzr log --limit=1 --show-ids| indent)" || true
