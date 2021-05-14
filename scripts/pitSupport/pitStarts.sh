#!/bin/bash

HOME_DIR="../.."

REVISIONS_DIR="$HOME_DIR/original_source"
STARTS_DIR="$HOME_DIR/STARTS"
pitestWorkDir="$HOME_DIR/pitestWork"

mkdir $pitestWorkDir

echo "Adding pitest Plugin"

_PitestSTARTS__PROFILE=$(cat <<EOF
        <profile>
            <id>spitestp</id>
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
                  <version>1.5.1</version>
                  <configuration>
                        <targetClasses>
                                trgclz
                        </targetClasses>
                        <targetTests>
                                trgtst
                        </targetTests>
			<excludedTestClasses>
                                <param>org.apache.commons.net.ftp.parser.MLSDComparison</param>
                                <param>org.apache.commons.imaging.ImageDumpTest</param>
                                <param>org.apache.commons.imaging.roundtrip.FullColorRoundtrip</param>
                        </excludedTestClasses>
                  </configuration>
           </plugin>
                </plugins>
            </build>
        </profile>
EOF
)
_PitestSTARTS__PROFILE=$(echo ${_PitestSTARTS__PROFILE} | sed 's/ //g')

_PitestOrig__PROFILE=$(cat <<EOF
        <profile>
            <id>opitestp</id>
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
                  <version>1.5.1</version>
                  <configuration>
                        <targetClasses>
                                trgclz
                        </targetClasses>
			<targetTests>
            			<param>org.*</param>
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
_PitestOrig__PROFILE=$(echo ${_PitestOrig__PROFILE} | sed 's/ //g')

function Pitest_integrate() {
	#cat "CUR DIR =$(pwd)"
        local repo="${1}"
        local replacement="${2}"

        ( #cd ${repo};
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
	echo "$subN"
	if [ "$subN" = "commonsNet" ]; then
	if [ -d $REVISIONS_DIR/$subN ]; then
		echo "*** RUN on project: $subN"

		for i in {2..50}; do
			#if [ $i != 42 ]; then
		#		continue
		#	fi
			revN="rev_$i"
			if [ -d $REVISIONS_DIR/$subN/$revN ] && [ -s $STARTS_DIR/$subN/$revN/changedList.txt ]; then
				echo "***** Run on Revision: $revN"
				(awk '{ print "<param>", $0, "</param>"}' $STARTS_DIR/$subN/$revN/changedList.txt &> $STARTS_DIR/$subN/$revN/pitchangedList.txt)
				(awk '{ print "<param>", $0, "</param>"}' $STARTS_DIR/$subN/$revN/testList.txt &> $STARTS_DIR/$subN/$revN/pittestList.txt)

				changeClasses=$(cat "$STARTS_DIR/$subN/$revN/pitchangedList.txt")

      				startsTargetTests=$(cat "$STARTS_DIR/$subN/$revN/pittestList.txt")
      				startsProfile=$_PitestSTARTS__PROFILE
       				startsProfile=${startsProfile/trgclz/$changeClasses}
       				startsProfile=${startsProfile/trgtst/$startsTargetTests}
       				startsProfile=$(echo ${startsProfile} | sed 's/ //g')

       				origProfile=$_PitestOrig__PROFILE
       				origProfile=${origProfile/trgclz/$changeClasses}
       				origProfile=$(echo ${origProfile} | sed 's/ //g')

				echo "***** copy project into workDir"
       				(cp -r -f -a $REVISIONS_DIR/$subN/$revN/*  $pitestWorkDir)
				mkdir "$STARTS_DIR/$subN/$revN/pitestResults"
				cwd=$(pwd)
				cd "$pitestWorkDir/"
       				Pitest_integrate   "$pitestWorkDir/"   "$startsProfile"
       				#Pitest_integrate   "$pitestWorkDir/"   "$origProfile"

				echo "***** maven clean project and compile"
       				mvn clean
       				#mvn compile -Drat.skip=true 
       				mvn test -Drat.skip=true &>> "CleanCompileResult.txt"

				echo "***** run pit with STARTS"
				timeout 8m mvn org.pitest:pitest-maven:mutationCoverage -Pspitestp -Drat.skip=true > "pitestResult.txt"
       				cp -r -f -a "pitestResult.txt"  "$cwd/$STARTS_DIR/$subN/$revN/pitestResults/"
       				rm -r -f "target/pit-reports/"

				#echo "***** run pit with all"
       				#timeout 8m mvn org.pitest:pitest-maven:mutationCoverage -Popitestp -Drat.skip=true > "pitestAllTestResult.txt"
       				#cp -r -f -a "pitestAllTestResult.txt"  "$cwd/$STARTS_DIR/$subN/$revN/pitestResults/"
       				#rm -r -f "target/pit-reports/"

				cd $cwd
				#rm $STARTS_DIR/$subN/$revN/pitchangedList.txt
				#rm $STARTS_DIR/$subN/$revN/pittestList.txt

			fi
		done
	fi
	fi

rm -rf $pitestWorkDir/*
done

