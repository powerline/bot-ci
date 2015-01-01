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

cd build/cpython-ucs2/$REV
sed -r -i -e 's/^(\s*lib_dirs\s*=.*\[)/\1"/usr/lib/x86_64-linux-gnu",/' setup.py
./configure --enable-unicode=ucs2 --prefix=/opt/cpython-ucs2-$REV --enable-shared
make
sudo make install
# Sanity check: run python --version, fail build if it fails
/opt/cpython-ucs2-$REV/bin/python$REV --version
cd $ROOT/deps
tar czf cpython-ucs2/cpython-ucs2-${REV}.tar.gz -C /opt cpython-ucs2-$REV
git add cpython-ucs2/cpython-ucs2-${REV}.tar.gz
git commit -m "Update ucs2 cpython-$REV build

python --version:

$(env LD_LIBRARY_PATH=/opt/cpython-ucs2-$REV/lib /opt/cpython-ucs2-$REV/bin/python$REV --version 2>&1 | indent)
$COMMIT_MESSAGE_FOOTER"
