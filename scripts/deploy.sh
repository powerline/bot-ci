#!/bin/sh
. scripts/common/main.sh
cd deps
ATTEMPTS=5
while test $ATTEMPTS -gt 0 ; do
	if git push origin master:master ; then
		FAILED=0
		break
	else
		FAILED=1
		ATTEMPTS=$(( ATTEMPTS - 1 ))
	fi
	git checkout --detach
	git fetch --force origin master:origin-master
	git checkout origin-master
	git merge \
		--strategy recursive --strategy-option theirs \
		--no-ff --commit \
		-m "Merge branch '${BRANCH_NAME}' into master" "${BRANCH_NAME}"
	git branch -f master
done
exit $FAILED
