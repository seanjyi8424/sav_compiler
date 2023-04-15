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

{DIGIT}+ {printf("NUMBER: %s\n", yytext);} 
{QUOTE}[a-z0-9 ]*{QUOTE} {printf("IDENTIFIER: %s\n", yytext);}
{QUOTE}[^\"]*{QUOTE} {
  // IDENTIFIER ERROR
  printf("Error at line %d, column %d: identifier %s must only contain lowercase letters, numbers, and spaces\n", yylineno, yycolumn - yyleng, yytext);
  return 1;
  }
has {printf("ARRAY: %s\n", yytext);}
is[ ]a[ ]number {printf("INTEGER: %s\n", yytext);}
numbers {printf("INTEGER: %s\n", yytext);}
is {printf("ASSIGNMENT: %s\n", yytext);}
plus {printf("ADDITION: %s\n", yytext);}
minus {printf("SUBTRACTION: %s\n", yytext);}
divided[ ]by {printf("DIVISION: %s\n", yytext);}
times {printf("MULTIPLICATION: %s\n", yytext);}
modulo {printf("MOD: %s\n", yytext);}
is[ ]greater[ ]than[ ]or[ ]equal[ ]to {printf("GREATER_OR_EQUAL: %s\n", yytext);}
is[ ]less[ ]than[ ]or[ ]equal[ ]to {printf("LESSER_OR_EQUAL: %s\n", yytext);}
is[ ]less[ ]than {printf("LESS: %s\n", yytext);}
is[ ]greater[ ]than {printf("GREATER: %s\n", yytext);}
equals {printf("EQUAL: %s\n", yytext);}
does[ ]not[ ]equal {printf("DIFFERENT: %s\n", yytext);}
do[ ]this[ ]until {printf("WHILE: %s\n", yytext);}
";" {printf("SEMICOLON: %s\n", yytext);}
"\t" {printf("TAB: %s\n", yytext);}

leave {printf("BREAK: %s\n", yytext);}
do[ ]this[ ]if {printf("IF: %s\n", yytext);}
if[ ]not[ ]do[ ]this {printf("THEN: %s\n", yytext);}
otherwise[]do[ ]this {printf("ELSE: %s\n", yytext);}
show[ ]me {printf("PRINT: %s\n", yytext);}
give[ ]me {printf("WRITE: %s\n", yytext);}
i'm[ ]thinking[ ]that.* { }
use {printf("FUNC_EXEC: %s\n", yytext);}
create[ ]tool {printf("FUNCTION: %s\n", yytext);}
with {printf("BEGIN_PARAMS: %s\n", yytext);}
ok {printf("END_PARAMS: %s\n", yytext);}
"." {printf("PERIOD: %s\n", yytext);}
give[ ]back {printf("RETURN: %s\n", yytext);}
\n {yycolumn = 1;}

[ ] {}
[ ]+ {
  // WHITESPACE ERROR
	printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", yylineno, yycolumn - yyleng, yytext);
	return 1;
}

. {
  // UNRECOGNIZED SYMBOL ERROR
	printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", yylineno, yycolumn - yyleng, yytext);
	return 1;
	};

%%

int main(void) {
	printf("Ctl + D to quit\n");
	yylex();
}