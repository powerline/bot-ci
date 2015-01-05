use-virtual-env() {
	local name="$1"
	local prefix="$2"
	local pysuf="$3"

	pip install virtualenvwrapper
	set +e
	. virtualenvwrapper.sh || exit 1
	set -e

	sudo apt-get install -qq zlib1g libssl1.0.0

	export PATH="$prefix/bin:$PATH"
	export LD_LIBRARY_PATH="$prefix/lib:$LD_LIBRARY_PATH"
	if ! lsvirtualenv -b | grep -xF "$name" ; then
		set +e
		mkvirtualenv -p "$prefix/bin/python$pysuf" "$name" || return 1
		set -e
	fi
}
