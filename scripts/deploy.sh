#!/bin/sh
set -e
cd deps
git fetch origin master:origin-master
git checkout origin-master
git merge --no-ff --commit -m 'Merge' master
git branch -f master
git push origin master:master
