#!/usr/bin/env bash

JENKINS_HOME="${JENKINS_HOME:-$2}"
PLUGIN="$1"

find "$JENKINS_HOME" -iname config.xml -exec grep -l "$PLUGIN" {} \
