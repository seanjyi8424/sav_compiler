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
.
%%

int main(void) {
	printf("Ctl + D to quit\n");
	yylex();
}