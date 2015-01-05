#!/bin/bash
REV=$1
PYTHON1=$2

. scripts/common/main.sh
. scripts/common/build.sh
. scripts/common/use-virtual-env.bash

if test -z "$PYTHON1" ; then
	SUBDIR="${REV}-$PYTHON_VERSION"
else
	SUBDIR="${REV}-$PYTHON1-double"
fi

if test -z "$PYTHON1" ; then
	prepare_build vim/$SUBDIR mercurial https://vim.googlecode.com/hg "$REV"
else
	UPDATES=0
	prepare_build --onlycheck cpython-ucs2/cpython-ucs2-$PYTHON1 mercurial http://hg.python.org/cpython $PYTHON1
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
	use-virtual-env cpython-ucs2-$PYTHON1 "$PY1PATH" $PYTHON1
	main_path="$PY1PATH/lib/python$UCS2_PYTHON_VARIANT"
	site_path="$main_path/site-packages"
	venv_main_path="$VIRTUAL_ENV/lib/python$UCS2_PYTHON_VARIANT"
	venv_site_path="$venv_main_path/site-packages"
	new_paths="${main_path}:${site_path}:${venv_main_path}:${venv_site_path}"
	export LD_LIBRARY_PATH=$PY1PATH/lib:$LD_LIBRARY_PATH
	export PYTHONPATH="$NEW_PATHS${PYTHONPATH:+:}$PYTHONPATH"
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

cp src/vim "$DDIR/${TARGET}/vim"
cd "$DDIR"
# Try running vim --version, fail build if it fails
$TARGET/vim --version
git add $TARGET/vim
git commit -m "Update vim for $SUBDIR

vim --version:

$("$DDIR/$TARGET/vim" --version | indent)
$COMMIT_MESSAGE_FOOTER"
