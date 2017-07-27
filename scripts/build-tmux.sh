#!/bin/sh
REV=$1

. scripts/common/main.sh
. scripts/common/build.sh

prepare_build tmux/tmux-$REV \
	--url git://github.com/tmux/tmux \
	--rev $REV

cd "$BUILD_DIRECTORY"
sh autogen.sh
./configure
make

# Check that tmux works
./tmux -V

save_exe ./tmux "$DDIR/$TARGET/tmux"

cd "$DDIR"
git commit -m "Update tmux $REV

tmux -V:

$("$DDIR/$TARGET/tmux" -V | indent)
$COMMIT_MESSAGE_FOOTER" || true
