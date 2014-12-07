#!/bin/sh
set -e
cd deps
git pull origin master
git push origin master:master
