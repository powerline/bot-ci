#!/bin/sh
. scripts/common/main.sh
. scripts/common/build.sh

prepare_build vim-plugins/command-t git https://github.com/wincent/Command-T

cd build/vim-plugins

cd command-t/ruby/command-t
ruby extconf.rb
make

cd ../..
mv .git ../.git-command-t
cd ..
tar czf $ROOT/deps/vim-plugins/command-t.tar.gz command-t
mv .git-command-t command-t/.git

cd $ROOT/deps
git add vim-plugins/command-t.tar.gz
git commit -m "Update Command-T
$COMMIT_MESSAGE_FOOTER"
