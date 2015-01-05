#!/usr/bin/env python
# vim:fileencoding=utf-8:noet
from __future__ import (unicode_literals, division, absolute_import, print_function)

import sys

from difflib import ndiff

def str_to_lines(s):
	ret = []
	for line in s.splitlines(1):
		if isinstance(line, bytes):
			line = line.decode('utf-8')
		if not line.endswith('\n'):
			line = line + '\n'
		ret.append(line)
	return ret

if sys.version_info < (3,):
	def main(a, b):
		sys.stdout.write((''.join(ndiff(str_to_lines(a), str_to_lines(b)))).encode('utf-8'))
else:
	def main(a, b):
		sys.stdout.write(''.join(ndiff(str_to_lines(a), str_to_lines(b))))

if __name__ == '__main__':
	main(sys.argv[1], sys.argv[2])
