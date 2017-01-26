#!/bin/sh
. scripts/common/main.sh
. scripts/common/build.sh

prepare_build fish/fish --url git://github.com/fish-shell/fish-shell

cd "${BUILD_DIRECTORY}"
if cd pcre2* ; then
	autoreconf
	cd ..
fi
sed -r -i -e '/AC_CONFIG_MACRO_DIRS/d' ./configure.ac
autoreconf --version
autoreconf --no-recursive
./configure --prefix="$OPT_DIRECTORY"
make
./fish --version
make install

commit_opt_archive "$OPT_DIRECTORY" "$TARGET" \
"Update fish
$COMMIT_MESSAGE_FOOTER"
