#!/bin/sh
. scripts/common/main.sh
PYTHON_SUFFIX="${PYTHON_IMPLEMENTATION}-${PYTHON_VERSION}"
mkdir deps/wheels-$PYTHON_SUFFIX
cd deps/wheels-$PYTHON_SUFFIX
sudo pip install wheel
WHEEL_ARGS="psutil netifaces"
if test "$PYTHON_VERSION_MAJOR" -eq 2 ; then
	if test "$PYTHON_IMPLEMENTATION" = "CPython" ; then
		WHEEL_ARGS="${WHEEL_ARGS} mercurial --allow-external bzr --allow-unverified bzr bzr"
	fi
	if test "$PYTHON_VERSION_MINOR" -ge 7 ; then
		WHEEL_ARGS="${WHEEL_ARGS} ipython"
	elif test "$PYTHON_VERSION_MINOR" -lt 7 ; then
		WHEEL_ARGS="${WHEEL_ARGS} unittest2 argparse"
	fi
else
	if test "$PYTHON_VERSION_MINOR" -ge 3 ; then
		WHEEL_ARGS="${WHEEL_ARGS} ipython"
	fi
fi
pip wheel $WHEEL_ARGS
git add wheelhouse
git commit wheelhouse -m "Create Python wheels for $PYTHON_IMPLEMENTATION version $PYTHON_VERSION

WHEEL_ARGS='$WHEEL_ARGS'"
