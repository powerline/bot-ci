set -e

: ${PYTHON:=python}

PYTHON_VERSION="$("$PYTHON" -c 'import platform; print(platform.python_version())')"
PYTHON_IMPLEMENTATION="$("$PYTHON" -c 'import platform; print(platform.python_implementation())')"
PYTHON_VERSION_MAJOR="${PYTHON_VERSION%%.*}"
PYTHON_VERSION_MINOR="${PYTHON_VERSION#?.}"
PYTHON_VERSION_MINOR="${PYTHON_VERSION_MINOR%.*}"

PYTHON_SUFFIX="${PYTHON_IMPLEMENTATION}-${PYTHON_VERSION}"

ROOT="${PWD:-$(pwd)}"

BRANCH_NAME="travis-${TRAVIS_JOB_NUMBER}"
