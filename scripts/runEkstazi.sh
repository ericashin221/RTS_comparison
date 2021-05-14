#!/bin/env bash

HOME_DIR=".."

REVISIONS_DIR="$HOME_DIR/original_source"
EKSTAZI_DIR="$HOME_DIR/Ekstazi"

_Ekstazi__PROFILE=$(cat <<EOF
        <profile>
            <id>ekstazip</id>
            <activation>
                <property>
                    <name>ekstazi</name>
                </property>
            </activation>
            <build>
                <plugins>
                  <plugin>
                      <groupId>org.ekstazi</groupId>
                      <artifactId>ekstazi-maven-plugin</artifactId>
                      <version>4.6.3</version>
                      <executions>
                          <execution>
                              <id>ekstazi</id>
                              <goals>
                                  <goal>select</goal>
                              </goals>
                          </execution>
                      </executions>
                  </plugin>
<!-- EKSTAZI -->
                </plugins>
            </build>
        </profile>
EOF
)
_Ekstazi__PROFILE=$(echo ${_Ekstazi__PROFILE} | sed 's/ //g')

function Ekstazi_integrate {
		echo "**** Ekstazi INTEGRATE FUNCTION ***"
		local pom="$1/pom.xml"
		if [ -f ${pom} ]; then
			echo "***** FOUND pom.xml at: ${pom}"

			local has_profiles=$( grep 'profiles' ${pom} | wc -l )
            if [ ${has_profiles} -eq 0 ]; then
				sed -i 'sX</project>X<profiles>'${_Ekstazi__PROFILE}'</profiles></project>Xg' ${pom}
            else
				sed -i 'sX</profiles>X'${_Ekstazi__PROFILE}'</profiles>Xg' ${pom}
            fi

		fi
}

for subN in $(ls $REVISIONS_DIR/); do
	if [ -d $REVISIONS_DIR/$subN ]; then
		echo "*** RUN Ekstazi on project: $subN"
		mkdir $EKSTAZI_DIR/$subN
		mkdir $EKSTAZI_DIR/$subN/workingDir

		for i in {1..50}; do
			revN="rev_$i"
			if [ -d $REVISIONS_DIR/$subN/$revN ] ; then
				echo "**** RUN $subN with revision: $revN"
				mkdir $EKSTAZI_DIR/$subN/$revN
				cp -r -f $REVISIONS_DIR/$subN/$revN/* $EKSTAZI_DIR/$subN/workingDir
				Ekstazi_integrate "$EKSTAZI_DIR/$subN/workingDir"
				echo "**** maven run Ekstazi"
				cwd=$(pwd)
				cd $EKSTAZI_DIR/$subN/workingDir
				mvn ekstazi:ekstazi -Pekstazip -Drat.skip=true > $cwd/$EKSTAZI_DIR/$subN/$revN/EkstaziRTSOutput.txt
				cd $cwd
				cp -r $EKSTAZI_DIR/$subN/workingDir/.ekstazi $EKSTAZI_DIR/$subN/$revN
			fi
		done
	fi
done 


