%{
    #include <stdio.h>

    void yyerror (char const *s) {
        fprintf (stderr, "Parse error: %s\n.", s);
    }
    extern int yyparse();
    extern int yylex();
    extern FILE* yyin;
%}
%define parse.error verbose
%token NUMBER IDENTIFIER INTEGER ARRAY ACCESS_ARRAY ASSIGNMENT PERIOD ADDITION SUBTRACTION DIVISION MULTIPLICATION MOD LESS GREATER GREATER_OR_EQUAL LESSER_OR_EQUAL EQUAL DIFFERENT WHILE IF THEN ELSE PRINT READ FUNC_EXEC FUNCTION BEGIN_PARAMS END_PARAMS NOT AND OR TAB SEMICOLON LEFT_PAREN RIGHT_PAREN RETURN COMMA BREAK QUOTE
%start prog_start

%%


prog_start:   %empty {printf("prog_start -> epsilon\n");}      
	      | functions {printf("prog_start -> functions\n");}
	      ;

/*
TODO: Commented out to compile correctly
*/

functions:     function {printf("functions -> function\n");}
            |  function functions {printf("functions -> function functions\n");}
            ;


function:    FUNCTION IDENTIFIER BEGIN_PARAMS arguments END_PARAMS SEMICOLON statements {printf("function -> FUNCTION IDENTIFIER BEGIN_PARAMS arguments END_PARAMS SEMICOLON statements\n");}
             ;

arguments:    %empty  {printf("arguments -> epsilon\n");}
            | argument repeat_arguments
            ;

repeat_arguments:     %empty
                    | COMMA argument repeat_arguments
                    ;

argument: IDENTIFIER INTEGER {printf("argument -> IDENTIFIER INTEGER\n");}
          ;

statements:   tabs statement {printf("statements -> statement\n");}
	    | tabs statement statements {printf("statements -> statement statements\n");}
	    ;

statement:   %empty 
	   | variable expression PERIOD {printf("statement -> variable expression PERIOD\n");}
	   | variable ASSIGNMENT expression PERIOD {printf("statement -> variable ASSIGNMENT expression PERIOD\n");}
           | IF bool_exp SEMICOLON statements ELSE statements {printf("statement -> \n");}
           | WHILE bool_exp SEMICOLON statements {printf("statement -> WHILE bool-exp SEMICOLON statements\n");}
           | READ variable PERIOD {printf("statement -> READ variable PERIOD\n");}
           | PRINT variable PERIOD {printf("statement -> PRINT variable PERIOD\n");}
           | BREAK PERIOD {printf("statement -> BREAK PERIOD\n");}
           | expression PERIOD {printf("statement -> expression PERIOD\n");}
	   ;

tabs:	  TAB repeat_tabs {printf("tabs -> TAB repeat_tabs\n");}
	;

repeat_tabs: %empty
	| TAB repeat_tabs {printf("repeat_tabs -> TAB repeat_tabs\n");}
	;

variable: IDENTIFIER {printf("variable -> IDENTIFIER\n");}
	;

bool_exp: %empty {printf("bool-exp -> epsilon\n");} /*placeholder for now*/
	;

expression: INTEGER {printf("expression -> INTEGER\n");}
	| NUMBER {printf("expression -> NUMBER\n");}
	;
%%

int main(void) {
	yyin = stdin;
	
	do {
	  printf("Ctrl + D to quit\n");
	  yyparse();
	} while(!feof(yyin));
	return 0;
}
