 #!/bin/bash

CUR_DIR=$(pwd)
echo $CUR_DIR
HOME_DIR="$CUR_DIR/.."
DIR="$HOME_DIR/result/safetyPrecision"

tools=(
	STARTS
	Ekstazi
	HyRTS
	Clover
)

mkdir $DIR

cat $HOME_DIR/repositories.txt |
while IFS=" " read -r subN noUse noUse2; do
	for revIdx in {1..50}; do
		revN="rev_$revIdx"
		tool=${tools[$i]}
		f=testList.txt
		if [[ $revN == rev* ]]; then
			java -classpath calcSafetyPrecision/src SPRCalculator.SPRCalculator "$subN" "$revIdx" "$HOME_DIR/${tools[0]}/$subN/$revN/$f" "$HOME_DIR/${tools[1]}/$subN/$revN/$f" "$HOME_DIR/${tools[2]}/$subN/$revN/$f" "$HOME_DIR/${tools[3]}/$subN/$revN/$f" "$DIR"
		fi
	done
done

