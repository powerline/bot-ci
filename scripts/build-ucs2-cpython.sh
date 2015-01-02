#!/bin/sh
REV=$1
. scripts/common/main.sh
. scripts/common/build.sh

prepare_build cpython-ucs2/$REV mercurial http://hg.python.org/cpython $REV

# List from http://askubuntu.com/questions/21547:
# sudo apt-get install -qq build-essential libz-dev libreadline-dev \
#                      libncursesw5-dev libssl-dev libgdbm-dev libsqlite3-dev \
#                      libz2-dev liblzma-dev libc6-dev tk-dev libdb-dev
sudo apt-get install -qq build-essential zlib1g-dev libreadline-dev \
                         libncursesw5-dev libssl-dev libgdbm-dev \
                         libsqlite3-dev liblzma-dev libc6-dev tk-dev libdb-dev

cd "${BUILD_DIRECTORY}"
sed -r -i -e 's@^(\s*)('\''/lib64)@\1"/usr/lib/x86_64-linux-gnu",\2@' setup.py
hg diff
./configure --enable-unicode=ucs2 --prefix="${OPT_DIRECTORY}" --enable-shared
make
sudo make install
# Sanity check: run python --version, fail build if it fails
"${OPT_DIRECTORY}"/bin/python$REV --version
cd "$DDIR"
commit_opt_archive "$OPT_DIRECTORY" "$TARGET" \
"Update ucs2 cpython-$REV build

python --version:

$(env LD_LIBRARY_PATH=$OPT_DIRECTORY/lib $OPT_DIRECTORY/bin/python$REV --version 2>&1 | indent)
$COMMIT_MESSAGE_FOOTER"
