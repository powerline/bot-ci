#!/bin/sh
. scripts/common/main.sh
. scripts/common/build.sh

mkdir -p build/vim-plugins

cd build/vim-plugins

echo -n "\
capslock  https://github.com/tpope/vim-capslock
syntastic https://github.com/scrooloose/syntastic
tagbar    https://github.com/majutsushi/tagbar
nerdtree  https://github.com/scrooloose/nerdtree
ctrlp     https://github.com/kien/ctrlp.vim
" | while read name url ; do
	prepare_build vim-plugins/"$name" git "$url"
	cd "$name"
	mv .git "../.git-${name}"
	cd ..
	echo ">>> $name"
	tar cvf "$ROOT/deps/vim-plugins/${name}.tar.gz" "${name}"
	mv ".git-${name}" "${name}/.git"
	(
		cd $ROOT/deps
		git add "vim-plugins/${name}.tar.gz"
		git commit -m "Update vim plugin $name$NL$COMMIT_MESSAGE_FOOTER"
	)
	COMMIT_MESSAGE_FOOTER=
done
