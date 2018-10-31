#! /bin/bash

process_bug() {
        if [ -e $DEST/$1 ]; then
                rm -rf $DEST/$1
        fi
        mkdir $DEST/$1
        cp $ROOT/defects4j/D4JwithGP/$1/genprog.log $DEST/$1
        cp $ROOT/defects4j/D4JwithGP/$1/log* $DEST/$1
        for seed in $ROOT/defects4j/D4JwithGP/$1/variants*/; do
                cp -r $seed $DEST/$1
        done
}

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DEST=$1

if [ ! -e $DEST ]; then
        mkdir $DEST
fi

if [ ! -e $DEST/errors ]; then
        mkdir $DEST/errors
fi

cp  $ROOT/GenProgScripts/errors/* $DEST/errors
export -f process_bug
export ROOT=$ROOT
export DEST=$DEST
ls $ROOT/defects4j/D4JwithGP | xargs -n1 -P32 -I% bash -c 'process_bug %'



