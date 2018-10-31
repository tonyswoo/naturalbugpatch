#! /bin/bash

WD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

git clone https://github.com/rjust/defects4j.git
git clone https://github.com/squaresLab/genprog4java.git
git clone https://github.com/squaresLab/GenProgScripts.git
git clone https://github.com/SLP-team/SLP-Core.git

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
