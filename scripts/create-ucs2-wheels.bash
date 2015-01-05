#!/bin/bash
REV=$1
. scripts/common/main.sh
. scripts/common/build.sh
. scripts/common/use-virtual-env.bash

ensure_opt cpython-ucs2 cpython-ucs2-$REV

use-virtual-env cpython-ucs2-$REV "$OPT_DIRECTORY" $REV

pip install wheel
pwd
cd "$ROOT"
"$ROOT"/scripts/create-wheels.sh ucs2
