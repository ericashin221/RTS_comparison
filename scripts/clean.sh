#!/bin/env bash

HOME_DIR=".."

echo "### cleaning... "

echo "#### Delete original sources"
rm -rf "$HOME_DIR/original_source"

echo "#### Delete Ekstazi Dir"
rm -rf "$HOME_DIR/Ekstazi"

echo "#### Delete STARTS Dir"
rm -rf "$HOME_DIR/STARTS"

echo "#### Delete HyRTS Dir"
rm -rf "$HOME_DIR/HyRTS"

echo "#### Delete Clover Dir"
rm -rf "$HOME_DIR/Clover"

rm -rf ~/.local/share/Trash/*

