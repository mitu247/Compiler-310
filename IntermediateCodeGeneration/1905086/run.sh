#!/bin/bash
yacc -d -y 1905086.y
echo 'Generated the parser C file as well the header file'
g++ -w -c -o y.o y.tab.c
echo 'Generated the parser object file'
flex 1905086.l
echo 'Generated the scanner C file'
g++ -w -c -o l.o lex.yy.c
#g++ -fpermissive -w -c -o l.o lex.yy.c
echo 'Generated the scanner object file'
g++ y.o l.o -lfl
echo 'All ready, running'
./a.out input.c
