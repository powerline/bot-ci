#!/bin/sh
. scripts/common/main.sh

mkdir -p deps/vim-plugins
mkdir -p build/vim-plugins

git clone --depth=1 https://github.com/wincent/Command-T command-t

cd command-t
cd ruby/command-t
ruby extconfig.rb
make

cd ../..
mv .git ../.git-command-t
cd ..
tar czvf $ROOT/deps/vim-plugins/command-t.tar.gz command-t
mv .git-command-t command-t/.git

git commit -m "Update Command-T

git head:

$(cd "${ROOT}/build/vim-plugins/command-t" && git show --no-patch HEAD | indent)"
