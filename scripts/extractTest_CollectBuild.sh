#!/bin/bash

HOME_DIR=".."
REVISIONS_DIR="$HOME_DIR/original_source"

function extractTests() {
	dir=${1}
	fileName=${2}

	#extract tests only if build success
	success=$( grep -F "BUILD SUCCESS" $dir/$fileName )
	if [ -n "$success" ]; then
		info=$( cat $dir/$fileName | sed -n '/T E S T/,$p' | grep -E '(\[INFO\]) Running ' )
		if [ -n "$info" ]; then
			sed -n '/T E S T/,$p' $dir/$fileName | grep -E 'Running org' | awk '{print $3}' > $dir/testList.txt
		else
			sed -n '/T E S T/,$p' $dir/$fileName | grep -E 'Running org' | awk '{print $2}' > $dir/testList.txt
		fi
		echo 1
	else
		echo 0
	fi
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
mkdir $HOME_DIR/result/buildResult

cat $HOME_DIR/repositories.txt |
while IFS=" " read -r subN noUse noUse2; do
	brFile=$HOME_DIR/result/buildResult/$subN.csv
	echo "rev, All, STARTS, Ekstazi, HyRTS, Clover" > $brFile
	for revIdx in {1..50}; do
		revN="rev_$revIdx"
		for i in ${!tools[*]}; do
			tool=${tools[$i]}
			file=${outFiles[$i]}

			if [[ $tool == All ]]; then
				if [[ $revN == rev* ]] && [ -d $REVISIONS_DIR/$subN/$revN ]; then
                                        returnVal=$(extractTests $REVISIONS_DIR/$subN/$revN $file)
                                        if [[ $returnVal == 1 ]]; then
                                                resultStr+="Success, "
                                        else
                                                resultStr+="Fail, "
                                        fi
                                fi
			else
				if [[ $revN == rev* ]] && [ -d $HOME_DIR/$tool/$subN/$revN ]; then
					returnVal=$(extractTests $HOME_DIR/$tool/$subN/$revN $file)
					if [[ $returnVal == 1 ]]; then
                                                resultStr+="Success, "
                                        else
                                                resultStr+="Fail, "
                                        fi
				fi
			fi

		done
		if [[ ${#resultStr} == 0 ]]; then
			echo "$revN: Not Avaiable!"
		else
			echo "$revN, ${resultStr::-2}" >> $brFile
		fi
		resultStr=""
	done
done

