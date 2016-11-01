#!/bin/sh
PREF=${1}${1+-}
. scripts/common/main.sh
. scripts/common/build.sh

PYTHON_SUFFIX=${PREF}${PYTHON_SUFFIX}

mkdir -p "$BDIR/wheels/$PYTHON_SUFFIX"
mkdir -p "$DDIR/wheels/$PYTHON_SUFFIX"
cd "$BDIR/wheels/$PYTHON_SUFFIX"
pip install wheel
WHEEL_ARGS="psutil netifaces python-hglib"
OLD_PEXPECT="pexpect==3.3"

if test "$PYTHON_VERSION_MAJOR" -eq 2 ; then
	if test "$PYTHON_IMPLEMENTATION" = "CPython" ; then
		WHEEL_ARGS="${WHEEL_ARGS} mercurial --allow-external bzr --allow-unverified bzr bzr"
	fi
	if test "$PYTHON_VERSION_MINOR" -ge 7 ; then
		WHEEL_ARGS="${WHEEL_ARGS} pexpect ipython"
		if test "x${PREF}" '!=' "x" ; then
			WHEEL_ARGS="${WHEEL_ARGS} virtualenvwrapper"
		fi
	elif test "$PYTHON_VERSION_MINOR" -lt 7 ; then
		WHEEL_ARGS="${WHEEL_ARGS} ${OLD_PEXPECT} unittest2 argparse"
		if test "x${PREF}" '!=' "x" ; then
			WHEEL_ARGS="${WHEEL_ARGS} virtualenvwrapper==4.6.0"
		fi
	fi
else
	if test "$PYTHON_VERSION_MINOR" -ge 3 ; then
		WHEEL_ARGS="${WHEEL_ARGS} pexpect ipython"
	else
		WHEEL_ARGS="${WHEEL_ARGS} ${OLD_PEXPECT}"
	fi
fi
pip wheel --wheel-dir . $WHEEL_ARGS
if test "$PYTHON_IMPLEMENTATION" = "CPython" ; then
	pip wheel --wheel-dir . pyuv || true
fi

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
	OLD_LIST="$(dir -1 .)"
	cd ..
fi
PY_SUF_PART="${PREF}${PYTHON_IMPLEMENTATION}-${PYTHON_MM}"
for dir in $PY_SUF_PART $PY_SUF_PART* ; do
	git rm -r --ignore-unmatch --cached "$dir"
	rm -rf "$dir"
done
mkdir "$PYTHON_SUFFIX"
cd "$PYTHON_SUFFIX"
cp --target=. "$BDIR/wheels/$PYTHON_SUFFIX"/*.whl
NEW_LIST="$(dir -1 .)"

DIFF="$(python "$ROOT"/scripts/ndiff-strings.py "$OLD_LIST" "$NEW_LIST" | indent)"

git add .
git commit -m "Update Python wheels for ${PREF}$PYTHON_IMPLEMENTATION version $PYTHON_VERSION

WHEEL_ARGS='$WHEEL_ARGS'

diff:

$DIFF"
