%option noyywrap

%{
// this is where we have our definitions
#include <string.h>
#include <string>
#include "y.tab.h"
int currLine = 1, currPos =1;

/*#define YY_DECL int yylex(void)
int yycolumn = 1;*/

extern char *identToken;
extern int numberToken;
// code for generating line and column number was taken from: https://stackoverflow.com/questions/26854374/how-do-i-use-yy-bs-lineno-and-yy-bs-column-in-flex

/*#define YY_USER_ACTION                                                   \
  start_line = prev_yylineno; start_column = yycolumn;                   \
  if (yylineno == prev_yylineno) yycolumn += yyleng;                     \
  else {                                                                 \
    for (yycolumn = 1; yytext[yyleng - yycolumn] != '\n'; ++yycolumn) {} \
    prev_yylineno = yylineno;                                            \
  }*/
  
  void convertIdentifier(char * str) {
    size_t length = strlen(str);
  
    if (length <= 2) {  // If the string has 2 or fewer characters, it becomes an empty string
      str[0] = '\0';
    } else {
      for (size_t i = 0; i < length - 2; i++) {
        str[i] = str[i + 1];  // Shift characters to the left by one position
      }

      str[length - 2] = '\0';  // Terminate the string at the new end
    }
  
    // Replace spaces with underscores
    for (size_t i = 0; i < length; i++) {
      if (str[i] == ' ') {
        str[i] = '_';
      }
    }
  }
%}

DIGIT [0-9]
ALPHA [a-zA-Z]
QUOTE \"

%%
   /* Any indented text before the first rule goes at the top of the lexer.  */
   /*int start_line, start_column;
   int prev_yylineno = yylineno; */

{DIGIT}+ {
	currPos += yyleng;
	char *token = new char[yyleng];
  strcpy(token, yytext);
  yylval.op_val = token;
  numberToken = atoi(yytext);
	return NUMBER;} 
{QUOTE}[a-z0-9 ]*{QUOTE} {
  currPos += yyleng;
  char * token = new char[yyleng];
  strcpy(token, yytext);
  convertIdentifier(token);
  yylval.op_val = token;
  identToken = yytext; 
  return IDENTIFIER;
}
{QUOTE}[^\"]*{QUOTE} {
  // IDENTIFIER ERROR
  // TODO: Figure out how to handle syntax errors
  printf("Error at line %d, column %d: identifier %s must only contain lowercase letters, numbers, and spaces\n", currLine, currPos, yytext);
  }
has {currPos += yyleng; return ARRAY;}
is[ ]a[ ]number {currPos += yyleng; return INTEGER;}
numbers {currPos += yyleng; return INTEGER;}
is {currPos += yyleng; return ASSIGNMENT;}
plus {
  currPos += yyleng;
	char *token = new char[yyleng];
  strcpy(token, yytext);
  yylval.op_val = token;
  return ADDITION;
}
minus {
  currPos += yyleng;
	char *token = new char[yyleng];
  strcpy(token, yytext);
  yylval.op_val = token;
  return SUBTRACTION;
  }
divided[ ]by {
  currPos += yyleng;
	char *token = new char[yyleng];
  strcpy(token, yytext);
  yylval.op_val = token;
  return DIVISION;
}
times {
  currPos += yyleng;
	char *token = new char[yyleng];
  strcpy(token, yytext);
  yylval.op_val = token;
  return MULTIPLICATION;
}
modulo|mod {
  currPos += yyleng; 
	char *token = new char[yyleng];
  strcpy(token, yytext);
  yylval.op_val = token;
  return MOD;
}
is[ ]greater[ ]than[ ]or[ ]equal[ ]to {currPos += yyleng; return GREATER_OR_EQUAL;}
is[ ]less[ ]than[ ]or[ ]equal[ ]to {currPos += yyleng; return LESSER_OR_EQUAL;}
is[ ]less[ ]than {currPos += yyleng; return LESS;}
is[ ]greater[ ]than {currPos += yyleng; return GREATER;}
equals {currPos += yyleng; return EQUAL;}
does[ ]not[ ]equal {currPos += yyleng; return DIFFERENT;}
do[ ]this[ ]until {currPos += yyleng; return WHILE;}
";" {currPos += yyleng; return SEMICOLON;}
"    "|"\t" {currPos += yyleng; return TAB;}
at {currPos += yyleng; return ACCESS_ARRAY;}
"(" {currPos += yyleng; return LEFT_PAREN;}
")" {currPos += yyleng; return RIGHT_PAREN;}
\{ {currPos += yyleng; return LEFT_CBRACKET;}
\} {currPos += yyleng; return RIGHT_CBRACKET;}
, {currPos += yyleng; return COMMA;}

leave {currPos += yyleng; return BREAK;}
continue {currPos += yyleng; return CONTINUE;}
do[ ]this[ ]if {currPos += yyleng; return IF;}
if[ ]not[ ]do[ ]this {currPos += yyleng; return THEN;}
otherwise[ ]do[ ]this {currPos += yyleng; return ELSE;}
show[ ]me {currPos += yyleng; return PRINT;}
give[ ]me {currPos += yyleng; return READ;}
i'm[ ]thinking[ ]that.* { }
use {currPos += yyleng; return FUNC_EXEC;}
create[ ]tool {currPos += yyleng; return FUNCTION;}
with {currPos += yyleng; return BEGIN_PARAMS;}
ok {currPos += yyleng; return END_PARAMS;}
"." {currPos += yyleng; return PERIOD;}
give[ ]back {currPos += yyleng; return RETURN;}
\n {/*yycolumn = 1;*/ currLine++; currPos = 1;}

[ ] {}
[ ]+ {
  // WHITESPACE ERROR
	/*printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", yylineno, yycolumn - yyleng, yytext);*/
	printf("Error at line %d, column %d: identifier %s must only contain lowercase letters, numbers, and spaces\n", currLine, currPos, yytext);
}

. {
  // UNRECOGNIZED SYMBOL ERROR
	/*printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", yylineno, yycolumn - yyleng, yytext);*/
	printf("Error at line %d, column %d: identifier %s must only contain lowercase letters, numbers, and spaces\n", currLine, currPos, yytext);
	}

%%
