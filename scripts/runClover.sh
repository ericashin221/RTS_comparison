#!/bin/env bash

HOME_DIR=".."

REVISIONS_DIR="$HOME_DIR/original_source"
CLOVER_DIR="$HOME_DIR/Clover"

_Clover__PROFILE=$(cat <<EOF
        <profile>
            <id>cloverp</id>
            <activation>
                <property>
                    <name>clover</name>
                </property>
            </activation>
            <build>
                <plugins>
                         <plugin>
                                <groupId>org.openclover</groupId>
                                <artifactId>clover-maven-plugin</artifactId>
                                <version>4.4.1</version>
                         </plugin>
                </plugins>
            </build>
        </profile>
EOF
)
_Clover__PROFILE=$(echo ${_Clover__PROFILE} | sed 's/ //g')

function Clover_integrate {
		echo "**** Clover INTEGRATE FUNCTION ***"
		local pom="$1/pom.xml"
		if [ -f ${pom} ]; then
			echo "***** FOUND pom.xml at: ${pom}"

			local has_profiles=$( grep 'profiles' ${pom} | wc -l )
            if [ ${has_profiles} -eq 0 ]; then
				sed -i 'sX</project>X<profiles>'${_Clover__PROFILE}'</profiles></project>Xg' ${pom}
            else
				sed -i 'sX</profiles>X'${_Clover__PROFILE}'</profiles>Xg' ${pom}
            fi

		fi
}

for subN in $(ls $REVISIONS_DIR/); do
if [[ $subN == asterisk ]]; then
	if [ -d $REVISIONS_DIR/$subN ]; then
		echo "*** RUN Clover on project: $subN"
		mkdir $CLOVER_DIR/$subN
		mkdir $CLOVER_DIR/$subN/workingDir
		#mkdir $CLOVER_DIR/$subN/tmp

		for i in {1..50}; do
			revN="rev_$i"
			if [ -d $REVISIONS_DIR/$subN/$revN ] ; then
				echo "**** RUN $subN with revision: $revN"
				mkdir $CLOVER_DIR/$subN/$revN
				cp -r -f $REVISIONS_DIR/$subN/$revN/* $CLOVER_DIR/$subN/workingDir
				Clover_integrate "$CLOVER_DIR/$subN/workingDir"
				echo "**** maven run OpenClover"
				cwd=$(pwd)
				cd $CLOVER_DIR/$subN/workingDir
				mvn clover:setup clover:optimize test clover:snapshot -Pcloverp -Dmaven.clover.fullRunEvery=80 -Drat.skip=true> $cwd/$CLOVER_DIR/$subN/$revN/CloverOutput.txt
				#mvn clover:setup clover:optimize test clover:snapshot -Pcloverp -Drat.skip=true > $cwd/$CLOVER_DIR/$subN/$revN/CloverOutput.txt
				cd $cwd
				cp -r $CLOVER_DIR/$subN/workingDir/.clover $CLOVER_DIR/$subN/$revN
			fi
		done
	fi

fi
done 


