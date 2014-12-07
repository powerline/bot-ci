#!/bin/sh

sudo apt-get install mercurial

chmod 0600 keys/id_rsa
cp keys/id_rsa ~/.ssh
git clone ssh://git@github.com/powerline/deps

git config --global user.name 'Travis CI bot'
git config --global user.email 'bot@example.com'
