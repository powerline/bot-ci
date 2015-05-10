#!/bin/sh
. scripts/common/main.sh
. scripts/common/build.sh

prepare_build busybox \
	--url git://git.busybox.net/busybox

make defconfig
make

cp ./busybox "$DDIR/$TARGET/busybox"
cd "$DDIR"

# Check that busybox works
$TARGET/busybox --help

git add $TARGET/busybox
git commit -m "Update busybox

busybox --help:

$("$DDIR/$TARGET/busybox" --help | indent)
$COMMIT_MESSAGE_FOOTER" || true
