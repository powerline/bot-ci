#!/bin/bash
REV=$1
PYTHON1=$2

. scripts/common/main.sh
. scripts/common/build.sh
. scripts/common/use-virtual-env.bash
. scripts/common/ruby.bash

ruby_setup

OLD=
if test "${REV#v7.0}" != "$REV" ; then
	OLD=1
fi

DOUBLE=
if test -z "$PYTHON1" ; then
	SUBDIR="${REV}-$PYTHON_MM"
elif test -n "$OLD" ; then
	SUBDIR="${REV}-$PYTHON1-ucs2"
else
	DOUBLE=1
	SUBDIR="${REV}-$PYTHON1-ucs2-double"
fi

if test -z "$PYTHON1" ; then
	prepare_build vim/$SUBDIR \
		--url git://github.com/vim/vim \
		--rev "$REV"
else
	ensure_opt cpython-ucs2 cpython-ucs2-$PYTHON1
	use-virtual-env cpython-ucs2-$PYTHON1 "$OPT_DIRECTORY" $PYTHON1
	version_file="$(get_version_file_name cpython-ucs2/cpython-ucs2-$PYTHON1)"
	archive_file="cpython-ucs2/cpython-ucs2-${PYTHON1}.tar.gz"
	prepare_build vim/$SUBDIR \
		--embedded-python \
		--url git://github.com/vim/vim \
		--rev "$REV" \
		--depends cpython-ucs2/cpython-ucs2-$PYTHON1
fi

# PYTHON_CFLAGS contains -Werror=format-security. Old vim cannot be built with 
# this.
unset PYTHON_CFLAGS
cd "$BUILD_DIRECTORY"

CFGARGS="--with-features=normal --without-x --disable-gui"
if test -z "$DOUBLE" ; then
	if test "$PYTHON_VERSION_MAJOR" -ge 3 ; then
		CFGARGS="$CFGARGS --enable-python3interp"
	else
		CFGARGS="$CFGARGS --enable-pythoninterp"
	fi
else
	CFGARGS="$CFGARGS --enable-python3interp=dynamic"
	CFGARGS="$CFGARGS --enable-pythoninterp=dynamic"
fi
if test -n "$OLD" ; then
	# With -O2 Vim is crashing
	export CFLAGS='-O0 -g'
else
	CFGARGS="$CFGARGS --enable-rubyinterp"
fi

./configure $CFGARGS
make

save_exe src/vim "$DDIR/$TARGET/vim"
cd "$DDIR"
# Try running vim --version, fail build if it fails
$TARGET/vim --version
git commit -m "Update vim for $SUBDIR

vim --version:

$("$DDIR/$TARGET/vim" --version | indent)
$COMMIT_MESSAGE_FOOTER"
