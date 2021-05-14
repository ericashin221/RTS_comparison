#!/bin/env bash

HOME_DIR=".."

REVISIONS_DIR="$HOME_DIR/original_source"
HYRTS_DIR="$HOME_DIR/HyRTS"

_HyRTS__PROFILE=$(cat <<EOF
        <profile>
            <id>hyrtsp</id>
            <activation>
                <property>
                    <name>hyrts</name>
                </property>
            </activation>
            <build>
                <plugins>
                         <plugin>
                                <groupId>org.hyrts</groupId>
                                <artifactId>hyrts-maven-plugin</artifactId>
                                <version>1.0.1</version>
                         </plugin>
                </plugins>
            </build>
        </profile>
EOF
)
_HyRTS__PROFILE=$(echo ${_HyRTS__PROFILE} | sed 's/ //g')

function HyRTS_integrate {
		echo "**** HyRTS INTEGRATE FUNCTION ***"
		local pom="$1/pom.xml"
		if [ -f ${pom} ]; then
			echo "***** FOUND pom.xml at: ${pom}"

			local has_profiles=$( grep 'profiles' ${pom} | wc -l )
            if [ ${has_profiles} -eq 0 ]; then
				sed -i 'sX</project>X<profiles>'${_HyRTS__PROFILE}'</profiles></project>Xg' ${pom}
            else
				sed -i 'sX</profiles>X'${_HyRTS__PROFILE}'</profiles>Xg' ${pom}
            fi
		fi
}

for subN in $(ls $REVISIONS_DIR/); do

	if [ -d $REVISIONS_DIR/$subN ]; then
		echo "*** RUN HyRTS on project: $subN"
		mkdir $HYRTS_DIR/$subN
		mkdir $HYRTS_DIR/$subN/workingDir

		for i in {1..50}; do
			revN="rev_$i"
			if [ -d $REVISIONS_DIR/$subN/$revN ] ; then
				echo "**** RUN $subN with revision: $revN"
				mkdir $HYRTS_DIR/$subN/$revN
				cp -r -f $REVISIONS_DIR/$subN/$revN/* $HYRTS_DIR/$subN/workingDir
				HyRTS_integrate "$HYRTS_DIR/$subN/workingDir"
				echo "**** maven run HyRTS"
				cwd=$(pwd)
				cd $HYRTS_DIR/$subN/workingDir
				mvn hyrts:HyRTS -Phyrtsp -Drat.skip=true > $cwd/$HYRTS_DIR/$subN/$revN/HyRTSOutput.txt
				cd $cwd
				cp -r $HYRTS_DIR/$subN/workingDir/hyrts-files $HYRTS_DIR/$subN/$revN
			fi
		done
	fi
done 


