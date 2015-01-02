#!/bin/sh
. scripts/common/main.sh
. scripts/common/build.sh

prepare_build vim-plugins/command-t git https://github.com/wincent/Command-T

cd "$BDIR_DIRECTORY"

cd command-t/ruby/command-t
ruby extconf.rb
make

cd ../..
mv .git ../.git-command-t
cd ..
tar czf "$DDIR/${TARGET}.tar.gz" command-t
mv .git-command-t command-t/.git

cd "$DDIR"
git add ${TARGET}.tar.gz
git commit -m "Update Command-T
$COMMIT_MESSAGE_FOOTER"
