%{
#include "parser.tab.h"
#include <string.h>
%}
%option noyywrap
%%
[ \t\n\r]   { /* skip */ }
"print-num"  { return PRINT_NUM; }
"print-bool" { return PRINT_BOOL; }
"define"     { return DEFINE; }
"if"         { return IF; }
"fun"        { return FUN; }
"and"        { return AND; }
"or"         { return OR; }
"not"        { return NOT; }
"mod"        { return MOD; }
"#t"         { yylval.bool_val = 1; return BOOL_VAL; }
"#f"         { yylval.bool_val = 0; return BOOL_VAL; }
0|[1-9][0-9]*|-[1-9][0-9]* { yylval.num_val = atoi(yytext); return NUMBER; }
[a-z][a-z0-9-]* { yylval.id_name = strdup(yytext); return ID; }
.            { return yytext[0]; }
%%