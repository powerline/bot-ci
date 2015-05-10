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

get_version_file_name() {
	local dir="$1"
	echo "$DDIR/versions/$(echo "$dir" | sed -r 's/[^A-Za-z0-9.-]+/-/g')"
}

_get_version() {
	local vcs="$1"
	local url="$2"
	local rev="$3"
	local embedded_python="$4"
	shift 4

	case "$vcs" in
		(git)
			git ls-remote "$url" "$rev" | \
				cut -f1
			;;
		(mercurial)
			hg identify --rev="$rev" "$url"
			;;
		(bzr)
			bzr log --limit=1 --show-ids "$url" | \
				grep '^revision-id:' | cut -d' ' -f2
			;;
	esac
	local dep
	for dep in "$@" ; do
		shift
		if test "x$dep" = "x--" ; then
			break
		fi
		local dep_file="$(get_version_file_name $dep)"
		if ! test -e "$dep_file" ; then
			echo "File $dep_file was not found" >&2
			return 1
		fi
		echo "${dep}:"
		cat $dep_file | sed 's/^/    /'
	done
	if test $# -gt 0 ; then
		echo "$@:"
		prepare_build --version "$@" | sed 's/^/    /'
	fi
	if test "$embedded_python" -ne 0 ; then
		echo "Python: $PYTHON_VERSION"
	fi
}

get_version() {
	local var="$1"
	shift
	local ret="$(_get_version "$@" || echo "--FAIL--")"
	if test "${ret%--FAIL--}" != "${ret}" ; then
		return 1
	fi
	eval $var='"$ret"'
}

vcs_checkout() {
	local vcs=$1
	local rev="$2"
	local url="$3"
	local target="$4"

	mkdir -p "$BUILD_DIRECTORY"

	case $vcs in
		(git)
			local branch_arg=
			if test "$rev" != "HEAD" ; then
				branch_arg="--branch=$rev"
			fi
			git clone --depth=1 $branch_arg "$url" "$target"
			;;
		(mercurial)
			hg clone --rev="$rev" --updaterev="$rev" "$url" "$target"
			;;
		(bzr)
			bzr checkout --lightweight --revision="$rev" "$url" "$target"
			;;
	esac
}

prepare_build() {
	local only_print_version=
	if test "x$1" = "x--version" ; then
		shift
		only_print_version=1
	fi

	local dir="$1" vcs= url= rev= deps= other= embedded_python=0
	shift
	while test "$#" -gt 0 ; do
		case "$1" in
			(--vcs) vcs="$2" ; shift 2 ;;
			(--url) url="$2" ; shift 2 ;;
			(--rev) rev="$2" ; shift 2 ;;
			(--depends) deps="$deps $2" ; shift 2 ;;
			(--also-build) other="$2" ; shift 2 ;;
			(--embedded-python) embedded_python=1 ; shift ;;
			(*)
				echo "Unknown argument: $1"
				echo "Remaining args: $@"
				return 1
				;;
		esac
	done
	if test -z "$vcs" ; then
		case "$url" in
			(git://*)     vcs=git ;;
			(*)           vcs=mercurial ;;
		esac
	fi
	if test -z "$rev" ; then
		case "$vcs" in
			(git)       rev=HEAD ;;
			(mercurial) rev=default ;;
			(bzr)       rev= ;;
		esac
	fi

	local new_version=
	get_version new_version "$vcs" "$url" "$rev" "$embedded_python" $deps -- $other

	if test -n "$only_print_version" ; then
		echo "$new_version"
		return 0
	fi

	local old_version=
	mkdir -p "$DDIR"/versions
	local version_file="$(get_version_file_name "$dir")"
	if test -e $version_file ; then
		old_version="$(cat "$version_file")"
	fi

	local always="$ALWAYS_BUILD"
	local other_dep="$(echo "$other" | cut -d' ' -f1)"
	for dep in $deps $dir $other_dep ; do
		if test "${ALWAYS_BUILD_DEP#*:${dep}:}" != "$ALWAYS_BUILD_DEP" ; then
			always=1
		fi
	done

	if test "$new_version" != "$old_version" || test -n "$always" ; then
		echo "$new_version" > "$version_file"
		TARGET="$dir"
		OPT_DIRECTORY="$HOME/opt/$(basename "$dir")"
		BUILD_DIRECTORY="$BDIR/$dir"
		(
			mkdir -p "$DDIR/$dir"
			cd "$DDIR"
			git add "$version_file"
		)
		vcs_checkout $vcs "$rev" "$url" "$BUILD_DIRECTORY"
		COMMIT_MESSAGE_FOOTER="$COMMIT_MESSAGE_FOOTER$NL$dir tip:$NL$NL$(get_${vcs}_tip "$BUILD_DIRECTORY" | indent)$NL"
	else
		exit 0
	fi

	if test -n "$other" ; then
		FIRST_TARGET="$TARGET"
		FIRST_OPT_DIRECTORY="$OPT_DIRECTORY"
		FIRST_BUILD_DIRECTORY="$BUILD_DIRECTORY"
		prepare_build $other --depends $dir
		SECOND_TARGET="$TARGET"
		SECOND_OPT_DIRECTORY="$OPT_DIRECTORY"
		SECOND_BUILD_DIRECTORY="$BUILD_DIRECTORY"
	fi
}

ensure_opt() {
	local ddir="$1"
	local name="$2"
	OPT_DIRECTORY="$HOME/opt/$name"
	if ! test -d "$OPT_DIRECTORY" ; then
		(
			cd $HOME/opt
			tar xzf "$DDIR/$ddir/${name}.tar.gz"
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
