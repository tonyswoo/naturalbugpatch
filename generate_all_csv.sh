export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
export JRE_HOME=/usr/lib/jvm/java-7-openjdk-amd64/jre

POOL=/data/ktony11/
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
ORIGDIR=$pwd
RESULT=result_all.csv
EVOSUITE=$ROOT/test_suite
LOGFILE="csv_gen.log"

rm $RESULT $LOGFILE 2> /dev/null
export PATH=$PATH:$ROOT/defects4j/framework/bin
echo "Project, BugNumber, Seed, Patch ID, Entropy, Repair?" >> $RESULT

for data in $POOL/GenProgSeed*/; do
	for bug in $data/*/; do
        	if [ $(ls $bug | grep variants | grep -v tar | wc -l) -gt 0 ]; then
                	numRepairs=$(ls $bug/variants* | grep repair | grep -v repair.sanity | wc -l)
                	if [ $numRepairs -gt 0 ]; then
				PROJECT=$(echo $(basename "$bug") | sed 's/Buggy$//' | sed 's/.*/\u&/' | sed 's/[0-9]//g')
				BUGNUM=$(echo $(basename "$bug") | sed 's/[a-zA-Z]//g')
				if [[ $(basename "$data") == *"FL"* ]]; then
					continue
				fi

				for seed in $bug/variants*/; do
					TESTLOGFILE=$seed/"test.log"
					SEEDNUM=$(echo $(basename "$seed") | sed 's/.*Seed//')
					for variant in $seed/variant*/; do
						if [[ $(basename "$variant") == 'repair.sanity' || ! -d $variant ]]; then
							continue
						fi
						PATCHNUM=$(echo $(basename "$variant") | sed 's/variant//')
						ENTROPY=$(grep "variant$PATCHNUM " $TESTLOGFILE | awk '{print $3}')

						if [ $(grep "Repair.*variant$PATCHNUM)" $bug/log*$SEEDNUM.txt | wc -l) -gt 0 ]; then
							REPAIR='true'
						else
							REPAIR='false'
						fi

						echo "$PROJECT, $BUGNUM, $SEEDNUM, $PATCHNUM, $ENTROPY, $REPAIR" >> $RESULT

					done
				done
	                fi
	        fi
	done
done

