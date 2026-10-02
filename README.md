# Minilisp

This is a minilisp interpreter build by lex and yacc. 

Make sure you have build the environment for lex and yacc.

#How to run

`bison -d parser.y` This will output the C file for yacc.

`flex lexer.l`      This will output the C file for lex.

`gcc lex.yy.c parser.tab.c -o minilisp`     This will compile the file into an exe file called minilisp.

`./minilisp <your_script.lsp>`  This can run the lisp file. Ex. `./minilisp 01_1.lsp`
