%{
    #include <stdio.h>

    void yyerror (char const *s) {
        fprintf (stderr, "%s\n", s);
    }

    int yylex();
%}

%start prog_start
%token FUNCTION IDENTIFIER BEGIN_PARAMS END_PARAMS SEMICOLON

%%


prog_start:   %empty {printf("prog_start -> epsilon\n");}
            ;

/*
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