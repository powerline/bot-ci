#!/bin/sh
REV=$1
. scripts/common/main.sh
. scripts/common/build.sh

prepare_build cpython-ucs2/cpython-ucs2-$REV \
	--url http://hg.python.org/cpython \
	--rev $REV

cd "${BUILD_DIRECTORY}"
sed -r -i -e 's@^(\s*)('\''/lib64)@\1"/usr/lib/x86_64-linux-gnu",\2@' setup.py
hg diff
./configure --enable-unicode=ucs2 --prefix="${OPT_DIRECTORY}" --enable-shared
make
make install
# Sanity check: run python --version, fail build if it fails
env LD_LIBRARY_PATH="$OPT_DIRECTORY"/lib "$OPT_DIRECTORY"/bin/python$REV --version
cd "$DDIR"

(
	export LD_LIBRARY_PATH="$OPT_DIRECTORY/lib"
	save_exe "$OPT_DIRECTORY/bin/python$REV"
)

commit_opt_archive "$OPT_DIRECTORY" "$TARGET" \
"Update ucs2 cpython-$REV build

python --version:

$(env LD_LIBRARY_PATH="$OPT_DIRECTORY"/lib "$OPT_DIRECTORY"/bin/python$REV --version 2>&1 | indent)
$COMMIT_MESSAGE_FOOTER"
