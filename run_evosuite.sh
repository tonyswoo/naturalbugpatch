export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
export JRE_HOME=/usr/lib/jvm/java-7-openjdk-amd64/jre

POOL=/data/ktony11/$1
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
ORIGDIR=$pwd
RESULT=$1.result
EVOSUITE=$ROOT/test_suite
LOGFILE='evosuite'_$1'.log'
TESTFOLDER=testing$1


rm $RESULT $LOGFILE 2> /dev/null
export PATH=$PATH:$ROOT/defects4j/framework/bin

for bug in $POOL/*; do
        if [ $(ls $bug | grep variants | grep -v tar | wc -l) -gt 0 ]; then
                numRepairs=$(ls $bug/variants* | grep repair | grep -v repair.sanity | wc -l)
                if [ $numRepairs -gt 0 ]; then
			PROJECT=$(echo $(basename "$bug") | sed 's/Buggy$//' | sed 's/.*/\u&/' | sed 's/[0-9]//g')
			BUGNUM=$(echo $(basename "$bug") | sed 's/[a-zA-Z]//g')
			defects4j checkout -p $PROJECT -v $BUGNUM"b" -w $TESTFOLDER
			cd $TESTFOLDER
			SOURCEDIR=$(defects4j export -p dir.src.classes)
			TESTS=$(ls $EVOSUITE/$PROJECT/evosuite-branch/1/ | grep $PROJECT"-"$BUGNUM | grep -v '.bak')
			#if [ $(echo $TESTS | wc -l) -eq 0 ]; then
			#	perl $ROOT/defects4j/framework/bin/run_evosuite.pl -p $PROJECT -v $BUGNUM"f" -n 1 -o test_suite -c branch -b 1800
			#	perl $ROOT/defects4j/framework/util/fix_test_suite.pl -p $PROJECT -d $ROOT/test_suite/$PROJECT/evosuite-branch/1/ -v $BUGNUM"f"
			#	TESTS=$(ls $EVOSUITE/$PROJECT/evosuite-branch/1/ | grep $PROJECT"-"$BUGNUM | grep -v '.bak')
			#fi

			TESTS="$EVOSUITE/$PROJECT/evosuite-branch/1/$TESTS"

			# Fix special cases of sanity check fail bugs by replacing files
			if [[ "$PROJECT" == "Mockito"  && ( $BUGNUM -le 9 || ( $BUGNUM -ge 18 && $BUGNUM -le 20 ) ) ]] ; then
        			rm buildSrc/src/"test"/groovy/org/mockito/release/notes/NotesPrinterTest.groovy
        			if [ $BUGNUM -ne 9 ]; then
                			sed -i 's/org.spockframework:spock-core:0.7-groovy-2.0/org.spockframework:spock-core:0.7-groovy-1.8/g' $BUGWD/buildSrc/build.gradle
        		fi
			elif [ $PROJECT$BUGNUM == "Closure106" ]; then
        			cp $ROOT/defects4j/framework/projects/Closure/lib/junit.jar lib/junit.jar
			fi


			for seed in $bug/variants*/; do
				for repair in $seed/repair*/; do
					if [ $(basename "$repair") == 'repair.sanity' ]; then
						continue
					fi
					cp -r $repair/* $SOURCEDIR
					defects4j compile
					SEEDNUM=$(echo $(basename "$seed") | sed 's/.*Seed//')
					OUTPUT=$(defects4j test -s $TESTS)
					echo "$PROJECT $BUGNUM SEED$SEEDNUM $(basename "$repair") $OUTPUT" >> $ROOT/$LOGFILE
					OUTPUT=$(echo $OUTPUT | awk '{print $3}')
					cp -r $seed/original/* $SOURCEDIR
				
					if [ $OUTPUT == 0 ]; then
						echo "$PROJECT $BUGNUM SEED$SEEDNUM $(basename "$repair")" >> $ROOT/$RESULT
					fi
				done
			done
			cd $ORIGDIR
			rm -rf $TESTFOLDER
                fi
        fi
done

