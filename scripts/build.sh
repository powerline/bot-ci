#!/bin/sh
. scripts/common/main.sh
set -x
while eval test -n "\"\$SCRIPT$i\"" ; do
	eval \$SCRIPT$i
done
