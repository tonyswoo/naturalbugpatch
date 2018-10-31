#! /bin/bash

WD=$D4J_HOME/D4JwithGP
PATHTOBUG=defects4j/D4JwithGP

while [ $# -gt 0 ]; do
	for tarfile in $WD/$1/*.tar; do
		tar -xf $tarfile -C $WD/$1
		mv $WD/$1/$PATHTOBUG/$1/tmp ${tarfile%.tar}
		rm -rf $WD/$1/defects4j
	done
	shift
done

