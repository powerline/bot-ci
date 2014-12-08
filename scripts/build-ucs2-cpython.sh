#!/bin/sh
REV=$1
. scripts/common/main.sh
mkdir -p build/cpython-ucs2
mkdir -p deps/cpython-ucs2
cd build/cpython-ucs2
hg clone http://hg.python.org/cpython -r $REV -u $REV $REV
cd $REV
./configure --enable-unicode=ucs2 --prefix=/opt/cpython-ucs2-$REV --enable-shared
make
sudo make install
# Sanity check: run python --version, fail build if it fails
/opt/cpython-ucs2-$REV/bin/python$REV --version
cd $ROOT/deps
tar czvf cpython-ucs2/cpython-ucs2-${REV}.tar.gz -C /opt cpython-ucs2-$REV
git add cpython-ucs2/cpython-ucs2-${REV}.tar.gz
git commit -m "Update ucs2 cpython-$REV build

python --version:

$(env LD_LIBRARY_PATH=/opt/cpython-ucs2-$REV/lib /opt/cpython-ucs2-$REV/bin/python$REV --version 2>&1)

hg tip:

$(hg tip -R $ROOT/build/cpython-ucs2/$REV | sed 's/^/    /')"
