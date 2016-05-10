#!/usr/bin/env bash

while getopts ":b:v:" opt; do
	case $opt in;
		b) build="b${OPTARG/#b}"
			;;
		v) version="$OPTARG"
			;;
		\?) 
			echo "Invalid option: $OPTARG"
			exit 1
			;;
	esac
done

base="https://edelivery.oracle.com/otn-pub/java/jdk/${version}-${build}/jdk-${version}"
cookie="gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie"

curl --location --remote-name --header "Cookie: ${cookie}" --insecure "${base}-windows-x64.exe"
curl --location --remote-name --header "Cookie: ${cookie}" --insecure "${base}-windows-i586.exe"