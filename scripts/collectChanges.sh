#!/bin/bash

HOME_DIR=".."
STARTS_DIR="$HOME_DIR/STARTS"

function extractChanges() {
	dir=${1}

	numChange=$(wc -l $dir/changedList.txt | cut -d " " -f1)
	echo "$numChange"
}

mkdir $HOME_DIR/result/changes

cat $HOME_DIR/repositories.txt |
while IFS=" " read -r subN noUse noUse2; do
	changesFile=$HOME_DIR/result/changes/$subN.csv

	echo "rev" > $changesFile
	for revIdx in {2..50}; do
		revN="rev_$revIdx"
		if [[ $revN == rev* ]] && [ -d $STARTS_DIR/$subN/$revN ]; then
                        echo "extract from " $STARTS_DIR/$subN
                        returnVal=$(extractChanges $STARTS_DIR/$subN/$revN)
                        str+="$returnVal, "
                fi

		if [[ ${#str} == 0 ]]; then
			echo "$revN: Not Avaiable!"
		else
			echo "$revN, ${str::-2}" >> $changesFile
			str=""
		fi
	done
done

