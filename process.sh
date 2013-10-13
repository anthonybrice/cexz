#!/bin/bash

# @author: Anthony Brice
#
# TO USE: Put your first and last name in the first noncommented section below. Place the script in the folder that contains the program you wish to compile. Ensure no other .c files are in the folder than the ones you wish to compile. Open a terminal and navigate to the folder containing process.sh. Run with the command "./process.sh [lab#] [task#] [arguments]"; i.e. to make and run executable l6t1 for Lab 6 Task 1 which takes the argument input.txt, type "./process.sh 6 1 input.txt".
#
# If you have valgrind installed, specify argument v before the lab # to have the program additionally compile, execute, and output a valgrind run to show any memory leaks.
#
# This script will compile all .c files in the current folder. If they do not have a header, it will prepend the file with the header. If they do have a header it will update the date on the header. It will then run the executable making a file of the output with the header, and start a script with the header, running the executable with the given arguments. It will attemt to run the executable again with last argument as a replacement for stdin. It will then scrub the script for those weird input keystrokes, but I'm pretty sure we don't need to do that since our script never takes any keystrokes. It then zips all .h and .c files, the two outputfiles, and any arguments into a file named with AJ's naming scheme. THIS SCRIPT DOES NOT SUPPORT SPECIAL COMPILATIONS.

# I could have made the name a run argument to keep this script as generic as possible, but it would have been a pain to have to enter it every time. Is there I can have a specific run argument that changes the name variables in here and saves the file?
# PLEASE PUT YOUR NAME BELOW:
firstName="Anthony"
lastName="Brice"

# This function makes the script's contents. The function is only called when process.sh is called with "s" as the first argument. Ostensibly the end-user could do this on his or her own, but I think of this as a private function that is used when we call the script command with process.sh below (see "# Make the script.").
runScript() {
	command1str="./l${1}t${2} ${@:3}"
	if [ $# -gt 3 ]; then
		args="${@:3:$#-3}"
	else
		args=""
	fi
	command2str="./l${1}t${2} $args < ${@:${#-1}:1}"

	command1() {
		"./l${1}t${2}" "${@:3}"
	}

	command2() {
		if [ "$args" ]; then
			"./l${1}t${2}" "${args}" < "${@:${#-1}:1}"
		else
			"./l${1}t${2}" < "${@:${#-1}:1}"
		fi
	}

	echo \$ ${command1str}
	command1 "$@"

	echo

	if [ "$#" -gt 2 ]; then
		echo \$ ${command2str}
		command2 "$@"
	fi

	echo
}

# This checks the first argument for the "s" option. It should only be used when this file wants to make a script. It also checks for "v" argument which tells the script to make and run a special valgrind executable.
valgrind=false
gcBool=false
lex=false
gcstring=""
argOffset=0
index=0
for arg in $@; do
	index=$[index+1]
	if [ "$arg" == "s" ]; then
		runScript ${@:2}
		exit
	fi
	if [ "$arg" == "v" ]; then
		valgrind=true
		argOffset=$[argOffset+1]
	fi
	if [ "$arg" == "g" ]; then
		gcBool=true
		gcString+="${@:$index+2:${@:index+1:1}}"
		argOffset=$[argOffset+2+${@:$index+1:1}]
	fi
	if [ "$arg" == "l" ]; then
		lex=true
		printf "\nExecuting lex *.l\n"
		lex *.l ${lexString}
		argOffset=$[argOffset+1]
	fi
done

# Checks for valid number of arguments.
if [ "$#" -lt 2 ]; then
	echo syntax: "$0" "[lab #]" "[task #]" "[arguments]"
	exit
fi

# Get lab and task number.
lab="${@:$argOffset+1:1}"
task="${@:$argOffset+2:1}"

# Make the output files, write the headers. The printf commands will overwrite any existing contents in the files.
touch task${task}_out.txt
touch task${task}_script.txt

printf "/**\n* Name: ${firstName} ${lastName}\n* Lab/task: Lab ${lab} Task ${task}\n* Date: $(date +%m)/$(date +%d)/$(date +%Y) $(date +%I:%M:%S) $(date +%p)\n*/\n\n" > task${task}_out.txt

printf "/**\n* Name: ${firstName} ${lastName}\n* Lab/task: Lab ${lab} Task ${task}\n* Date: $(date +%m)/$(date +%d)/$(date +%Y) $(date +%I:%M:%S) $(date +%p)\n*/\n\n" > task${task}_script.txt

# For each .c and .h file, we check for the existence of the header. If no header, we put one in there. If a header exists, we overwrite the lab/task line and the date line.
for f in *.{c,h} ; do
	if ! grep -q "/**\n* Name:" "${f}"; then
		sed -i -e "1i /**\n* Name: Anthony Brice\n* Lab/task: Lab ${lab} Task ${task}\n* Date: $(date +%m)/$(date +%d)/$(date +%Y) $(date +%I:%M:%S) $(date +%p)\n*/\n" ${f}
	else
		if [ "$f" != "lex.yy.c" ]; then
			new_line="* Date: $(date +%m)/$(date +%d)/$(date +%Y) $(date +%I:%M:%S) $(date +%p)"
			sed -i -e "3s@.*@* Lab/task: Lab ${lab} Task ${task}@" ${f}
			sed -i -e "4s@.*@${new_line}@" ${f}
		fi
	fi
done

# Make sure executable is the latest build.
if $gcBool ; then
	printf "Compiling with command: gcc *.c ${gcString} -o l${lab}t${task}"
	gcc *.c ${gcString} -o l${lab}t${task}
else
	gcc *.c -o l${lab}t${task}
fi

# Execute valgrind run.
if $valgrind ; then
	printf "\nValgrind executable is l${lab}t${task}val. Executing run...\n"
	gcc *.c -g -O1 -w -o l${lab}t${task}val
	valgrind --leak-check=yes ./l${lab}t${task}val ${@:$argOffset+3} > l${lab}t${task}val.txt 2>&1
	printf "Output saved to l${lab}t${task}val.txt\n"
fi

# Print the output of the program.
args="${@:$argOffset+3}"
printf "\nExecuting program with command: ./l${lab}t${task} $args\n"
./l${lab}t${task} ${@:argOffset+3} >> task${task}_out.txt
printf "Output written to task${task}_out.txt\n\n"

# Make the script.
script task${task}_script.txt -a -c "bash process.sh s ${lab} ${task} $args"

# Clean the script.
cat task${task}_script.txt | perl -pe 's/\e([^\[\]]|\[.*?[a-zA-Z]|\].*?\a)//g' | col -b > task${task}_script-processed.txt

# Make the zip
if $lex ; then
	rm lex.yy.c
fi
printf "\nZipping the following files into ${firstName}${lastName}Lab${lab}Task${task}.zip\n"
zip ${firstName}${lastName}Lab${lab}Task${task} *.c *.h *.l task${task}_out.txt task${task}_script-processed.txt ${@:$argOffset+3}

echo

# Licensed under GPLv3.
# See https://github.com/anthonybrice/cexz/blob/master/LICENSE for more info.