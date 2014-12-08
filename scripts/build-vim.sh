#!/bin/sh
REV=$1
PYTHON1=$2
PYTHON2=$3
. scripts/common/main.sh
if test -z "$PYTHON1" ; then
	SUBDIR="${REV}-$PYTHON_VERSION"
else
	SUBDIR="${REV}-$PYTHON1-$PYTHON2"
fi
if ! test -d build/vim-repo ; then
	hg clone https://vim.googlecode.com/hg --noupdate build/vim-repo
fi
unset CFLAGS PROFILE_CFLAGS POST_DEFS CCC
mkdir -p build/vim/$SUBDIR
mkdir -p deps/vim/$SUBDIR
cd build/vim/$SUBDIR
hg clone $ROOT/build/vim-repo -r $REV -u $REV vim
cd vim
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
make EXTRA_DEFS=-Wno-error=format-security --no-builtin-rules --no-builtin-variables
cp src/vim $ROOT/deps/vim/$SUBDIR/vim
cd $ROOT/deps
# Try running vim --version, fail build if it fails
vim/$SUBDIR/vim --version
git add vim/$SUBDIR/vim
git commit -m "Update vim for $SUBDIR

hg tip:

$(hg tip -R "$ROOT/build/vim/$SUBDIR/vim" | indent)

vim --version:

$("$ROOT/deps/vim/$SUBDIR/vim" --version | indent)"
