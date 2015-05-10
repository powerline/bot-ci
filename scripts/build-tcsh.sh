#!/bin/sh
. scripts/common/main.sh
. scripts/common/build.sh

prepare_build tcsh \
	--url ftp://ftp.astron.com/pub/tcsh \
	--rev 'tcsh-|.tar.gz|tar xzvf'

cd "${BUILD_DIRECTORY}"

./configure --prefix="$HOME/opt/tcsh"
make

cp ./tcsh "$DDIR/$TARGET/tcsh"
cd "$DDIR"

# Check that tcsh works
$TARGET/tcsh --version

git add $TARGET/tcsh
git commit -m "Update tcsh

tcsh --version:

$("$DDIR/$TARGET/tcsh" --version | indent)
$COMMIT_MESSAGE_FOOTER" || true
