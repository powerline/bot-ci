#!/bin/sh
REV=$1
PYTHON1=$2
PYTHON2=$3

. scripts/common/main.sh
. scripts/common/build.sh

if test -z "$PYTHON1" ; then
	SUBDIR="${REV}-$PYTHON_VERSION"
else
	SUBDIR="${REV}-$PYTHON1-$PYTHON2"
fi

if ! test -d build/vim-repo ; then
	hg clone https://vim.googlecode.com/hg --noupdate build/vim-repo
fi

if test -z "$PYTHON1" ; then
	prepare_build vim/$SUBDIR mercurial "$ROOT/build/vim-repo" "$REV"
else
	UPDATES=0
	prepare_build --always cpython-ucs2/$REV mercurial http://hg.python.org/cpython $PYTHON1
	UPDATES="$(( $VERSION_UPDATED + $UPDATES ))"
	prepare_build --always cpython-ucs2/$REV mercurial http://hg.python.org/cpython $PYTHON2
	UPDATES="$(( $VERSION_UPDATED + $UPDATES ))"
	prepare_build --always vim/$SUBDIR mercurial "$ROOT/build/vim-repo" "$REV"
	UPDATES="$(( $VERSION_UPDATED + $UPDATES ))"
	if test $UPDATES -eq 0 ; then
		exit 0
	fi
fi

# PYTHON_CFLAGS contains -Werror=format-security. Old vim cannot be built with 
# this.
unset PYTHON_CFLAGS
cd build/vim/$SUBDIR

CFGARGS="--with-features=normal --without-x --disable-gui"
if test -z "$PYTHON1" ; then
	if test "$PYTHON_VERSION_MAJOR" -ge 3 ; then
		CFGARGS="$CFGARGS --enable-python3interp"
	else
		CFGARGS="$CFGARGS --enable-pythoninterp"
	fi
else
	PY1PATH=/opt/cpython-ucs2-$PYTHON1
	PY2PATH=/opt/cpython-ucs2-$PYTHON2
	export LD_LIBRARY_PATH=$PY1PATH/lib:$PY2PATH/lib
	export PATH="$PY1PATH/bin:$PY2PATH/bin:$PATH"
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

cp src/vim $ROOT/deps/vim/$SUBDIR/vim
cd $ROOT/deps
# Try running vim --version, fail build if it fails
vim/$SUBDIR/vim --version
git add vim/$SUBDIR/vim
git commit -m "Update vim for $SUBDIR

vim --version:

$("$ROOT/deps/vim/$SUBDIR/vim" --version | indent)
$COMMIT_MESSAGE_FOOTER"
