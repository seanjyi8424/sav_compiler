%{
    #include <stdio.h>

    void yyerror (char const *s) {
        fprintf (stderr, "%s\n", s);
    }

    int yylex();
%}

%start prog_start
%token NUMBER IDENTIFIER INTEGER ARRAY ACCESS_ARRAY ASSIGNMENT PERIOD ADDITION SUBTRACTION DIVISION MULTIPLICATION MOD LESS GREATER GREATER_OR_EQUAL LESSER_OR_EQUAL EQUAL DIFFERENT WHILE IF THEN ELSE PRINT READ FUNC_EXEC FUNCTION BEGIN_PARAMS END_PARAMS NOT AND OR TAB SEMICOLON LEFT_PAREN RIGHT_PAREN RETURN COMMA BREAK QUOTE

%%


prog_start:   %empty {printf("prog_start -> epsilon\n");}
            ;

/*
TODO: Commented out to compile correctly

functions:     function {printf("functions -> function\n");}
            |  function functions {printf("functions -> function functions\n");}
            ;


function:    FUNCTION IDENTIFIER BEGIN_PARAMS arguments END_PARAMS SEMICOLON statements
             {printf("function -> ...");}
             ;

arguments:   %empty
            | argument repeat_arguments
            ;

repeat_arguments:    %empty
                    | COMMA argument repeat_arguments
                    ;

argument: INTEGER IDENTIFIER {printf("argument -> INTEGER IDENTIFIER");}
          ;

*/

%%

int main(void) {
	printf("Ctl + D to quit\n");
	yylex();
}