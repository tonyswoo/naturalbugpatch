export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
export JRE_HOME=/usr/lib/jvm/java-7-openjdk-amd64/jre

POOL=/data/ktony11/
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
ORIGDIR=$pwd
RESULT=result.csv
EVOSUITE=$ROOT/test_suite
LOGFILE="csv_gen.log"

rm $RESULT $LOGFILE 2> /dev/null
export PATH=$PATH:$ROOT/defects4j/framework/bin
echo "Project, BugNumber, Treatment, Seed, Patch ID, Time to Generate, Entropy, Num Tests Generated, Num Tests Failed" >> $RESULT

for data in $POOL/GenProg*/; do
	for bug in $data/*/; do
        	if [ $(ls $bug | grep variants | grep -v tar | wc -l) -gt 0 ]; then
                	numRepairs=$(ls $bug/variants* | grep repair | grep -v repair.sanity | wc -l)
                	if [ $numRepairs -gt 0 ]; then
				PROJECT=$(echo $(basename "$bug") | sed 's/Buggy$//' | sed 's/.*/\u&/' | sed 's/[0-9]//g')
				BUGNUM=$(echo $(basename "$bug") | sed 's/[a-zA-Z]//g')
				if [[ $(basename "$data") == *"Vanilla"* ]]; then
					TYPE=Pure
				else
					TYPE=Entropy
				fi
				TESTS=$(ls $EVOSUITE/$PROJECT/evosuite-branch/1/ | grep $PROJECT"-"$BUGNUM | grep -v '.bak')
				NUMEVOTESTS=$(grep Generated $ROOT/test_suite/logs/$PROJECT.$BUGNUM"f.branch.1.log" | awk '{print $3}')
				if [ $(grep $PROJECT"-"$BUGNUM"f" $ROOT/test_suite/$PROJECT/evosuite-branch/1/fix_test_suite.run.log | wc -l) -gt 0 ]; then
					NUMBROKENTESTS=$(grep $PROJECT"-"$BUGNUM"f" $ROOT/test_suite/$PROJECT/evosuite-branch/1/fix_test_suite.run.log | awk '{print $1}')
					NUMEVOTESTS=$(($NUMEVOTESTS - $NUMBROKENTESTS))
				fi

				if [ -z "$NUMEVOTESTS" ]; then
					NUMEVOTESTS=0
				fi

				for seed in $bug/variants*/; do
					TESTLOGFILE=$seed/"test.log"
					SEEDNUM=$(echo $(basename "$seed") | sed 's/.*Seed//')
					for repair in $seed/repair*/; do
						if [[ $(basename "$repair") == 'repair.sanity' || ! -d $repair ]]; then
							continue
						fi
echo "$repair"
						PATCHNUM=$(echo $(basename "$repair") | sed 's/repair//')
						ENTROPY=$(grep "variant$PATCHNUM " $TESTLOGFILE | awk '{print $3}')
						TIMETOGENERATE=$(grep "variant$PATCHNUM" $bug/log*$SEEDNUM.txt | head -n1 | awk '{print $1}')
						FAILING=$(grep "$PROJECT $BUGNUM SEED$SEEDNUM $(basename "$repair") " $ROOT/evosuite_$(basename "$data").log)
						if [[ -z "$FAILING" || -z "$(echo $FAILING | awk '{print $7}')" ]]; then
							FAILING=0
						else
							FAILING=$(echo $FAILING | awk '{print $7}')
						fi
						echo "$PROJECT, $BUGNUM, $TYPE, $SEEDNUM, $PATCHNUM, $TIMETOGENERATE, $ENTROPY, $NUMEVOTESTS, $FAILING" >> $RESULT

					done
				done
	                fi
	        fi
	done
done

