. $HOME/.rvm/scripts/rvm

ruby_setup() {
	rvm system
	export PATH="$( \
		printf '%s:/X' "$PATH" \
		| tr ':' '\0' \
		| grep -zv ruby \
		| head -c-1 \
		| tr '\0' ':')"
	export PATH="${PATH%:/X}"
}
