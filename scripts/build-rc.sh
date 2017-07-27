#!/bin/sh
. scripts/common/main.sh
. scripts/common/build.sh

prepare_build rc \
	--url 'http://mirror.yandex.ru/gentoo-distfiles/distfiles/rc-1.7.2.tbz' \
	--vcs curl \
	--rev '1.7.2|tar xjvf'

cd "${BUILD_DIRECTORY}"

./configure --with-history --with-readline
make

# Check that rc works
./rc -c 'echo $version'

save_exe ./rc "$DDIR/$TARGET/rc"

cd "$DDIR"
git commit -m "Update rc

rc -c 'echo \$version':

$("$DDIR/$TARGET/rc" -c 'echo $version' | indent)
$COMMIT_MESSAGE_FOOTER" || true
