#!/bin/sh
. scripts/common/main.sh
. scripts/common/build.sh

echo -n "\
capslock  https://github.com/tpope/vim-capslock
syntastic https://github.com/scrooloose/syntastic
tagbar    https://github.com/majutsushi/tagbar
nerdtree  https://github.com/scrooloose/nerdtree
ctrlp     https://github.com/kien/ctrlp.vim
" | while read name url ; do
	(
		prepare_build vim-plugins/"$name" git "$url"
		cd "$name"
		mv .git "../.git-${name}"
		cd ..
		echo ">>> $name"
		tar cvf "$DEPS/${TARGET}.tar.gz" "${name}"
		mv ".git-${name}" "${name}/.git"
		cd "$DEPS"
		git add "${TARGET}.tar.gz"
		git commit -m "Update vim plugin $name$NL$COMMIT_MESSAGE_FOOTER"
	)
done
