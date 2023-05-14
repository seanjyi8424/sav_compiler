%{
    #include <stdio.h>
    extern int yylineno;
    void yyerror (char const *s) {
        fprintf (stderr, "Error at line %d: %s\n", yylineno, s);
    }
    extern int yyparse();
    extern int yylex();
    extern FILE* yyin;
%}
%define parse.error verbose
%token NUMBER IDENTIFIER INTEGER ARRAY ACCESS_ARRAY ASSIGNMENT PERIOD ADDITION SUBTRACTION DIVISION MULTIPLICATION MOD LESS GREATER GREATER_OR_EQUAL LESSER_OR_EQUAL EQUAL DIFFERENT WHILE IF THEN ELSE PRINT READ FUNC_EXEC FUNCTION BEGIN_PARAMS END_PARAMS NOT AND OR TAB SEMICOLON LEFT_PAREN RIGHT_PAREN RETURN COMMA BREAK QUOTE
%start prog_start
%locations

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


function:    FUNCTION IDENTIFIER BEGIN_PARAMS declarations END_PARAMS SEMICOLON statements {printf("function -> FUNCTION IDENTIFIER BEGIN_PARAMS arguments END_PARAMS SEMICOLON statements\n");}
             ;

statements:   tabs statement {printf("statements -> statement\n");}
	    | tabs statement statements {printf("statements -> statement statements\n");}
	    ;

statement:   %empty 
	   | var expression PERIOD {printf("statement -> var expression PERIOD\n");}
	   | var ASSIGNMENT expression PERIOD {printf("statement -> var ASSIGNMENT expression PERIOD\n");}
           | ELSE SEMICOLON statements {printf("statement -> ELSE SEMICOLON statements\n");}
           | IF bool_exp SEMICOLON statements {printf("statement -> IF bool_exp SEMICOLON statements\n");}
	   | WHILE bool_exp SEMICOLON statements {printf("statement -> WHILE bool-exp SEMICOLON statements\n");}
           | READ var PERIOD {printf("statement -> READ var PERIOD\n");}
           | PRINT var PERIOD {printf("statement -> PRINT var PERIOD\n");}
           | BREAK PERIOD {printf("statement -> BREAK PERIOD\n");}
           | RETURN expression PERIOD {printf("statement -> RETURN expression PERIOD\n");}
	   | expression PERIOD {printf("statement -> expression PERIOD\n");}
           | declaration PERIOD {printf("statement -> declaration PERIOD\n");}
	   ;

tabs:	  single_tab {printf("tabs -> TAB repeat_tabs\n");}
	| tabs single_tab {printf("tabs -> tabs single_tab\n");}
	;

single_tab: TAB {printf("single_tab -> TAB \n");}
	;

bool_exp: negate expression comp expression {printf("bool_exp -> not expression comp expression\n");}
	;

negate: %empty {printf("negate -> epsilon\n");}
  | NOT {printf("negate -> NOT\n");}
  ;

declarations: %empty {printf("declarations -> epsilon\n");}
	| declaration {printf("declarations -> declaration\n");}
	| declaration COMMA declarations {printf("declarations -> declaration COMMA declarations\n");}

declaration: IDENTIFIER array_declaration INTEGER {printf("declaration -> IDENTIFIER array_declaration INTEGER\n");}
  ;

array_declaration: %empty {printf("array_declaration -> epsilon\n");}
  | ARRAY NUMBER {printf("array_declaration -> ARRAY NUMBER\n");}
  ;

comp: LESS {printf("comp -> LESS\n");}
  | GREATER {printf("comp -> GREATER\n");}
  | GREATER_OR_EQUAL {printf("comp -> GREATER_OR_EQUAL\n");}
  | LESSER_OR_EQUAL {printf("comp -> LESSER_OR_EQUAL\n");}
  | EQUAL {printf("comp -> EQUAL\n");}
  | DIFFERENT {printf("comp -> DIFFERENT\n");}
  ;

expression: multiplicative_expr {printf("expression -> multiplicative_expr\n");}
  | multiplicative_expr ADDITION multiplicative_expr {printf("expression -> multiplicative_expr ADDITION multiplicative_expr\n");}
  | multiplicative_expr SUBTRACTION multiplicative_expr {printf("expression -> multiplicative_expr SUBTRACTION multiplicative_expr\n");}
  ;

multiplicative_expr: term {printf("multiplicative_expr -> term\n");}
  | term MULTIPLICATION term {printf("multiplicative_expr -> term MULTIPLICATION term\n");}
  | term DIVISION term {printf("multiplicative_expr -> term DIVISION term\n");}
  | term MOD term {printf("multiplicative_expr -> term MOD term\n");}

term: var {printf("term -> var\n");}
  | INTEGER
  | NUMBER {printf("term -> NUMBER\n");}
  | LEFT_PAREN expression RIGHT_PAREN {printf("term -> LEFT_PAREN expression RIGHT_PAREN\n");}
  | FUNC_EXEC IDENTIFIER BEGIN_PARAMS expressions END_PARAMS {printf("term -> FUNC_EXEC QUOTE IDENTIFIER QUOTE BEGIN_PARAMS expressions END_PARAMS\n");}

expressions: %empty {printf("expressions-> epsilon\n");}
  | expression {printf("expressions-> expression\n");}
  | expression COMMA expressions {printf("expressions-> expression COMMA expressions\n");}

var: IDENTIFIER {printf("var-> QUOTE IDENTIFIER QUOTE\n");}
  | IDENTIFIER ACCESS_ARRAY expression {printf("var-> QUOTE IDENTIFIER QUOTE ACCESS_ARRAY expression\n");}
%%


int main(void) {
	yyin = stdin;
	
	do {
	  printf("Ctrl + D to quit\n");
	  yyparse();
	} while(!feof(yyin));
	return 0;
}
