#!/bin/sh
. scripts/common/main.sh
set -x
i=1
while eval test -n "\"\$SCRIPT$i\"" ; do
	eval \$SCRIPT$i
	i=$(( i + 1 ))
done
