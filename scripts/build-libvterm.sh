#!/bin/sh
. scripts/common/main.sh
. scripts/common/build.sh

prepare_build libvterm \
	--vcs bzr \
	--url http://bazaar.leonerd.org.uk/c/libvterm/

cd "$BUILD_DIRECTORY"
make
make test

cp -L .libs/libvterm.so "$DDIR/$TARGET"
cd "$DDIR"
git add "${TARGET}"/libvterm.so
git commit -m "Update libvterm.so
$COMMIT_MESSAGE_FOOTER" || true
