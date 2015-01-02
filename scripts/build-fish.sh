#!/bin/sh
. scripts/common/main.sh
. scripts/common/build.sh

prepare_build fish/fish git https://github.com/fish-shell/fish-shell

cd "${BUILD_DIRECTORY}"
autoconf
./configure --prefix="$OPT_DIRECTORY"
make
./fish --version
sudo make install

commit_opt_archive "$OPT_DIRECTORY" "$TARGET" \
"Update fish
$COMMIT_MESSAGE_FOOTER"
