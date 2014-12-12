#!/bin/sh
. scripts/common/main.sh

sudo apt-get install -qq bzr

chmod 0600 keys/id_rsa
cp keys/id_rsa ~/.ssh
git clone ssh://git@github.com/powerline/deps
(cd deps && git checkout -b "${BRANCH_NAME}")

git config --global user.name 'Travis CI bot'
git config --global user.email 'bot@example.com'
git config --global push.default simple
