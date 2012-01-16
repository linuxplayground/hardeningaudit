#!/bin/bash
#empty report
rm report.xml
echo "<?xml version=\"1.0\" ?>" > report.xml;
echo "<?xml-stylesheet type=\"text/xsl\" href=\"report.xsl\"?>" >> report.xml;
# xmlfunctions


function conv_special_chars() {
	result=$(echo "${1}" | sed 's/\&/&amp;/g';);
	echo "${result}";
}




# function	item	Function to create an item in xml format.
# var	$1	str		Title		REQ	The title of the item
# var	$2	str		Stauts 	REQ	The status of the item
#												[low|med|high|pass|none]
# var	$3	text	msg			OPT	The message of the item.
# var	$4	text	rec			OPT	The recommendation.	
# var $5  text	cmd			OPT	a command to execute and include in the rec tag.
# result	xmlStr	An XML formatted string containing the details of the item.
function xmlitem() {
	EXPECTED_ARGS=3;
	E_BADARGS=65;
	USAGE="Usage: item <title> <low|med|high|pass> [content] [cmd]";
	if [ $# -lt $EXPECTED_ARGS ]; then
		echo "${USAGE}";
		echo "$0 $1 $2 $3 $4";
		exit $E_BADARGS;
	fi

	link_name=$(echo $1 | sed 's/ /_/g' | sed 's/\.//g' | sed 's/\///g');
	case ${2} in
	"low")
		type="LOW";
		;;
	"med")
		type="MED";
		;;
	"high")
		type="HIGH";
		;;
	"pass")
		type="PASS";
		;;
	"text")
		type="TEXT";
		;;
	"none")
		type="NONE";
		;;
	*)
		echo "${USAGE}";
		echo "$0 $1 $2 $3 $4";
		exit $E_BADARGS;
		;;
	esac

	output="<item><name>${link_name}</name><title>$(conv_special_chars "${1}")</title><type>${type}</type>";

	case $# in
	3)
		output=$(echo "${output}<msg>$(conv_special_chars "${3}")</msg>");;
	4)
		output=$(echo "${output}<msg>$(conv_special_chars "${3}")</msg><rec>$(conv_special_chars "${4}")</rec>");;
	esac
	output=$(echo "${output}</item>");
	echo "${output}" >> report.xml;
}

# function	section	Function to create a plain text section.
# var	$1	str		Title	REQ	The title of the item
# var	$2	text	msg		OPT	The message of the item.
# result	call	item	Call the item function. 
function section() {
	if [ $# -eq 2 ]; then
		xmlitem "${1}" "text" "${2}";
	else
		xmlitem "${1}" "text" "";	
	fi
}

# html_exec - execute command, capture output and add to body.
# $1 = command to execute
function html_exec() {
	# execute command and redirect output to temp file.
	echo "<pre>" >> body.inc
	${1} >> body.inc 2>&1
	echo "</pre>" >> body.inc
	
	if [ ${2} ]; then
		echo "<pre>" >> fail.inc
		echo $(eval "${1}") >> fail.inc 2>&1
		echo "</pre>" >> fail.inc
	fi
}

