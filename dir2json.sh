#!/bin/bash

#
# Generates JSON file representation of a directory
#
# To interact with JSON filesystem use JsonFS (https://gist.github.com/bng44270/183eed06ec1bda30535278e36e1295cb)
#

FILETEMPLATE='"FILENAME":{"content":"FILECONTENT","modified":"MODDATE","size":FILESIZE}'

parsefile() {
	FILE="$@"
	if [ -f $FILE ]; then
		CONTENT="$(base64 < $FILE | tr -d '\n' | sed 's/\//\\\//g')"
		sed 's/FILENAME/'"$(basename $FILE)"'/g;s/FILECONTENT/'"$CONTENT"'/g;s/MODDATE/'"$(date -r $FILE)"'/g;s/FILESIZE/'"$(wc -c $FILE | awk '{ print $1 }')"'/g' <<< "$FILETEMPLATE"
	fi
}

parsedirectory() {
	DIR="$@"
	if [ -d $DIR ]; then
		printf "\"$(basename $DIR)\":{"
		ls $DIR/* -d | while read item; do
			if [ -z "$item" ]; then
				continue
			elif [ -d $item ]; then
				printf "$(parsedirectory $item),"
			elif [ -f $item ]; then
				printf "$(parsefile $item),"
			fi
		done | sed 's/,$/}/g'
	fi
}

getargs() {
	echo "$@" | sed 's/[ \t]*\(-[a-zA-Z][ \t]\+\)/\n\1/g' | awk '/^-/ { printf("ARG_%s=\"%s\"\n",gensub(/^-([a-zA-Z]).*$/,"\\1","g",$0),gensub(/^-[a-zA-Z][ \t]+(.*)[ \t]*$/,"\\1","g",$0)) }' | sed 's/""/"EMPTY"/g'
}

eval $(getargs "$@")

if [ -z "$ARG_d" ] && [ -z "$ARG_f" ]; then
	echo "usage: dir2json.sh -d <directory> -f <JSON-file>"
else
	printf "{" > $ARG_f
	printf "\"type\":\"jsonfs\",\"fs\":{" >> $ARG_f
	parsedirectory $ARG_d >> $ARG_f
	printf "}}" >> $ARG_f
fi