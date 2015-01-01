#!/bin/bash
REV=$1
. scripts/common/main.sh
. scripts/common/build.sh

ensure_opt cpython-ucs2 cpython-ucs2-$REV

pip install virtualenvwrapper
. virtualenvwrapper.sh

PREFIX=/opt/cpython-ucs2-$REV

export PATH=$PREFIX/bin:$PATH
export LD_LIBRARY_PATH=$PREFIX/lib
mkvirtualenv -p $PREFIX/bin/python$REV python-ucs2-$REV

pip install wheel
$ROOT/scripts/create-wheels.sh ucs2
