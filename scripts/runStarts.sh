#!/bin/env bash

HOME_DIR=".."

REVISIONS_DIR="$HOME_DIR/original_source"
STARTS_DIR="$HOME_DIR/STARTS"

_Starts__PROFILE=$(cat <<EOF
        <profile>
            <id>startsp</id>
            <activation>
                <property>
                    <name>starts</name>
                </property>
            </activation>
            <build>
                <plugins>
                         <plugin>
                                <groupId>edu.illinois</groupId>
                                <artifactId>starts-maven-plugin</artifactId>
                                <version>1.3</version>
                         </plugin>
                </plugins>
            </build>
        </profile>
EOF
)
_Starts__PROFILE=$(echo ${_Starts__PROFILE} | sed 's/ //g')

function Starts_integrate {
		echo "**** STARTS INTEGRATE FUNCTION ***"
		local pom="$1/pom.xml"
		if [ -f ${pom} ]; then
			echo "***** FOUND pom.xml at: ${pom}"

			local has_profiles=$( grep 'profiles' ${pom} | wc -l )
            if [ ${has_profiles} -eq 0 ]; then
				sed -i 'sX</project>X<profiles>'${_Starts__PROFILE}'</profiles></project>Xg' ${pom}
            else
				sed -i 'sX</profiles>X'${_Starts__PROFILE}'</profiles>Xg' ${pom}
            fi

		fi
}

for subN in $(ls $REVISIONS_DIR/); do

	if [ -d $REVISIONS_DIR/$subN ] && [ ! -d $STARTS_DIR/$subN ]; then
		echo "*** RUN STARTS on project: $subN"
		mkdir $STARTS_DIR/$subN
		mkdir $STARTS_DIR/$subN/workingDir

		for i in {1..50}; do
			revN="rev_$i"
			if [ -d $REVISIONS_DIR/$subN/$revN ]; then
				echo "**** RUN $subN with revision: $revN"
				mkdir $STARTS_DIR/$subN/$revN
				cp -r -f $REVISIONS_DIR/$subN/$revN/* $STARTS_DIR/$subN/workingDir
				Starts_integrate "$STARTS_DIR/$subN/workingDir"
				echo "**** maven run STARTS"
				cwd=$(pwd)
				cd $STARTS_DIR/$subN/workingDir
				if [[ $revN == rev_1 ]]; then
					#mvn starts:starts -DdepFormat=CLZ -Pstartsp -Drat.skip=true > $cwd/$STARTS_DIR/$subN/$revN/StartsRTSOutput.txt
					mvn starts:starts -Pstartsp -Drat.skip=true > $cwd/$STARTS_DIR/$subN/$revN/StartsRTSOutput.txt

				else
					mvn starts:diff -Pstartsp -Drat.skip=true > $cwd/$STARTS_DIR/$subN/$revN/StartsChangedFiles.txt
					mvn starts:starts -Pstartsp -Drat.skip=true > $cwd/$STARTS_DIR/$subN/$revN/StartsRTSOutput.txt
				fi
				cd $cwd
				#find $STARTS_DIR/$subN/workingDir/*.txt -size 0 -delete #delete empty files
				#mv $STARTS_DIR/$subN/workingDir/Starts*.txt $STARTS_DIR/$subN/$revN
				cp -r $STARTS_DIR/$subN/workingDir/.starts $STARTS_DIR/$subN/$revN
			fi
		done
	fi
done


