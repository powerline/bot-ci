#!/bin/sh
. scripts/common/main.sh
cd deps
git fetch origin master:origin-master
git checkout origin-master
git merge --no-ff --commit -m "Merge branch '${BRANCH_NAME}' into master" "${BRANCH_NAME}"
git branch -f master
git push origin master:master
