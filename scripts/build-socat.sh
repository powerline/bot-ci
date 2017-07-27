#!/bin/sh
. scripts/common/main.sh
. scripts/common/build.sh

prepare_build socat \
	--url 'http://mirror.yandex.ru/gentoo-distfiles/distfiles/socat-1.7.3.0.tar.bz2' \
	--vcs curl \
	--rev '1.7.3.0|tar xjvf'

cd "${BUILD_DIRECTORY}"

./configure
make

# Check that socat works
./socat -V

save_exe ./socat "$DDIR/$TARGET/socat"

cd "$DDIR"
git commit -m "Update socat

socat -V:

$("$DDIR/$TARGET/socat" -V | indent)
$COMMIT_MESSAGE_FOOTER" || true
