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
	local always="$ALWAYS_BUILD"
	if test "x$1" = "x--always" ; then
		always=1
		shift
	fi
	local onlycheck=""
	if test "x$1" = "x--onlycheck" ; then
		onlycheck=1
		shift
	fi
	local dir="$1"
	local vcs="$2"
	local url="$3"
	local rev="$4"

	export VERSION_UPDATED="$(test -n "$ALWAYS_BUILD" && echo 1 || echo 0)"
	if echo "$ALWAYS_BUILD_DEP" | grep -q ":${dir}:" ; then
		always=1
		export VERSION_UPDATED=1
	fi

	local old_version=
	local new_version=
	mkdir -p "$DDIR"/versions
	local version_file="$DDIR/versions/$(echo "$dir" | sed -r 's/[^A-Za-z0-9-]+/-/g')"
	if test -e $version_file ; then
		old_version="$(cat "$version_file")"
	fi
	case $vcs in
		git)
			new_version="$(git ls-remote "$url" ${rev:-HEAD} | cut -f1)"
			;;
		mercurial)
			if ! test -d "$BDIR/empty_hg_repository" ; then
				mkdir -p "$BDIR"
				hg init "$BDIR/empty_hg_repository"
			fi
			new_version="$(hg -R "$BDIR/empty_hg_repository" incoming --limit=1 --newest-first --template='{node}' --quiet --rev=${rev:-default} "$url")"
			;;
		bzr)
			new_version="$(bzr log --limit=1 --show-ids "$url" | grep '^revision-id:' | cut -d' ' -f2)"
			;;
	esac
	if test "$new_version" != "$old_version" ; then
		export VERSION_UPDATED=1
	fi
	if test -n "$onlycheck" ; then
		return 0
	fi
	if test "$new_version" != "$old_version" || test -n "$always" ; then
		echo "$new_version" > "$version_file"
		export TARGET="$dir"
		export OPT_DIRECTORY="/opt/$(basename "$dir")"
		export BUILD_DIRECTORY="$BDIR/$dir"
		(
			mkdir -p "$DDIR/$dir"
			cd "$DDIR"
			git add "$version_file"
			mkdir -p "$BDIR_DIRECTORY"
			case $vcs in
				(git)
					local branch_arg=
					if test -n "$rev" ; then
						branch_arg="--branch=$rev"
					fi
					git clone --depth=1 $branch_arg "$url" "$BDIR/$dir"
					;;
				(mercurial)
					hg clone --rev=$new_version --updaterev=$new_version "$url" "$BDIR/$dir"
					;;
				(bzr)
					bzr checkout --lightweight --revision="$new_version" "$url" "$BDIR/$dir"
					;;
			esac
		)
		COMMIT_MESSAGE_FOOTER="$COMMIT_MESSAGE_FOOTER$NL$dir tip:$NL$NL$(get_${vcs}_tip "$BDIR/$dir" | indent)$NL"
	else
		exit 0
	fi
}

ensure_opt() {
	local ddir="$1"
	local name="$2"
	export OPT_DIRECTORY="/opt/$name"
	if ! test -d "$OPT_DIRECTORY" ; then
		(
			cd /opt
			sudo tar xzf "$DDIR/$ddir/${name}.tar.gz"
		)
	fi
}

commit_opt_archive() {
	local opt_dir="$1"
	local target="$2"
	local message="$3"
	(
		cd "$DDIR"
		tar czf ${target}.tar.gz -C "$(dirname "$opt_dir")" "$(basename "$opt_dir")"
		git add ${target}.tar.gz
		git commit -m "$message"
	)
}
