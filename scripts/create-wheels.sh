#!/bin/sh
PREF=${1}${1+-}
. scripts/common/main.sh
. scripts/common/build.sh

PYTHON_SUFFIX=${PREF}${PYTHON_SUFFIX}

mkdir -p "$BDIR/wheels/$PYTHON_SUFFIX"
mkdir -p "$DDIR/wheels/$PYTHON_SUFFIX"
cd "$BDIR/wheels/$PYTHON_SUFFIX"
sudo pip install wheel
WHEEL_ARGS="psutil netifaces pyuv"
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
pip wheel --wheel-dir . $WHEEL_ARGS

HAS_NEW_FILES=

if test -n "$ALWAYS_BUILD" ; then
	HAS_NEW_FILES=1
else
	for file in *.whl ; do
		if ! test -e "$DDIR/wheels/$PYTHON_SUFFIX/$file" ; then
			HAS_NEW_FILES=1
			break
		fi
	done
fi

if test -z "$HAS_NEW_FILES" ; then
	exit 0
fi

cd "$DDIR/wheels"
if test -d "$PYTHON_SUFFIX" ; then
	cd "$PYTHON_SUFFIX"
	export OLD_LIST="$(dir -1 .)"
	cd ..
fi
PY_SUF_PART="${PREF}${PYTHON_IMPLEMENTATION}-${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}"
for dir in $PY_SUF_PART $PY_SUF_PART* ; do
	git rm -r --ignore-unmatch --cached "$dir"
	rm -rf "$dir"
done
mkdir "$PYTHON_SUFFIX"
cd "$PYTHON_SUFFIX"
cp --target=. "$BDIR/wheels/$PYTHON_SUFFIX"/*.whl
export NEW_LIST="$(dir -1 .)"

DIFF="$(python "$ROOT"/scripts/ndiff-strings.py "$OLD_LIST" "$NEW_LIST" | indent)"

git add .
git commit -m "Update Python wheels for ${PREF}$PYTHON_IMPLEMENTATION version $PYTHON_VERSION

WHEEL_ARGS='$WHEEL_ARGS'

diff:

$DIFF"
