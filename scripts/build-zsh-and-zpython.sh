#!/bin/bash
UCS2_REV="$1"

. scripts/common/main.sh
. scripts/common/build.sh
. scripts/common/use-virtual-env.bash

if test -n "$UCS2_REV" ; then
	ensure_opt cpython-ucs2 cpython-ucs2-$UCS2_REV
	use-virtual-env cpython-ucs2-$UCS2_REV "$OPT_DIRECTORY" $UCS2_REV
fi

prepare_build zpython/zsh${UCS2_REV:+-}${UCS2_REV}-$PYTHON_MM \
	--url git://git.code.sf.net/p/zsh/code \
	--also-build "zpython/zpython-$PYTHON_MM
	              --embeded-python
	              --url https://bitbucket.org/ZyX_I/zpython"
ZSH_TGT="$FIRST_TARGET"
ZSH_OPT="$FIRST_OPT_DIRECTORY"
ZSH_BDIR="$FIRST_BUILD_DIRECTORY"
ZPYTHON_BDIR="$SECOND_BUILD_DIRECTORY"

cd "$ZSH_BDIR"
./.preconfig
./configure --prefix="$ZSH_OPT"
# Zsh make may fail due to missing yodl
make || true
# Simple sanity check in case the above command failed in an unexpected way, do 
# not run all tests
make TESTNUM=A01 test
sudo make install || true

cd "$ZPYTHON_BDIR"
mkdir build
cd build
LIBRARY_PATH="$(ldd "$(which python)" | grep libpython | sed 's/^.* => //;s/ .*$//')"
LIBRARY_DIR="$(dirname "${LIBRARY_PATH}")"
LIBPYTHON_NAME="$(basename "${LIBRARY_PATH}")"
PYTHON_SUFFIX="$(echo "${LIBPYTHON_NAME}" | sed -r 's/^libpython(.*)\.so.*$/\1/')"
PYTHON_INCLUDE_DIR="$(dirname "${LIBRARY_DIR}")/include/python$PYTHON_SUFFIX"

export LD_LIBRARY_PATH="${LIBRARY_DIR}:$LD_LIBRARY_PATH"

cmake .. -DZSH_REPOSITORY="$ZSH_BDIR" \
         -DPYTHON_LIBRARY="$LIBRARY_PATH" \
         -DPYTHON_INCLUDE_DIR="${PYTHON_INCLUDE_DIR}" \
         -DCMAKE_INSTALL_PREFIX="$ZSH_OPT"
make
ldd libzpython.so
ctest -VV
sudo make install
commit_opt_archive "$ZSH_OPT" "$ZSH_TGT" \
"Update zsh and zpython for $LIBPYTHON_NAME

zsh --version:

$($ZSH_OPT/bin/zsh --version | indent)

python version:

$($ZSH_OPT/bin/zsh -c 'zmodload libzpython; zpython "import sys; print(sys.version)"' | indent)
$COMMIT_MESSAGE_FOOTER"
