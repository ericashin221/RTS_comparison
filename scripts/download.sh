#!/bin/env bash

HOME_DIR=".."

REVISIONS_DIR="$HOME_DIR/original_source"
EKSTAZI_DIR="$HOME_DIR/Ekstazi"
STARTS_DIR="$HOME_DIR/STARTS"
HYRTS_DIR="$HOME_DIR/HyRTS"
CLOVER_DIR="$HOME_DIR/Clover"

mkdir $REVISIONS_DIR
mkdir $EKSTAZI_DIR
mkdir $STARTS_DIR
mkdir $HYRTS_DIR
mkdir $CLOVER_DIR

cat ../repositories.txt |
while IFS=" " read -r pName pURL pRevSNum; do
	if [[ -z "$pName" ]]; then
		break
	fi

	echo "### Clone project " $pName

	mkdir "$REVISIONS_DIR/$pName"
	echo "***" git clone $pURL "$REVISIONS_DIR/$pName/$pName"
	git clone $pURL "$REVISIONS_DIR/$pName/$pName"

	if [[ $pName == openTripPlanner ]]; then
		cwd=$(pwd)
		cd $REVISIONS_DIR/$pName/$pName
		git checkout master
		cd $cwd
		echo "CURRENT PATH: " $cwd
	fi

	(git --git-dir $REVISIONS_DIR/$pName/$pName/.git log --reverse --ancestry-path $pRevSNum...master | grep -F "commit " | cut -f2 -d' ') > $REVISIONS_DIR/$pName/revisions.txt 

	if [ ! -s $REVISIONS_DIR/$pName/revisions.txt ]  || [ ! -f $REVISIONS_DIR/$pName/revisions.txt ]; then
		echo "ERROR: Failed to create revisions.txt!"
		exit 2
	fi

	idx=1
	max_idx=50

	cat $REVISIONS_DIR/$pName/revisions.txt |
	while IFS= read -r hashID; do
		if [[ -z "$hashID" ]]; then
			echo "skip hashID because the value is $hashID"
			continue
		fi

		git clone $pURL "$REVISIONS_DIR/$pName/rev_$idx"
		cwd=$(pwd)
		cd $REVISIONS_DIR/$pName/rev_$idx
		git checkout -f $hashID
		cd $cwd

		if ((idx >= max_idx)); then
			break
		fi

		idx=$((idx + 1))
	done
done

