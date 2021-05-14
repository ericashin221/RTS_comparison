#!/bin/bash


HOME_DIR=".."
STARTS_DIR="$HOME_DIR/STARTS"

for subN in $(ls $STARTS_DIR/); do
	if [ -d $STARTS_DIR/$subN ]; then
		echo "*** Recurse subject: " $subN
		for revN in $(ls $STARTS_DIR/$subN/); do
			if [[ $revN == rev* ]] && [ -d $STARTS_DIR/$subN/$revN ]; then
				echo "****** Recurse Revision: " $revN
				dir=$STARTS_DIR/$subN/$revN
				if [ ! -f $dir/StartsChangedFiles.txt ]; then
					echo "        SKIP: NO FILE CONTAINS CHANGES!"
					continue
				fi
				#ed -s $dir/StartsChangedFiles.txt <<< '/ChangedClasses/+1,$p' | grep -E 'file:' | grep -Po '/test-classes/\K.*' > $dir/changes.txt
                		ed -s $dir/StartsChangedFiles.txt <<< '/ChangedClasses/+1,$p' | grep -E 'file:' | awk '{print $2}' | grep -o 'org/.*' > $dir/changes.txt
				cat $dir/changes.txt | tr / . > $dir/changedList.txt
				sed -i -e 's/.class/ /' $dir/changedList.txt
	                	rm $dir/changes.txt
			fi
		done
	fi

done






