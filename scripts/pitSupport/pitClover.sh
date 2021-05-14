#!/bin/bash

HOME_DIR="../.."

REVISIONS_DIR="$HOME_DIR/original_source"
STARTS_DIR="$HOME_DIR/STARTS"
CLOVER_DIR="$HOME_DIR/Clover"
pitestWorkDir="$HOME_DIR/pitestWork4"

mkdir $pitestWorkDir

echo "Adding pitest Plugin"

_PitestClover__PROFILE=$(cat <<EOF
        <profile>
            <id>cpitestp</id>
            <activation>
                <property>
                    <name>pitest</name>
                </property>
            </activation>
            <build>
                <plugins>
                         <plugin>
                  <groupId>org.pitest</groupId>
                  <artifactId>pitest-maven</artifactId>
                  <version>1.5.0</version>
                  <configuration>
                        <targetClasses>
                                trgclz
                        </targetClasses>
                        <targetTests>
                                trgtst
                        </targetTests>
			<excludedTestClasses>
                                <param>org.apache.commons.net.ftp.parser.MLSDComparison</param>
                        </excludedTestClasses>
                  </configuration>
           </plugin>
                </plugins>
            </build>
        </profile>
EOF
)
_PitestClover__PROFILE=$(echo ${_PitestClover__PROFILE} | sed 's/ //g')


function Pitest_integrate() {
        local replacement="${1}"

        ( 
                for pom in $(find -name "pom.xml"); do
                        local has_profiles=$( grep 'profiles' ${pom} | wc -l )
                        if [ ${has_profiles} -eq 0 ]; then
                                sed -i 's%</project>%<profiles>'${replacement}'</profiles></project>%g' ${pom}
                        else
                                sed -i 's%</profiles>%'${replacement}'</profiles>%g' ${pom}
                        fi
                done
        )
}

for subN in $(ls $REVISIONS_DIR/); do
	if [ "$subN" == "asterisk" ];then
	if [ -d $REVISIONS_DIR/$subN ]; then
		echo "*** RUN on project: $subN"

		for i in {2..50}; do
			revN="rev_$i"
			if [ -d $REVISIONS_DIR/$subN/$revN ] && [ -s $STARTS_DIR/$subN/$revN/changedList.txt ]; then

				#if [ -d $CLOVER_DIR/$subN/$revN/pitestResults ]; then
				#	success=$(grep -R "BUILD SUCCESS" $CLOVER_DIR/$subN/$revN/pitestResults/pitestResult.txt)
				#	if [[ $success == *"SUCCESS"* ]]; then
				#		echo "***** Skip due to success"
				#		continue
				#	fi
				#fi

				echo "***** Run on Revision: $revN"
				(awk '{ print "<param>", $0, "</param>"}' $STARTS_DIR/$subN/$revN/changedList.txt &> $STARTS_DIR/$subN/$revN/pitchangedList.txt)
				(awk '{ print "<param>", $0, "</param>"}' $CLOVER_DIR/$subN/$revN/testList.txt &> $CLOVER_DIR/$subN/$revN/pittestList.txt)

				changeClasses=$(cat "$STARTS_DIR/$subN/$revN/pitchangedList.txt")

      				cloverTargetTests=$(cat "$CLOVER_DIR/$subN/$revN/pittestList.txt")
      				cloverProfile=$_PitestClover__PROFILE
       				cloverProfile=${cloverProfile/trgclz/$changeClasses}
       				cloverProfile=${cloverProfile/trgtst/$cloverTargetTests}
       				cloverProfile=$(echo ${cloverProfile} | sed 's/ //g')

				echo "***** copy project into workDir"
       				(cp -r -f -a $REVISIONS_DIR/$subN/$revN/*  $pitestWorkDir)
				mkdir "$CLOVER_DIR/$subN/$revN/pitestResults"
				cwd=$(pwd)
				cd "$pitestWorkDir/"
       				Pitest_integrate  "$cloverProfile"

				echo "***** maven clean project and compile"
       				mvn clean &>> "CleanCompileResult.txt"
       				#mvn compile -Drat.skip=true &>> "CleanCompileResult.txt"
       				mvn test -Drat.skip=true &>> "CleanCompileResult.txt"

				echo "***** run pit with Clover"
				timeout 8m mvn org.pitest:pitest-maven:mutationCoverage -Pcpitestp -Drat.skip=true > "pitestResult.txt"
       				cp -r -f -a "pitestResult.txt"  "$cwd/$CLOVER_DIR/$subN/$revN/pitestResults/"
       				rm -r -f "target/pit-reports/"

				cd $cwd
				#rm $STARTS_DIR/$subN/$revN/pitchangedList.txt
				#rm $CLOVER_DIR/$subN/$revN/pittestList.txt

			fi
		done
	fi
fi
(rm -rf $pitestWorkDir/*)
done

