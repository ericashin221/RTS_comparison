#!/bin/bash

HOME_DIR=".."
REVISIONS_DIR="$HOME_DIR/original_source"

function extractTime() {
	dir=${1}
	fileName=${2}

	#extract tests only if build success
	success=$( grep -F "BUILD SUCCESS" $dir/$fileName )
	if [ -n "$success" ]; then
		totalTime=$(grep -oP "Total time: \K.*" $dir/$fileName)
		if [[ $totalTime == *"s"* ]]; then
			totalTime=${totalTime::-2}
		else
			mins=${totalTime%:*}
			sec=${totalTime#*:}
			sec=${sec%%min*}
			totalTime=$(( mins*60+sec ))
		fi

		echo "$totalTime"
	else
		echo "fail"
	fi
}

function extractTestReduction() {
	dir=${1}

	numTest=$(wc -l $dir/testList.txt | cut -d " " -f1)
	echo "$numTest"
}

tools=(
	All
	STARTS
	Ekstazi
	HyRTS
	Clover
)

outFiles=(
	mvnRunOutput.txt
	StartsRTSOutput.txt
	EkstaziRTSOutput.txt
	HyRTSOutput.txt
	CloverOutput.txt
)

mkdir $HOME_DIR/result
mkdir $HOME_DIR/result/testTime
mkdir $HOME_DIR/result/numTest

cat $HOME_DIR/repositories.txt |
while IFS=" " read -r subN noUse noUse2; do
	timeFile=$HOME_DIR/result/testTime/$subN.csv
	numFile=$HOME_DIR/result/numTest/$subN.csv
	echo "rev, All, STARTS, Ekstazi, HyRTS, Clover" > $timeFile
	echo "rev, All, STARTS, Ekstazi, HyRTS, Clover" > $numFile
	for revIdx in {1..50}; do
		revN="rev_$revIdx"
		for i in ${!tools[*]}; do
			tool=${tools[$i]}
			file=${outFiles[$i]}

			if [[ $tool == All ]]; then
				if [[ $revN == rev* ]] && [ -d $REVISIONS_DIR/$subN/$revN ]; then
                                        echo "extract from " $REVISIONS_DIR/$subN
                                        returnVal=$(extractTime $REVISIONS_DIR/$subN/$revN $file)
                                        timeStr+="$returnVal, "
                                        reductionVal=$(extractTestReduction $REVISIONS_DIR//$subN/$revN)
                                        redStr+="$reductionVal, "
                                fi
			else
				if [[ $revN == rev* ]] && [ -d $HOME_DIR/$tool/$subN/$revN ]; then
					echo "extract from " $HOME_DIR/$tool/$subN
					returnVal=$(extractTime $HOME_DIR/$tool/$subN/$revN $file)
					timeStr+="$returnVal, "
					reductionVal=$(extractTestReduction $HOME_DIR/$tool/$subN/$revN)
					redStr+="$reductionVal, "
				fi
			fi
		done

		if [[ ${#timeStr} == 0 ]]; then
			echo "$revN: Not Avaiable!"
		else
			echo "$revN, ${timeStr::-2}" >> $timeFile
			timeStr=""
			echo "$revN, ${redStr::-2}" >> $numFile
			redStr=""
		fi
	done
done

