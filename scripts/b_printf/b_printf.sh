#!/bin/bash

# open directory and check makefile

red='\033[1;31m'
nc='\033[0m'
green='\033[01;32m'
yourtest="scripts/b_printf/yourmain1.c"
reftest="scripts/b_printf/refmain.c"
dirName="$1"
if [ -e "$dirName" ] ; then
    bash scripts/tools/norme.sh "$1"
    echo
    cp "$yourtest" "$dirName"
    cp -- "$reftest" "$dirName"
#   sh scripts/b_printf/getheader.sh "$1"
    cd -- "$dirName"
    cat yourmain1.c >> yourmain.c
    rm -f yourmain1.c
    if [ -e "author" ] ; then
        if [ $(cat -e author | sed -n '$s/.*\(.\)$/\1/p') ==  "\$" ] ; then
            echo -e "${green}Author file passes!${nc}"
        else
            echo -e "${red}Author file found but is invalid!${nc}"
        fi
    else
        echo -e "${red}Author file is missing!${nc}"
    fi
    if make re >/dev/null ; then
        if make fclean >/dev/null ; then
            echo -e "${green}Passed makefile test!${nc}"
            make re >/dev/null && make clean >/dev/null
        else
            echo -e "${red}Make fclean error!${nc}"
        fi
    else
        echo -e "${red}Make re error!"
        rm -f yourmain.c refmain.c
        exit 1
    fi
else
    echo -e "${red}Project not found! Use ${nc}./run [projName] [projPath]"
    exit 1
fi

# compile and eval main

mkdir logs

if gcc -g -fsanitize=address -Wall -Wextra -Werror yourmain.c libftprintf.a -o yourProg ; then
    if ./yourProg | cat -e > logs/yourLog; then
        gcc -g -fsanitize=address -Wall -Wextra -Werror refmain.c -o refProg
        rm -f yourmain.c refmain.c
    else
        echo -e "${red}Runtime error!${nc}"
        rm -f yourmain.c refmain.c
        exit 1
    fi
else
    echo -e "${red}Compile error!${nc}"
    rm -f yourmain.c refmain.c
    exit 1
fi

# compare your output to the standard functions

./refProg | cat -e >> logs/refLog

DIFF=$(diff logs/yourLog logs/refLog)

if [ "$DIFF" == "" ] ; then
    echo -e "${green}Passed!${nc}" && echo
else
    echo -e "${red}Outputs dont match! Run ${nc}\"./run.sh diff "$1"\"${red} to view output${nc}"
fi
rm -rf refProg yourProg refProg.dSYM yourProg.dSYM