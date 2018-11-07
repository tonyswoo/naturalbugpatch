#! /bin/bash

# $1 is true if using entropy
# $2 starting seed number
# $3 is true if using humanInjected fault localization
export SCRIPTS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
export INSTALLED=$SCRIPTS/..
export D4J_HOME=$INSTALLED/defects4j
export GP4J_HOME=$INSTALLED/genprog4java
export JAVA7_HOME=/usr/lib/jvm/java-7-openjdk-amd64
export JAVA8_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export JAVA9_HOME=/usr/lib/jvm/java-9-openjdk-amd64
export JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8"

$SCRIPTS/getBugs.sh | xargs -n1 -P16 -I% bash -c "$SCRIPTS/runBug.sh % $1 $2 $3"
