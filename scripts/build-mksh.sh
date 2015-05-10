#!/bin/sh
. scripts/common/main.sh
. scripts/common/build.sh

prepare_build mksh \
	--url git://github.com/MirBSD/mksh

cd "${BUILD_DIRECTORY}"

make

cp ./mksh "$DDIR/$TARGET/mksh"
cd "$DDIR"

# Check that mksh works
$TARGET/mksh -c 'echo $KSH_VERSION'

git add $TARGET/mksh
git commit -m "Update mksh

mksh -c 'echo \$KSH_VERSION':

$("$DDIR/$TARGET/mksh" -c 'echo $KSH_VERSION' | indent)
$COMMIT_MESSAGE_FOOTER" || true
