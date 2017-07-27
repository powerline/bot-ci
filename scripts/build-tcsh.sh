#!/bin/sh
. scripts/common/main.sh
. scripts/common/build.sh

prepare_build tcsh \
	--url ftp://ftp.astron.com/pub/tcsh \
	--rev 'tcsh-|.tar.gz|tar xzvf'

cd "${BUILD_DIRECTORY}"

./configure --prefix="$HOME/opt/tcsh"
make

# Check that tcsh works
./tcsh --version

save_exe ./tcsh "$DDIR/$TARGET/tcsh"

cd "$DDIR"
git commit -m "Update tcsh

tcsh --version:

$("$DDIR/$TARGET/tcsh" --version | indent)
$COMMIT_MESSAGE_FOOTER" || true
