#!/bin/sh
. scripts/common/main.sh
prepare_build libvterm bzr http://bazaar.leonerd.org.uk/c/libvterm/
cd build/libvterm
make
make test
cp -L .libs/libvterm.so $ROOT/deps/libvterm
cd $ROOT/deps
git add libvterm/libvterm.so
git commit -m "Update libvterm.so
$COMMIT_MESSAGE_FOOTER"
