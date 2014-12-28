#!/bin/sh
REV=$1
. scripts/common/main.sh
. scripts/common/build.sh

sudo apt-get install libsasl2-dev libssl-dev zlib1g-dev

prepare_build --always cpython-ucs2/$REV mercurial http://hg.python.org/cpython $REV
cd build/cpython-ucs2/$REV
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
