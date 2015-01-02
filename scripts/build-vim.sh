#!/bin/sh
REV=$1
PYTHON1=$2

. scripts/common/main.sh
. scripts/common/build.sh

if test -z "$PYTHON1" ; then
	SUBDIR="${REV}-$PYTHON_VERSION"
else
	SUBDIR="${REV}-$PYTHON1-double"
fi

if test -z "$PYTHON1" ; then
	prepare_build vim/$SUBDIR mercurial https://vim.googlecode.com/hg "$REV"
else
	UPDATES=0
	prepare_build --onlycheck cpython-ucs2/$PYTHON1 mercurial http://hg.python.org/cpython $PYTHON1
	UPDATES="$(( $VERSION_UPDATED + $UPDATES ))"
	prepare_build --always vim/$SUBDIR mercurial https://vim.googlecode.com/hg "$REV"
	UPDATES="$(( $VERSION_UPDATED + $UPDATES ))"
	if test $UPDATES -eq 0 ; then
		exit 0
	fi
	ensure_opt cpython-ucs2 cpython-ucs2-$PYTHON1
	PY1PATH="$OPT_DIRECTORY"
fi

# PYTHON_CFLAGS contains -Werror=format-security. Old vim cannot be built with 
# this.
unset PYTHON_CFLAGS
cd "$BUILD_DIRECTORY"

CFGARGS="--with-features=normal --without-x --disable-gui"
if test -z "$PYTHON1" ; then
	if test "$PYTHON_VERSION_MAJOR" -ge 3 ; then
		CFGARGS="$CFGARGS --enable-python3interp"
	else
		CFGARGS="$CFGARGS --enable-pythoninterp"
	fi
else
	export LD_LIBRARY_PATH=$PY1PATH/lib:$LD_LIBRARY_PATH
	export PATH="$PY1PATH/bin:$PATH"
	CFGARGS="$CFGARGS --enable-python3interp=dynamic"
	CFGARGS="$CFGARGS --enable-pythoninterp=dynamic"
fi
if echo "$REV" | grep -q v7-0 ; then
	# With -O2 Vim is crashing
	export CFLAGS='-O0 -g'
else
	CFGARGS="$CFGARGS --enable-rubyinterp"
fi

./configure $CFGARGS
make

cp src/vim "$DEPS/${TARGET}/vim"
cd "$DEPS"
# Try running vim --version, fail build if it fails
$TARGET/vim --version
git add $TARGET/vim
git commit -m "Update vim for $SUBDIR

vim --version:

$("$DEPS/$TARGET/vim" --version | indent)
$COMMIT_MESSAGE_FOOTER"
