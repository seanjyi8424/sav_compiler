%{
// this is where we have our definitions
#include <stdio.h>
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

{DIGIT}+ {printf("NUMBER %s\n", yytext);} 
{QUOTE}[a-z0-9 ]*{QUOTE} {printf("IDENTIFIER %s\n", yytext);}
{QUOTE}[^\"]*{QUOTE} {
  // IDENTIFIER ERROR
  printf("Error at line %d, column %d: identifier %s must only contain lowercase letters, numbers, and spaces\n", yylineno, yycolumn - yyleng, yytext);
  return 1;
  }
has {printf("ARRAY\n");}
is[ ]a[ ]number {printf("INTEGER\n");}
numbers {printf("INTEGER\n");}
is {printf("ASSIGNMENT\n");}
plus {printf("ADDITION\n");}
minus {printf("SUBTRACTION\n");}
divided[ ]by {printf("DIVISION\n");}
times {printf("MULTIPLICATION\n");}
modulo|mod {printf("MOD\n");}
is[ ]greater[ ]than[ ]or[ ]equal[ ]to {printf("GREATER_OR_EQUAL\n");}
is[ ]less[ ]than[ ]or[ ]equal[ ]to {printf("LESSER_OR_EQUAL\n");}
is[ ]less[ ]than {printf("LESS\n");}
is[ ]greater[ ]than {printf("GREATER\n");}
equals {printf("EQUAL\n");}
does[ ]not[ ]equal {printf("DIFFERENT\n");}
do[ ]this[ ]until {printf("WHILE\n");}
";" {printf("SEMICOLON\n");}
"    "|"\t" {printf("TAB\n");}
at {printf("ACCESS\n");}
"(" {printf("L_PAREN\n");}
")" {printf("R_PAREN\n");}
, {printf("COMMA\n");}

leave {printf("BREAK\n");}
do[ ]this[ ]if {printf("IF\n");}
if[ ]not[ ]do[ ]this {printf("THEN\n");}
otherwise[ ]do[ ]this {printf("ELSE\n");}
show[ ]me {printf("PRINT\n");}
give[ ]me {printf("WRITE\n");}
i'm[ ]thinking[ ]that.* { }
use {printf("FUNC_EXEC\n");}
create[ ]tool {printf("FUNCTION\n");}
with {printf("BEGIN_PARAMS\n");}
ok {printf("END_PARAMS\n");}
"." {printf("PERIOD\n");}
give[ ]back {printf("RETURN\n");}
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

int main(void) {
	printf("Ctl + D to quit\n");
	yylex();
}
