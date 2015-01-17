#!/bin/sh
. scripts/common/main.sh
. scripts/common/build.sh

echo -n "\
capslock  git://github.com/tpope/vim-capslock
syntastic git://github.com/scrooloose/syntastic
tagbar    git://github.com/majutsushi/tagbar
nerdtree  git://github.com/scrooloose/nerdtree
ctrlp     git://github.com/kien/ctrlp.vim
" | while read name url ; do
	(
		prepare_build vim-plugins/"$name" --url "$url"
		cd "$BUILD_DIRECTORY"
		mv .git "../.git-${name}"
		cd ..
		echo ">>> $name"
		tar czvf "$DDIR/${TARGET}.tar.gz" "${name}"
		mv ".git-${name}" "${name}/.git"
		cd "$DDIR"
		git add "${TARGET}.tar.gz"
		git commit -m "Update vim plugin $name$NL$COMMIT_MESSAGE_FOOTER"
	)
done
