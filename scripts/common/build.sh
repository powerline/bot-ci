indent() {
	sed 's/^/    /'
}

get_git_tip() {
	(
		cd $1
		git show --no-patch
	)
}

get_mercurial_tip() {
	hg log -R "$1" --limit=1 --rev=.
}

get_bzr_tip() {
	bzr log --limit=1 --show-ids "$1"
}

prepare_build() {
	local always=
	if test "x$1" = "x--always" ; then
		always=1
		shift
	fi
	local dir="$1"
	local vcs="$2"
	local url="$3"
	local rev="$4"

	local old_version=
	local new_version=
	mkdir -p $ROOT/deps/versions
	local version_file="$ROOT/deps/versions/$(echo "$dir" | sed -r 's/[^A-Za-z0-9-]+/-/g')"
	if test -e $version_file ; then
		old_version="$(cat "$version_file")"
	else
		mkdir -p $ROOT/deps/$dir
	fi
	case $vcs in
		git)
			new_version="$(git ls-remote "$url" ${rev:-HEAD} | cut -f1)"
			;;
		mercurial)
			if ! test -d $ROOT/build/empty_hg_repository ; then
				mkdir -p $ROOT/build
				hg init $ROOT/build/empty_hg_repository
			fi
			new_version="$(hg -R "$ROOT/build/empty_hg_repository" incoming --limit=1 --newest-first --template='{node}' --quiet --rev=${rev:-default} "$url")"
			;;
		bzr)
			new_version="$(bzr log --limit=1 --show-ids "$url" | grep '^revision-id:' | cut -d' ' -f2)"
			;;
	esac
	export VERSION_UPDATED=0
	if test "$new_version" != "$old_version" ; then
		export VERSION_UPDATED=1
	fi
	if test "$new_version" != "$old_version" || test -n "$always" ; then
		echo "$new_version" > "$version_file"
		(
			cd "$ROOT/deps"
			git add "$version_file"
			mkdir -p "$ROOT/build/$dir"
			case $vcs in
				(git)
					local branch_arg=
					if test -n "$rev" ; then
						branch_arg="--branch=$rev"
					fi
					git clone --depth=1 $branch_arg "$url" "$ROOT/build/$dir"
					;;
				(mercurial)
					hg clone --rev=$new_version --updaterev=$new_version "$url" "$ROOT/build/$dir"
					;;
				(bzr)
					bzr checkout --lightweight --revision="$new_version" "$url" "$ROOT/build/$dir"
					;;
			esac
		)
		COMMIT_MESSAGE_FOOTER="$COMMIT_MESSAGE_FOOTER$NL$dir tip:$NL$NL$(get_${vcs}_tip "$ROOT/build/$dir" | indent)$NL"
	else
		exit 0
	fi
}
