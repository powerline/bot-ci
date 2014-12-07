#!/bin/sh
LIBRARY_PATH="$(ldd "$(which python)" | grep libpython | sed 's/^.* => //;s/ .*$//')"
LIBPYTHON_NAME="$(basename "${LIBRARY_PATH}")"
PYTHON_SUFFIX="$(echo "${LIBPYTHON_NAME}" | sed -r 's/^libpython(.*)\.so.*$/\1/')"
PYTHON_INCLUDE_DIR="/opt/python/${PYTHON_VERSION}/include/python$PYTHON_SUFFIX"
echo "${LIBRARY_PATH}"
echo "${LIBPYTHON_NAME}"
echo "${PYTHON_SUFFIX}"
test -e "$LIBRARY_PATH" || echo FALSE:library
test -d "$PYTHON_INCLUDE_DIR" || echo FALSE:include
test -e "$PYTHON_INCLUDE_DIR/Python.h" || echo FALSE:header
