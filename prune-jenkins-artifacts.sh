#!/usr/bin/env bash

JENKINS_HOME="${JENKINS_HOME:-$1}"

find "$JENKINS_HOME/jobs" -mtime +7 -path "*/builds/[0-9]*/artifacts" -print0 | xargs -0i rm -rf {}