#!/bin/sh
. scripts/common/main.sh
. scripts/common/build.sh

UPDATES=0
prepare_build --always zpython/zsh git git://git.code.sf.net/p/zsh/code
UPDATES="$(( $VERSION_UPDATED + $UPDATES ))"
prepare_build --always zpython/zpython mercurial https://bitbucket.org/ZyX_I/zpython
UPDATES="$(( $VERSION_UPDATED + $UPDATES ))"
if test $UPDATES -eq 0 ; then
	exit 0
fi

cd build/zpython/zsh
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
LIBRARY_DIR="$(dirname "${LIBRARY_PATH}")"
LIBPYTHON_NAME="$(basename "${LIBRARY_PATH}")"
PYTHON_SUFFIX="$(echo "${LIBPYTHON_NAME}" | sed -r 's/^libpython(.*)\.so.*$/\1/')"
PYTHON_INCLUDE_DIR="$(dirname "${LIBRARY_DIR}")/include/python$PYTHON_SUFFIX"

export LD_LIBRARY_PATH="${LIBRARY_DIR}:$LD_LIBRARY_PATH"

cmake .. -DZSH_REPOSITORY="${ROOT}/build/zpython/zsh" \
         -DPYTHON_LIBRARY="$LIBRARY_PATH" \
         -DPYTHON_INCLUDE_DIR="${PYTHON_INCLUDE_DIR}"
make
ldd libzpython.so
ctest -VV
sudo make install
tar czf ${ROOT}/deps/zpython/zsh-${PYTHON_VERSION}.tar.gz -C /opt zsh-${PYTHON_VERSION}
cd ${ROOT}/deps

git add zpython/zsh-${PYTHON_VERSION}.tar.gz
git commit -m "Update zsh and zpython for $LIBPYTHON_NAME

zsh --version:

$(/opt/zsh-${PYTHON_VERSION}/bin/zsh --version | indent)

python version:

$(/opt/zsh-${PYTHON_VERSION}/bin/zsh -c 'zmodload libzpython; zpython "import sys; print(sys.version)"' | indent)
$COMMIT_MESSAGE_FOOTER"
