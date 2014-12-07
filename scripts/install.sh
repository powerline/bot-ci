#!/bin/sh

sudo apt-get install mercurial

chmod 0600 keys/id_rsa
cp keys/id_rsa ~/.ssh
git clone ssh://git@github.com/powerline/deps
