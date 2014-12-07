#!/bin/sh
. scripts/common/main.sh
mkdir -p build/zpython
mkdir -p deps/zpython
cd build/zpython
hg clone https://bitbucket.org/ZyX_I/zpython
git clone git://git.code.sf.net/p/zsh/code zsh
cd zsh
./.preconfig
./configure --prefix=/opt/zsh-${PYTHON_VERSION}
# Zsh make may fail due to missing yodl
make || true
# Simple sanity check in case the above command failed in an unexpected way, do 
# not run all tests
make TESTNUM=A01 test
sudo make install || true
cd ../zpython
mkdir build
cd build
cmake .. -DZSH_REPOSITORY="${ROOT}/build/zpython/zsh"
make
make test
sudo make install
tar czvf ${ROOT}/deps/zpython/zsh-${REV}.tar.gz -C /opt zsh-${PYTHON_VERSION}
cd ${ROOT}/deps
git add zpython/zsh-${REV}.tar.gz
git commit -m "Add zsh

zsh --version:

$(/opt/zsh-${PYTHON_VERSION}/bin/zsh --version | sed 's/^/    /')

python version:

$(/opt/zsh-${PYTHON_VERSION}/bin/zsh -c 'zmodload libzpython; zpython "import sys; print(sys.version)"' | sed 's/^/    /')

(zsh) git head:

$(cd "${ROOT}/build/zpython/zsh" && git show HEAD)

(zpython) hg tip:

$(hg tip -R "${ROOT}/build/zpython/zpython" | sed 's/^/    /')"
