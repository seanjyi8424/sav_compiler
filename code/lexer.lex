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

%%

int main(void) {
	printf("Ctl + D to quit\n");
	yylex();
}