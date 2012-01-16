#!/bin/bash

function checkPermission() {
	if [ -z $1 ]; then
		echo "No command line args";
		exit;
	fi
	
	fperm=$(ls -l $1 |awk '{ print $1 }');
	if [ $fperm = $2 ]; then
		echo 1;
	else
		echo 0;
	fi
}

function checkOwner() {
	if [ -z $1 ]; then
		echo "No command line args";
		exit;
	fi
	fown=$(ls -l $1 |awk '{ print $3":"$4 }');
	if [ $fown = $2 ]; then
		echo 1;
	else
		echo 0;
	fi
}

# return a listing of octal file permissions and the filenames.
function ls_oct() {
	if [ -z $1 ]; then
		echo "No command line args";
		exit;
	fi
	find "${1}" -maxdepth 0 -type f -printf "%m %f\n" 
}
