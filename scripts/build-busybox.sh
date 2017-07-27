#!/bin/sh
. scripts/common/main.sh
. scripts/common/build.sh

prepare_build busybox \
	--url git://git.busybox.net/busybox

cd "${BUILD_DIRECTORY}"

make defconfig
make

# Check that busybox works
./busybox --help

save_exe ./busybox "$DDIR/$TARGET/busybox"

cd "$DDIR"
git commit -m "Update busybox

busybox --help:

$("$DDIR/$TARGET/busybox" --help | indent)
$COMMIT_MESSAGE_FOOTER" || true
