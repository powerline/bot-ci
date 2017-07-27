#!/bin/sh
. scripts/common/main.sh
. scripts/common/build.sh

prepare_build mksh \
	--url git://github.com/MirBSD/mksh

cd "${BUILD_DIRECTORY}"

sh Build.sh

# Check that mksh works
./mksh -c 'echo $KSH_VERSION'

save_exe ./mksh "$DDIR/$TARGET/mksh"

cd "$DDIR"
git commit -m "Update mksh

mksh -c 'echo \$KSH_VERSION':

$("$DDIR/$TARGET/mksh" -c 'echo $KSH_VERSION' | indent)
$COMMIT_MESSAGE_FOOTER" || true
