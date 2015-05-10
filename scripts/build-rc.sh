#!/bin/sh
. scripts/common/main.sh
. scripts/common/build.sh

prepare_build rc \
	--url 'http://mirror.yandex.ru/gentoo-distfiles/distfiles/rc-1.7.2.tbz' \
	--vcs curl \
	--rev '1.7.2|tar xjvf'

./configure --with-history --with-readline
make

cp ./rc "$DDIR/$TARGET/rc"
cd "$DDIR"

# Check that rc works
$TARGET/rc -c 'echo $version'

git add $TARGET/rc
git commit -m "Update rc

rc -c 'echo \$version':

$("$DDIR/$TARGET/rc" -c 'echo $version' | indent)
$COMMIT_MESSAGE_FOOTER" || true
