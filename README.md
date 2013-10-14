# cexz #

This script will **C**ompile, **EX**ecute, and **Z**ip C programs with the naming scheme used by AJ at CSUCI.

To use it, open `process.sh` and change the `firstName` and `lastName` variables to your own. Place the script in the folder that contains the source files you wish to compile, navigate to the folder in a terminal and run with the syntax:

    $ ./process.sh [lab#] [task#] [run arguments]

where run arguments are the arguments with which you wish to run your executable. By default, process.sh will make the last argument a replacement for stdin for it's second run when making a script output file.

Place `l` before `lab#` to run `$ lex *.l` before compiling. Place `v` before the `lab#` to make a valgrind executable and check for memory leaks, with the ouput saved to `l[lab#]t[task#]val.txt`.

TRY IT ON BACKUP COPIES FIRST! As is, this shouldn't cause any harm to your source but awful things can happen if you mess with the sed commands in process.sh.

To be a true pro, add 'alias cexz="[any file path to process.sh]"' to your .bashrc file so that you can run the script with the cexz command and stop moving the .sh file around.
