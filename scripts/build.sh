#!/bin/sh
. scripts/common/main.sh
set -x
printf '%s' "$SCRIPTS" | tr ';' '\n' | while read -r script ; do
	eval "$script"
done

cd deps
git fetch origin master:origin-master
git checkout origin-master
git merge \
	--strategy recursive --strategy-option theirs \
	--no-ff --commit \
	-m "Merge branch '${BRANCH_NAME}' into master" "${BRANCH_NAME}"
git branch -f master
