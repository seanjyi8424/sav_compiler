%{
    #include <stdio.h>

    void yyerror (char const *s) {
        fprintf (stderr, "Parse error: %s\n.", s);
    }
    extern int yyparse();
    extern int yylex();
    extern FILE* yyin;
%}

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


function:    FUNCTION IDENTIFIER BEGIN_PARAMS arguments END_PARAMS SEMICOLON //statements
             {printf("function -> ...\n");}
             ;

arguments:    %empty
            | argument repeat_arguments
            ;

repeat_arguments:     %empty
                    | COMMA argument repeat_arguments
                    ;

argument: IDENTIFIER INTEGER PERIOD {printf("argument -> IDENTIFIER INTEGER");}
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
