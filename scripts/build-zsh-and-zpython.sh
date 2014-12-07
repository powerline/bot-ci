#!/bin/sh
. scripts/common/main.sh
mkdir -p build/zpython
mkdir -p deps/zpython
cd build/zpython
hg clone https://bitbucket.org/ZyX_I/zpython
git clone --depth=1 git://git.code.sf.net/p/zsh/code zsh
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
LIBRARY_PATH="$(ldd "$(which python)" | grep libpython | sed 's/^.* => //;s/ .*$//')"
LIBPYTHON_NAME="$(basename "${LIBRARY_PATH}")"
PYTHON_SUFFIX="$(echo "${LIBPYTHON_NAME}" | sed -r 's/^libpython(.*)\.so.*$/\1/')"
PYTHON_INCLUDE_DIR="$(dirname "$(dirname "${LIBRARY_PATH}")")/include/python$PYTHON_SUFFIX"
cmake .. -DZSH_REPOSITORY="${ROOT}/build/zpython/zsh" \
         -DPYTHON_LIBRARY="$LIBRARY_PATH" \
         -DPYTHON_INCLUDE_DIR="${PYTHON_INCLUDE_DIR}"
make
ctest -VV
sudo make install
tar czvf ${ROOT}/deps/zpython/zsh-${PYTHON_VERSION}.tar.gz -C /opt zsh-${PYTHON_VERSION}
cd ${ROOT}/deps
git add zpython/zsh-${PYTHON_VERSION}.tar.gz
git commit -m "Add zsh

zsh --version:

$(/opt/zsh-${PYTHON_VERSION}/bin/zsh --version | sed 's/^/    /')

python version:

$(/opt/zsh-${PYTHON_VERSION}/bin/zsh -c 'zmodload libzpython; zpython "import sys; print(sys.version)"' | sed 's/^/    /')

(zsh) git head:

$(cd "${ROOT}/build/zpython/zsh" && git show --no-patch HEAD)

(zpython) hg tip:

$(hg tip -R "${ROOT}/build/zpython/zpython" | sed 's/^/    /')"
