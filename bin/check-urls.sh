#!/bin/sh

if [ $# -eq 0 ]; then
	echo "Usage: $0 collection.txt ..."
	exit 1
fi

if command -v ${HTTPX:-httpx} >/dev/null 2>&1; then
	grep -Eiho "https?://[^\"\\'> ]+" "$@" |
		${HTTPX} -sc -fc 200 -p 80,443 -retries 3 -fr -fhr
else
	grep -Eiho "https?://[^\"\\'> ]+" |
		xargs -r -P10 -I{} \
		curl -I -o /dev/null -sw "[%{http_code}] %{url}\n" '{}' |
		grep -v '^\[200\]' | sort -u
fi

# End of file.
