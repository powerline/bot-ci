#!/bin/bash
UCS2_REV="$1"

. scripts/common/main.sh
. scripts/common/build.sh
. scripts/common/use-virtual-env.bash

if test -n "$UCS2_REV" ; then
	ensure_opt cpython-ucs2 cpython-ucs2-$UCS2_REV
	use-virtual-env cpython-ucs2-$UCS2_REV "$OPT_DIRECTORY" $UCS2_REV
	DEPENDS_ARGS="--depends cpython-ucs2/cpython-ucs2-$UCS2_REV"
else
	DEPENDS_ARGS="--embedded-python"
fi

prepare_build zpython/zsh-$PYTHON_MM${UCS2_REV:+-ucs2} \
	--url git://repo.or.cz/zsh/mirror.git \
	--also-build "zpython/zpython-$PYTHON_MM${UCS2_REV:+-ucs2}
	              $DEPENDS_ARGS
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
make install || true

cd "$ZPYTHON_BDIR"
mkdir build
cd build
BUILD_ZPYTHON=1
LIBRARY_PATH="$(ldd "$PYTHON" | grep libpython | sed 's/^.* => //;s/ .*$//')"
if test -z "$LIBRARY_PATH" ; then
	ldd "$PYTHON"
	PYTHON_PREFIX="$(env -i "$PYTHON" -c 'import sys ; print(sys.prefix)')"
	if test -z "$PYTHON_PREFIX" ; then
		BUILD_ZPYTHON=0
	else
		for lib in "$PYTHON_PREFIX"/lib/libpython* ; do
			if ! test -e "$lib" ; then
				BUILD_ZPYTHON=0
			fi
			LIBRARY_PATH="$lib"
		done
		LIBRARY_DIR="$PYTHON_PREFIX/lib"
	fi
else
	LIBRARY_DIR="$(dirname "${LIBRARY_PATH}")"
fi
if test "$BUILD_ZPYTHON" -eq 1 ; then
	LIBPYTHON_NAME="$(basename "${LIBRARY_PATH}")"
	PYTHON_SUFFIX="$(echo "${LIBPYTHON_NAME}" | sed -r 's/^libpython(.*)\.so.*$/\1/')"
	PYTHON_INCLUDE_DIR="$(dirname "${LIBRARY_DIR}")/include/python$PYTHON_SUFFIX"

	export LD_LIBRARY_PATH="${LIBRARY_DIR}${LD_LIBRARY_PATH:+:}$LD_LIBRARY_PATH"

	cmake .. -DZSH_REPOSITORY="$ZSH_BDIR" \
	         -DPYTHON_LIBRARY="$LIBRARY_PATH" \
	         -DPYTHON_INCLUDE_DIR="${PYTHON_INCLUDE_DIR}" \
	         -DCMAKE_INSTALL_PREFIX="$ZSH_OPT"
	make
	ldd libzpython.so
	ZTST_verbose=1 ctest -VV
	make install
	save_exe libzpython.so

	print_zpython_version() {
		"$ZSH_OPT/bin/zsh" -c 'zmodload libzpython ; zpython "import sys; print(sys.version)"' \
			| indent
	}
else
	print_zpython_version() {
		echo 'Python not found, zpython not built' | indent
	}
fi

save_exe "$ZSH_OPT/bin/zsh"

commit_opt_archive "$ZSH_OPT" "$ZSH_TGT" \
"Update zsh and zpython for $LIBPYTHON_NAME

zsh --version:

$("$ZSH_OPT/bin/zsh" --version | indent)

python version:

$(print_zpython_version)
$COMMIT_MESSAGE_FOOTER"
