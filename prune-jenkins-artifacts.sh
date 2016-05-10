#!/usr/bin/env bash

JENKINS_HOME="${JENKINS_HOME:-"$1"}"

if [[ ! -d "$JENKINS_HOME" ]]; then
	>&2 echo "JENKINS_HOME is not set."
	exit 1
fi


tmpfile=$(mktemp)
find "$JENKINS_HOME/jobs" -mtime +10 -path "*/builds/[0-9]*/artifacts" > "$tmpfile"

while read line; do
	if [[ -z "$line" || ! -d "$line"  || "$line" == "." || "$line" == ".." || "$line" == "/" ]]; then
		continue
	fi
	rm -rf "$line"
done < <(cat "$tmpfile")