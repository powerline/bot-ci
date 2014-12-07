#!/bin/sh
. scripts/common/main.sh
set -x
i=1
while eval test -n "\"\$SCRIPT$i\"" ; do
	eval \$SCRIPT$i
	i=$(( i + 1 ))
done

cd deps
git fetch origin master:origin-master
git checkout origin-master
git merge --strategy recursive --strategy-option theirs --no-ff --commit -m "Merge branch '${BRANCH_NAME}' into master" "${BRANCH_NAME}"
git branch -f master
