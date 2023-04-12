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
has {printf("ARRAY: %s\n", yytext);}
is[ ]a[ ]number {printf("INTEGER: %s\n", yytext);}
leave {printf("BREAK: %s\n", yytext);}
do[ ]this[ ]if {printf("IF: %s\n", yytext);}
if[ ]not[ ]do[ ]this {printf("THEN: %s\n", yytext);}
otherwise[]do[ ]this {printf("ELSE: %s\n", yytext);}
show[ ]me {printf("PRINT: %s\n", yytext);}
give[ ]me {printf("WRITE: %s\n", yytext);}
i'm[ ]thinking[ ]that.* {printf("COMMENT: %s\n", yytext);}
use {printf("FUNC_EXEC: %s\n", yytext);}
create[ ]tool {printf("FUNCTION: %s\n", yytext);}
with {printf("BEGIN_PARAMS: %s\n", yytext);}
ok {printf("END_PARAMS: %s\n", yytext);}
"." {printf("PERIOD: %s\n", yytext);}
give[ ]back {printf("RETURN: %s\n", yytext);}
\n {yycolumn = 1;}
. {
	printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", yylineno, yycolumn - yyleng, yytext);
	return 1;
	};
%%

int main(void) {
	printf("Ctl + D to quit\n");
	yylex();
}
