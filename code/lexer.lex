%{
// this is where we have our definitions
#include <stdio.h>

%}

DIGIT [0-9]
ALPHA [a-zA-Z]
QUOTE \"

%%
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
.
%%

int main(void) {
	printf("Ctl + D to quit\n");
	yylex();
}
