#! /bin/bash

D4J_HOME=$HOME/defects4j
export PATH=$PATH:$D4J_HOME/framework/bin

while [ $# -gt 0 ]; do
	defects4j checkout -p $1 -v ${2}b -w $1$2"buggy"
	defects4j checkout -p $1 -v ${2}f -w $1$2"fixed"

	if [ -e $1$2"tmp" ]; then
		rm $1$2"tmp"
	fi

	buggySourceDir=$(defects4j export -p dir.src.classes -w $1$2"buggy")
	fixedSourceDir=$(defects4j export -p dir.src.classes -w $1$2"fixed")

	diff -r $1$2"buggy"/$buggySourceDir/ $1$2"fixed"/$fixedSourceDir/ > $1$2"tmp"
	awk -v buggySourceDir=$1$2"buggy/"$buggySourceDir"/" '/^diff/ { 
			l=split($3, arr, "/")
			className=arr[l]
			filePath=substr($3, 1, length($3) - length(className) - 1) 
			sub(buggySourceDir, "", filePath)
			sub(".java", "", className)
		 }
		 /^[0-9]+/ {  
		 	split($1, arr, "a|c|d|,")
		 	print filePath "," className "," arr[1] 
		 }' $1$2"tmp" > $1$2"FaultLoc"
	rm -rf $1$2"tmp" $1$2"buggy" $1$2"fixed"
	shift 2

done
