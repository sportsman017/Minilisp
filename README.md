# Minilisp

This is a minilisp interpreter build by lex and yacc. 

Make sure you have build the environment for lex and yacc.

#How to run

`bison -d parser.y` This will output the C file for yacc.

`flex lexer.l`      This will output the C file for lex.

`gcc lex.yy.c parser.tab.c -o minilisp`     This will compile the file into an exe file called minilisp.

`./minilisp <your_script.lsp>`  This can run the lisp file. Ex. `./minilisp 01_1.lsp`


# MiniLisp Interpreter

A MiniLisp interpreter implementation with support for basic language
features and advanced function mechanisms.

## Features

### Core Features
- Syntax validation
- `print` statement
- Numerical operations
- Logical operations
- `if` expressions
- Variable definition
- Anonymous functions
- Named functions

### Bonus Features
- Recursion
- Type checking
- Nested functions with static scope
- First-class functions
- Function passing
- Closure support

## Overview

This project implements a MiniLisp interpreter that supports fundamental
language features such as expressions, variables, conditionals, and
functions. It also extends the interpreter with recursion, type checking,
nested functions, and first-class functions with closure support.

The project focuses on understanding the implementation of programming
language features, including syntax handling, function execution, variable
scope, and runtime behavior.
