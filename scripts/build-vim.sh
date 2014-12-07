#!/bin/sh
REV=$1
. scripts/common/main.sh
SUBDIR="${REV}-$PYTHON_VERSION"
if ! test -d build/vim-repo ; then
	hg clone https://vim.googlecode.com/hg --noupdate build/vim-repo
fi
mkdir -p build/vim/$SUBDIR
mkdir -p deps/vim/$SUBDIR
cd build/vim/$SUBDIR
hg clone $ROOT/build/vim-repo -r $REV -u $REV vim
cd vim
CFGARGS="--with-features=NORMAL --disable-gui"
if test "$PYTHON_VERSION_MAJOR" -ge 3 ; then
	CFGARGS="$CFGARGS --enable-python3interp"
else
	CFGARGS="$CFGARGS --enable-pythoninterp"
fi
./configure $CFGARGS
make
cp src/vim $ROOT/deps/vim/$SUBDIR/vim
cd $ROOT/deps
git add vim/$SUBDIR/vim
git commit -m "Built vim

hg tip:

$(hg tip -R "$ROOT/build/vim/$SUBDIR/vim" | sed 's/^/    /')

vim --version:

$("$ROOT/deps/vim/$SUBDIR/vim" --version | sed 's/^/    /')"
