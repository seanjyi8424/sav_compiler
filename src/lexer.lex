%option noyywrap

%{
// this is where we have our definitions
#include <stdio.h>
#define YY_DECL int yylex(void)

#include "y.tab.h"
int yycolumn = 1;
// code for generating line and column number was taken from: https://stackoverflow.com/questions/26854374/how-do-i-use-yy-bs-lineno-and-yy-bs-column-in-flex
#define YY_USER_ACTION                                                   \
  start_line = prev_yylineno; start_column = yycolumn;                   \
  if (yylineno == prev_yylineno) yycolumn += yyleng;                     \
  else {                                                                 \
    for (yycolumn = 1; yytext[yyleng - yycolumn] != '\n'; ++yycolumn) {} \
    prev_yylineno = yylineno;                                            \
  }
%}

%option yylineno

DIGIT [0-9]
ALPHA [a-zA-Z]
QUOTE \"

%%
   /* Any indented text before the first rule goes at the top of the lexer.  */
   int start_line, start_column;
   int prev_yylineno = yylineno;

{DIGIT}+ {return NUMBER;} 
{QUOTE}[a-z0-9 ]*{QUOTE} {return IDENTIFIER;}
{QUOTE}[^\"]*{QUOTE} {
  // IDENTIFIER ERROR
  // TODO: Figure out how to handle syntax errors
  printf("Error at line %d, column %d: identifier %s must only contain lowercase letters, numbers, and spaces\n", yylineno, yycolumn - yyleng, yytext);
  }
has {return ARRAY;}
is[ ]a[ ]number {return INTEGER;}
numbers {printf("INTEGER\n");}
is {return ASSIGNMENT;}
plus {return ADDITION;}
minus {return SUBTRACTION;}
divided[ ]by {return DIVISION;}
times {return MULTIPLICATION;}
modulo|mod {return MOD;}
is[ ]greater[ ]than[ ]or[ ]equal[ ]to {return GREATER_OR_EQUAL;}
is[ ]less[ ]than[ ]or[ ]equal[ ]to {return LESSER_OR_EQUAL;}
is[ ]less[ ]than {return LESS;}
is[ ]greater[ ]than {return GREATER;}
equals {return EQUAL;}
does[ ]not[ ]equal {return DIFFERENT;}
do[ ]this[ ]until {return WHILE;}
";" {return SEMICOLON;}
"    "|"\t" {return TAB;}
at {return ACCESS_ARRAY;}
"(" {return LEFT_PAREN;}
")" {return RIGHT_PAREN;}
, {return COMMA;}

leave {return BREAK;}
do[ ]this[ ]if {return IF;}
if[ ]not[ ]do[ ]this {return THEN;}
otherwise[ ]do[ ]this {return ELSE;}
show[ ]me {return PRINT;}
give[ ]me {return READ;}
i'm[ ]thinking[ ]that.* { }
use {return FUNC_EXEC;}
create[ ]tool {return FUNCTION;}
with {return BEGIN_PARAMS;}
ok {return END_PARAMS;}
"." {return PERIOD;}
give[ ]back {return RETURN;}
\n {yycolumn = 1;}

[ ] {}
[ ]+ {
  // WHITESPACE ERROR
	printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", yylineno, yycolumn - yyleng, yytext);
}

. {
  // UNRECOGNIZED SYMBOL ERROR
	printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", yylineno, yycolumn - yyleng, yytext);
	};

%%
