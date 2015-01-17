#!/bin/sh
REV=$1

. scripts/common/main.sh
. scripts/common/build.sh

prepare_build tmux/tmux-$REV \
	--url git://git.code.sf.net/p/tmux/tmux-code \
	--rev $REV

cd "$BUILD_DIRECTORY"
sh autogen.sh
./configure
make

cp ./tmux "$DDIR/$TARGET/tmux"
cd "$DDIR"

# Check that tmux works
$TARGET/tmux -V

git add $TARGET/tmux
git commit -m "Update tmux $REV

tmux -V:

$("$DDIR/$TARGET/tmux" -V | indent)
$COMMIT_MESSAGE_FOOTER"
