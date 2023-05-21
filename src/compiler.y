%{
#include <stdio.h>
#include<string>
#include<vector>
#include<string.h>
#include<stdlib.h>
    //extern int yylineno;
    //extern int yyparse();
    extern int yylex(void);
    extern int currLine;
    void yyerror (char const *s) {
        fprintf (stderr, "Error at line %d: %s\n", currLine, s);
    }
    //extern FILE* yyin;
    
    /*Phase 3 begin*/
char *identToken;
int  numberToken;
int  count_names = 0;

enum Type { Integer, Array };

struct Symbol {
  std::string name;
  Type type;
};

struct Function {
  std::string name;
  std::vector<Symbol> declarations;
};

std::vector<Function> symbol_table;

// remember that Bison is a bottom up parser: that it parses leaf nodes first before
// parsing the parent nodes. So control flow begins at the leaf grammar nodes
// and propagates up to the parents.
Function *get_function() {
  int last = symbol_table.size()-1;
  if (last < 0) {
    printf("***Error. Attempt to call get_function with an empty symbol table\n");
    printf("Create a 'Function' object using 'add_function_to_symbol_table' before\n");
    printf("calling 'find' or 'add_variable_to_symbol_table'");
    exit(1);
  }
  return &symbol_table[last];
}

// find a particular variable using the symbol table.
// grab the most recent function, and linear search to
// find the symbol you are looking for.
// you may want to extend "find" to handle different types of "Integer" vs "Array"
bool find(std::string &value) {
  Function *f = get_function();
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->name == value) {
      return true;
    }
  }
  return false;
}

// when you see a function declaration inside the grammar, add
// the function name to the symbol table
void add_function_to_symbol_table(std::string &value) {
  Function f; 
  f.name = value; 
  symbol_table.push_back(f);
}

// when you see a symbol declaration inside the grammar, add
// the symbol name as well as some type information to the symbol table
void add_variable_to_symbol_table(std::string &value, Type t) {
  Symbol s;
  s.name = value;
  s.type = t;
  Function *f = get_function();
  f->declarations.push_back(s);
}

// a function to print out the symbol table to the screen
// largely for debugging purposes.
void print_symbol_table(void) {
  printf("symbol table:\n");
  printf("--------------------\n");
  for(int i=0; i<symbol_table.size(); i++) {
    printf("function: %s\n", symbol_table[i].name.c_str());
    for(int j=0; j<symbol_table[i].declarations.size(); j++) {
      printf("  locals: %s\n", symbol_table[i].declarations[j].name.c_str());
    }
  }
  printf("--------------------\n");
}

struct CodeNode {
    std::string code; // generated code as a string.
    std::string name;
};

// utility functions from slides
bool has_main() {
  bool TF = false;
  for (int i = 0; i < symbol_table.size(); i++) {
    Function *f = &symbol_table[i];
    if (f->name == "main") {
      TF = true;
    }
  }
  return TF;
}

std::string create_temp() {
  static int num = 0;
  std::string value = "_temp" + std::to_string(num);
  num += 1;
  return value;
}

std::string decl_temp_code(std::string &temp) {
  return std::string(". ") + temp + std::string("\n");
}

    /*Phase 3 end*/
%}


%union {
  struct CodeNode *node;
  char *op_val;
  int int_val;
}

%define parse.error verbose
%token /*NUMBER IDENTIFIER*/ INTEGER ARRAY ACCESS_ARRAY ASSIGNMENT PERIOD LESS GREATER GREATER_OR_EQUAL LESSER_OR_EQUAL EQUAL DIFFERENT WHILE IF THEN ELSE PRINT READ FUNC_EXEC FUNCTION BEGIN_PARAMS END_PARAMS NOT AND OR TAB SEMICOLON LEFT_PAREN RIGHT_PAREN RETURN COMMA BREAK QUOTE
%token <op_val> NUMBER 
%token <op_val> IDENTIFIER
%token  <op_val> ADDITION
%token  <op_val> SUBTRACTION
%token  <op_val> DIVISION
%token  <op_val> MULTIPLICATION 
%token  <op_val> MOD 
%type  <op_val> var 
%type  <op_val> term 
%type  <op_val> function_ident
%type  <node>   functions
%type  <node>   function
%type  <node>   declarations
%type  <node>   declaration
%type  <node>   statements
%type  <node>   statement
%start prog_start
%locations

%%


prog_start: functions 
{
  CodeNode* node = $1;
  printf("Generated code:\n");
  printf("%s\n", node->code.c_str());
}
;

functions: %empty 
{
  CodeNode* node = new CodeNode;
  $$ = node;
}
| function functions 
{
  CodeNode* code_node1 = $1;
  CodeNode* code_node2 = $2;
  CodeNode* node = new CodeNode;
  node->code = code_node1->code + code_node2->code;
  $$ = node;
}
;


function: FUNCTION function_ident BEGIN_PARAMS declarations END_PARAMS SEMICOLON statements 
{
  CodeNode *node = new CodeNode;
  std::string func_name = $2;
  node->code = "";
  // add the "func func_name"
  node->code += std::string("func ") + func_name + std::string("\n");

  // add param declaration code
  CodeNode *declarations = $4;
  node->code += declarations->code;
  // printf("%s\n", declarations->code.c_str());

  CodeNode* statements = $7;
  node->code += statements->code;
  // printf("%s\n", statements->code.c_str());

  node->code += std::string("endfunc\n");
  // printf("%s\n", node->code.c_str());
  $$ = node;
  // * end of fucntion from video
  // printf("endfunc\n");
}
;

function_ident: IDENTIFIER
{
  // add the function to the symbol table.
  std::string func_name = $1;
  add_function_to_symbol_table(func_name);
  // * generating code using printf in phase 3
  // * start of function from video
  // printf("func %s\n", func_name.c_str());
  $$ = $1;
}

statements: tabs statement 
{
  CodeNode* node = $2;
  $$ = node;
}
| tabs statement statements 
{
  CodeNode* code_node1 = $2;
  CodeNode* code_node2 = $3;
  CodeNode* node = new CodeNode;
  node->code = code_node1->code + code_node2->code;
  $$ = node;
}
;

statement: %empty 
{
  CodeNode* node = new CodeNode;
  $$ = node;
}
| var expression PERIOD 
{
}
| var ASSIGNMENT expression PERIOD 
{
}
| ELSE SEMICOLON statements 
{
}
| IF bool_exp SEMICOLON statements 
{
}
| WHILE bool_exp SEMICOLON statements 
{
}
| READ var PERIOD 
{
  CodeNode *node = new CodeNode;
  std::string var = $2;
  node->code = std::string(".< ") + var + std::string("\n");
  $$ = node;
}
| PRINT var PERIOD 
{
  CodeNode *node = new CodeNode;
  std::string var = $2;
  node->code = std::string(".> ") + var + std::string("\n");
  $$ = node;

}
| BREAK PERIOD 
{
}
| RETURN expression PERIOD
{
}
| expression PERIOD 
{
}
| declaration PERIOD 
{
  CodeNode* code_node1 = $1;
  CodeNode* node = new CodeNode;
  node->code = code_node1->code;
  $$ = node;
}
;

tabs: single_tab 
{
}
| tabs single_tab
{
}
;

single_tab: TAB 
{
}
;

bool_exp: negate expression comp expression 
{
}
;

negate: %empty 
{
}
| NOT 
{
}
;

declarations: %empty 
{
  CodeNode* node = new CodeNode;
  $$ = node;
}
| declaration COMMA declarations 
{
  CodeNode* code_node1 = $1;
  CodeNode* code_node2 = $3;
  CodeNode* node = new CodeNode;
  node->code = code_node1->code + code_node2->code;
  $$ = node;
}

declaration: IDENTIFIER array_declaration INTEGER 
{
  CodeNode *code_node = new CodeNode;
  std::string id = $1;
  code_node->code = std::string(". ") + id + std::string("\n");
  $$ = code_node;

  std::string value = $1;
  Type t = Integer;
  add_variable_to_symbol_table(value, t);
}
;

array_declaration: %empty 
{
}
| ARRAY NUMBER 
{
}
;

comp: LESS 
{
}
| GREATER 
{
}
| GREATER_OR_EQUAL 
{
}
| LESSER_OR_EQUAL 
{
}
| EQUAL 
{
}
;

expression: multiplicative_expr 
{
}
| multiplicative_expr ADDITION multiplicative_expr 
{
}
| multiplicative_expr SUBTRACTION multiplicative_expr
{
}
;

multiplicative_expr: term 
{
}
| term MULTIPLICATION term 
{
}
| term DIVISION term 
{
}
| term MOD term 
{
}

term: var 
{
  // $$ = $1;
}
| INTEGER
{
  // $$ = $1;
}
| NUMBER 
{
  // $$ = $1;
}
| LEFT_PAREN expression RIGHT_PAREN 
{
}
| FUNC_EXEC IDENTIFIER BEGIN_PARAMS expressions END_PARAMS 
{
}

expressions: %empty 
{
}
| expression 
{
}
| expression COMMA expressions 
{
}

var: IDENTIFIER 
{
  $$ = $1;
}
| IDENTIFIER ACCESS_ARRAY expression 
{
}
%%


int main(int argc, char **argv) {
	/*yyin = stdin;
	
	do {
	  printf("Ctrl + D to quit\n");
	  yyparse();
	} while(!feof(yyin));
	return 0;*/
	yyparse();
  // print_symbol_table();
   	return 0;
}
