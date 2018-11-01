#! /bin/bash

WD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

git clone https://github.com/rjust/defects4j.git $WD/defects4j
git clone https://github.com/squaresLab/genprog4java.git $WD/genprog4java
git clone https://github.com/squaresLab/GenProgScripts.git $WD/GenProgScripts
git clone https://github.com/SLP-team/SLP-Core.git $WD/SLP-Core

mkdir $WD/GenProgScripts/errors

cd $WD/defects4j
yes | cpan App::cpanminus && cpanm --installdeps $WD/defects4j
./init.sh
cd $WD

cd $WD/SLP-Core
mvn clean install
cd $WD

cd $WD/genprog4java
mvn package
cd $WD

cp -r changedFile/* $WD
