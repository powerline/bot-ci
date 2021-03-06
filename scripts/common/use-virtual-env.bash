use-virtual-env() {
	local name="$1"
	local prefix="$2"
	local pysuf="$3"
	local addpypath="$4"

	local piparg="virtualenvwrapper"
	if test "$pysuf" = "2.6" ; then
		piparg="virtualenvwrapper==4.6.0"
	fi

	pip install $piparg
	set +e
	. virtualenvwrapper.sh || exit 1
	set -e

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
	pip install $piparg
	# XXX To filter all paths containing python `s/:?` needs to be used. This
	#     variant (without question mark) does not filter out the very first 
	#     path.
	export PATH="$(echo "$PATH" | sed -r -e 's@:[^:]*(python/?2|2\.[67]|pypy)[^:]*@:@g; s/:+/:/g; s/^://; s/:$//;')"
	if test -n "$addpypath" ; then
		main_path="$prefix/lib/python$pysuf"
		site_path="$main_path/site-packages"
		export PYTHONPATH="${main_path}:${site_path}${PYTHONPATH:+:}$PYTHONPATH"
		venv_main_path="$VIRTUAL_ENV/lib/python$pysuf"
		venv_site_path="$venv_main_path/site-packages"
		export PYTHONPATH="${venv_main_path}:${venv_site_path}:$PYTHONPATH"
	fi

	. "$(dirname ${BASH_SOURCE})"/main.sh
}
