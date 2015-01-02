#!/bin/bash
REV=$1
. scripts/common/main.sh
. scripts/common/build.sh

ensure_opt cpython-ucs2 cpython-ucs2-$REV

pip install virtualenvwrapper
set +e
. virtualenvwrapper.sh || exit 1
set -e

PREFIX="$OPT_DIRECTORY"

sudo apt-get install -qq zlib1g libssl1.0.0

export PATH="$PREFIX/bin:$PATH"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
set +e
mkvirtualenv -p $PREFIX/bin/python$REV python-ucs2-$REV || exit 1
set -e

pip install wheel
pwd
cd "$ROOT"
"$ROOT"/scripts/create-wheels.sh ucs2
