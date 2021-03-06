#!/bin/bash

# open directory and check makefile

red='\033[1;31m' 
nc='\033[0m'
green='\033[01;32m'
yourtest="scripts/b_libft/yourmain.c"
reftest="scripts/b_libft/refmain.c"
dirName="$1"
if [ -e "$dirName" ] ; then
    bash scripts/tools/norme.sh "$1"
    echo
    cp -- "$yourtest" "$dirName"
    cp -- "$reftest" "$dirName"
    cd -- "$dirName"
    if [ -e "author" ] ; then
        if [ $(cat -e author | sed -n '$s/.*\(.\)$/\1/p') ==  "$" ] ; then
            echo -e "${green}author file passes!${nc}"
        else
            echo -e "${red}author file found but is invalid!${nc}"
        fi
    else
        echo -e "${red}author file is missing!${nc}"
    fi
    if make re >/dev/null ; then
        if make fclean >/dev/null ; then
            echo -e "${green}passed makefile test!${nc}"
            make re >/dev/null && make clean >/dev/null
        else
            echo -e "${red}make fclean error!${nc}"
        fi
    else
        echo -e "${red}make re error!${nc}"
        rm -rf yourmain.c refmain.c
        exit 1
    fi
else
    echo -e "${red}project not found! Use ${nc}./run [projName] [projPath]"
    exit 1
fi

# compile and eval main

mkdir logs

if gcc -g -fsanitize=address -Wall -Wextra -Werror yourmain.c libft.a -o yourProg ; then
    if ./yourProg | cat -e > logs/yourLog; then
        gcc -g -fsanitize=address -Wall -Wextra -Werror refmain.c -o refProg
        rm -rf yourmain.c refmain.c yourProg.dSYM
    else
        echo -e "${red}runtime error!${nc}"
        rm -rf yourmain.c refmain.c yourProg.dSYM
        exit 1
    fi
else
    echo -e "${red}compile error!${nc}"
    rm -rf yourmain.c refmain.c yourProg.dSYM
    exit 1
fi

# compare your output to the standard functions

./refProg | cat -e > logs/refLog
DIFF=$(diff logs/yourLog logs/refLog)

if [ "$DIFF" = "" ] ; then
    echo -e "${green}passed!${nc}" && echo
else
    echo -e "${red}outputs dont match! Run ${nc}\"./run.sh diff "$1"\"${red} to view output${nc}"
fi
rm -rf refProg yourProg yourProg.dSYM refProg.dSYM
