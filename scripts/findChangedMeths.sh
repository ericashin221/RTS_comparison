#!/bin/bash

CUR_DIR=$(pwd)
echo $CUR_DIR
HOME_DIR="$CUR_DIR/.."

mkdir $DIR

java -classpath hyrtsChanged/src MyClass.MyClass "$HOME_DIR"

