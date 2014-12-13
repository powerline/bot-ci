#!/bin/sh
. scripts/common/main.sh

mkdir -p deps/vim-plugins
mkdir -p build/vim-plugins

cd build/vim-plugins

echo -n "\
capslock  https://github.com/tpope/vim-capslock
syntastic https://github.com/scrooloose/syntastic
tagbar    https://github.com/majutsushi/tagbar
nerdtree  https://github.com/scrooloose/nerdtree
ctrlp     https://github.com/kien/ctrlp.vim
" | while read name url ; do
	git clone --depth=1 "$url" "$name"
	cd "$name"
	HEAD="$(git show --no-patch HEAD)"
	mv .git "../.git-${name}"
	cd ..
	echo ">>> $name"
	tar cvf "$ROOT/deps/vim-plugins/${name}.tar.gz" "${name}"
	mv ".git-${name}" "${name}/.git"
	(
		cd $ROOT/deps
		git add "vim-plugins/${name}.tar.gz"
		git commit -m "Update vim plugin $name$(echo;echo;echo "${HEAD}"|indent)"
	)
done
