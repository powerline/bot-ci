use-virtual-env() {
	local name="$1"
	local prefix="$2"
	local pysuf="$3"
	local addpypath="$4"

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
	else
		set +e
		workon "$name"
		set -e
	fi
	if test -n "$addpypath" ; then
		main_path="$prefix/lib/python$pysuf"
		site_path="$main_path/site-packages"
		export PYTHONPATH="${main_path}:${site_path}${PYTHONPATH:+:}$PYTHONPATH"
		venv_main_path="$VIRTUAL_ENV/lib/python$pysuf"
		venv_site_path="$venv_main_path/site-packages"
		export PYTHONPATH="${venv_main_path}:${venv_site_path}:$PYTHONPATH"
	fi
}
