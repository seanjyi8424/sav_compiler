%{
// this is where we have our definitions
#include <stdio.h>

%}

DIGIT [0-9]
ALPHA [a-zA-Z]

%%
{DIGIT}+ {printf("NUMBER: %s\n", yytext);} 
{ALPHA}+ {printf("ALPHA: %s\n", yytext);} 

%%

int main(void) {
	printf("Ctl + D to quit\n");
	yylex();
}