set -e
set -x

: ${PYTHON:=python}

PYTHON_VERSION="$("$PYTHON" -c 'import platform; print(platform.python_version())')"
PYTHON_IMPLEMENTATION="$("$PYTHON" -c 'import platform; print(platform.python_implementation())')"
PYTHON_VERSION_MAJOR="${PYTHON_VERSION%%.*}"
PYTHON_VERSION_MINOR="${PYTHON_VERSION#?.}"
PYTHON_VERSION_MINOR="${PYTHON_VERSION_MINOR%.*}"

PYTHON_SUFFIX="${PYTHON_IMPLEMENTATION}-${PYTHON_VERSION}"
PYTHON_MM="${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}"

ROOT="${PWD:-$(pwd)}"
DDIR="$ROOT/deps"
BDIR="$ROOT/build"

BRANCH_NAME="travis-${TRAVIS_JOB_NUMBER}"

# HACK: get newline for use in strings given that "\n" and $'' do not work.
NL="$(printf '\nE')"
NL="${NL%E}"
