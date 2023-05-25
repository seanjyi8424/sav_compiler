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
    bool is_array = false;
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
  return std::string(". ") + temp;
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
%token <op_val> ADDITION
%token <op_val> SUBTRACTION
%token <op_val> DIVISION
%token <op_val> MULTIPLICATION 
%token <op_val> MOD
%token <op_val> ACCESS
%type  <op_val> var 
%type  <op_val> term 
%type  <op_val> function_ident
%type  <node>   functions
%type  <node>   function
%type  <node>   declarations
%type  <node>   declaration
%type  <node>   statements
%type  <node>   statement
%type  <node>   expression
%type  <node>   expressions
%type  <node>   array_expression
%type  <node>   multiplicative_expr
%type  <node>   math
%type  <node>   math_return
%type  <node>   array_math
%type  <node>   params
%type  <node>   param
%type  <node>   params_not_math
%type  <node>   array_declaration
%type  <node>   accessing_array
%start prog_start
%locations

%%


prog_start: functions 
{
  CodeNode* node = $1;
  // printf("Generated code:\n");
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

  node->code += std::string("endfunc\n\n");
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
| var ACCESS_ARRAY NUMBER ASSIGNMENT NUMBER PERIOD 
{
  std::string dest = $1;
  std::string index = $3;
  std::string val = $5;
  //CodeNode* exp = $5;
  CodeNode *node = new CodeNode;
  //std::string temp = create_temp();
  //std::string temp_decl = decl_temp_code(temp);
  // printf("%s\n", expr->code.c_str());
  //node->code = temp_decl + std::string("\n= ") + temp + std::string(", ") + exp->code + std::string("\n") + std::string("[]= ") + dest + std::string(", ") + index + std::string(", ") + temp + std::string("\n");
  //node->name = temp;
  node->code = std::string("[]= ") + dest + std::string(", ") + index + std::string(", ") + val + std::string("\n");
  $$ = node;
}
/*| var ACCESS_ARRAY NUMBER ASSIGNMENT math PERIOD
{ 
  std::string dest = $1;
  std::string index = $3;
  CodeNode* mat = $5;
  CodeNode* node = new CodeNode;
  //node->code = mat->code.substr(0, 2) + dest + mat->code.substr(2,mat->code.length()) + std::string("\n");
  node->code = mat->code + std::string("[]= ") + dest + std::string(", ") + index + std::string(", ") + mat->name + std::string("\n");
  node->name = mat->name;
  $$ = node;
}*/
| accessing_array ASSIGNMENT array_math PERIOD
{ 
  std::string dest = $1;
  CodeNode* mat = $3;
  CodeNode* node = new CodeNode;
  node->code = mat->code + std::string("[]= ") + dest + std::string(", ") + index + std::string(", ") + mat->name + std::string("\n");
  node->name = mat->name;
  $$ = node;
}
| var ASSIGNMENT expression PERIOD
{
  std::string dest = $1;
  CodeNode* expr = $3;
  CodeNode* node = new CodeNode;
  node->code = std::string("= ") + dest + std::string(", ") + expr->code + std::string("\n");
  $$ = node;
}
| var ASSIGNMENT math PERIOD
{
  std::string dest = $1;
  CodeNode* mat = $3;
  CodeNode* node = new CodeNode;
  node->code = mat->code + std::string("= ") + dest + std::string(", ") + mat->name + std::string("\n");
  $$ = node;
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
| PRINT var ACCESS_ARRAY NUMBER PERIOD 
{
  std::string temp = create_temp();
  std::string temp_decl = decl_temp_code(temp);
  std::string arr = $2;
  std::string index = $4;
  CodeNode *node = new CodeNode;
  std::string var = $2;
  node->code = temp_decl + std::string("\n") + std::string("=[] ") + temp + std::string(", ") + arr + std::string(", ") + index + std::string("\n") + std::string(".> ") + temp + std::string("\n");
  node->name = temp;
  $$ = node;
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
  CodeNode* exp = $2;
  CodeNode* node = new CodeNode;
  node->code = exp->code + std::string("ret ") + exp->name + std::string("\n");
  $$ = node;
}
| RETURN math_return PERIOD
{
  CodeNode* mat = $2;
  CodeNode* node = new CodeNode;
  node->code = mat->code + std::string("ret ") + mat->name + std::string("\n");
  $$ = node; 
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
| var ASSIGNMENT FUNC_EXEC function_ident BEGIN_PARAMS params END_PARAMS PERIOD
{
  std::string id = $1;
  std::string func_name = $4;
  CodeNode* node2 = $6;
  CodeNode* node = new CodeNode;
  std::string test = node2->name;
  if(node2->name.substr(0, 5) == "_temp") {
    node->code = node2->code + std::string("call ") + func_name + std::string(", ") + node2->name + std::string("\n") + std::string("= ") + id + std::string(", ") + node2->name + std::string("\n");
  }
  else {
    node->code = node2->code + std::string("call ") + func_name + std::string(", ") + node2->name + std::string("\n") + std::string("= ") + id + std::string(", ") + node2->name + std::string("\n");
  
  }
  $$ = node;
}
;

array_math: math
{
  $$ = $1;
}
/*| var ACCESS_ARRAY NUMBER ASSIGNMENT var ACCESS_ARRAY NUMBER 
  MULTIPLICATION LEFT_PAREN var ACCESS_ARRAY NUMBER ADDITION var RIGHT_PAREN
{
  std::string var1 = $1;
  std::string var2 = $14;
  std::string index1 = $3;
  std::string index2 = $7;
  std::string index3 = $12;
  std::string temp1 = create_temp();
  std::string temp2 = create_temp();
  std::string temp3 = create_temp();
  std::string temp4 = create_temp();
  std::string temp_decl1 = decl_temp_code(temp1);
  std::string temp_decl2 = decl_temp_code(temp2);
  std::string temp_decl3 = decl_temp_code(temp3);
  std::string temp_decl4 = decl_temp_code(temp4);
  CodeNode* node = new CodeNode;
  node->code = temp_decl1 + std::string("\n") + std::string("=[] ") + temp1 + 
  std::string(", ") + var1 + std::string(", ") + index1 + std::string("\n") +
  temp_decl2 + std::string("\n") + std::string("=[] ") + temp2 + std::string(", ") +
  var1 + std::string(", ") + index2 + std::string("\n") + temp_decl3 + std::string("\n")
  + std::string("+ ") + temp3 + std::string(", ") + temp2 + std::string(", ") + var2 +
  std::string("\n") + temp_decl4 + std::string("\n") + std::string("* ") + temp4 + 
  std::string(", ") + temp1 + std::string(", ") + temp3 + std::string("\n");
  node->name = temp4;
  $$ = node;
}*/
| array_expression MULTIPLICATION LEFT_PAREN array_expression RIGHT_PAREN
{
  std::string temp = create_temp();
  std::string temp_decl = decl_temp_code(temp);
  CodeNode* val1 = $1;
  CodeNode* val2 = $4;
  CodeNode* node = new CodeNode;
  node->code = val2->code + temp_decl + std::string("\n") + std::string("* ") + temp + std::string(", ") + val1->name 
  + std::string(", ") + val2->name + std::string("\n");
  node->name = temp;
  $$ = node;
}
| array_expression ADDITION array_expression
{
  std::string temp = create_temp();
  std::string temp_decl = decl_temp_code(temp);
  CodeNode* val1 = $1;
  CodeNode* val2 = $3;
  CodeNode* node = new CodeNode;
  node->code = temp_decl + std::string("\n") + std::string("+ ") + temp + std::string(", ") + val1->name 
  + std::string(", ") + val2->name + std::string("\n");
  node->name = temp;
  $$ = node;
}
;

array_expression: math 
{
  $$ = $1;
}
| accessing_array
{
  $$ = $1;
}
/*| LEFT_PAREN array_math RIGHT_PAREN
{
  $$ = $2;
}*/
| var {
  $$ = $1;
}
| NUMBER
{
  $$ = $1;
}
;

accessing_array: var ACCESS_ARRAY NUMBER
{
  std::string arr = $1;
  std::string index = $3;
  std::string temp = create_temp();
  std::string temp_decl = decl_temp_code(temp);
  CodeNode* node = new CodeNode;
  node->code = temp_decl + std::string("\n") + std::string("=[] ") + temp + 
  std::string(", ") + arr + std::string(", ") + index + std::string("\n");
  node->name = temp;
  $$ = node;
}

params: param
{
  CodeNode* code_node = $1;
  CodeNode* node = new CodeNode;
  node->code = code_node->code;
  node->name = code_node->name;
  $$ = node;
}
| param COMMA math
{
  std::string temp = create_temp();
  std::string name_decl = decl_temp_code(temp);
  CodeNode* code_node1 = $1;
  CodeNode* code_node2 = $3;
  CodeNode* node = new CodeNode;
  node->code = std::string("param ") + code_node1->code + std::string("\n") + code_node2->code + std::string("param ") + code_node2->name + std::string("\n") + name_decl + std::string("\n");
  node->name = temp;
  $$ = node;
}
| param COMMA params_not_math
{
  std::string temp = create_temp();
  std::string name_decl = decl_temp_code(temp);
  CodeNode* code_node1 = $1;
  CodeNode* code_node2 = $3;
  CodeNode* node = new CodeNode;
  node->code = std::string("param ") + code_node1->code + std::string("\n") + std::string("param ") + code_node2->name + std::string("\n") + name_decl + std::string("\n");
  node->name = temp;
  $$ = node;
}
;

math_return: multiplicative_expr ADDITION multiplicative_expr
{
        std::string temp = create_temp();
        std::string decl_temp = decl_temp_code(temp);
        CodeNode* term1 = $1;
        CodeNode* term2 = $3;
        CodeNode *node = new CodeNode;
        node->code = std::string("= ") + term1->code + std::string(", $0") +  std::string("\n") + std::string("= ") + term2->code + std::string(", $1") + std::string("\n") + decl_temp + std::string("\n") + std::string("+ ") + temp + std::string(", ") + term1->code + std::string(", ") + term2->code + std::string("\n");
        node->name = temp;
        $$ = node;
}
| multiplicative_expr SUBTRACTION multiplicative_expr
{
        std::string temp = create_temp();
        std::string decl_temp = decl_temp_code(temp);
        CodeNode* term1 = $1;
        CodeNode* term2 = $3;
        CodeNode *node = new CodeNode;
        node->code = std::string("= ") + term1->code + std::string(", $0") + std::string("\n") + std::string("= ") + term2->code + std::string(", $1") + std::string("\n") + decl_temp + decl_temp +std::string("\n") + std::string("- ") + temp + std::string(", ") + term1->code + std::string(", ") + term2->code + std::string("\n");
        node->name = temp;
        $$ = node;
}
| multiplicative_expr DIVISION multiplicative_expr
{
        std::string temp = create_temp();
        std::string decl_temp = decl_temp_code(temp);
        CodeNode* term1 = $1;
        CodeNode* term2 = $3;
        CodeNode *node = new CodeNode;
        node->code = std::string("= ") + term1->code + std::string(", $0") + std::string("\n") + std::string("= ") + term2->code + std::string(", $1") + std::string("\n") + decl_temp + decl_temp +std::string("\n") + std::string("/ ") + temp + std::string(", ") + term1->code + std::string(", ") + term2->code + std::string("\n");
        node->name = temp;
        $$ = node;
}
| multiplicative_expr MOD multiplicative_expr
{
        std::string temp = create_temp();
        std::string decl_temp = decl_temp_code(temp);
        CodeNode* term1 = $1;
        CodeNode* term2 = $3;
        CodeNode *node = new CodeNode;
        node->code = std::string("= ") + term1->code + std::string(", $0") + std::string("\n") + std::string("= ") + term2->code + std::string(", $1") + std::string("\n") + decl_temp + std::string("\n") + std::string("* ") + temp + std::string(", ") + term1->code + std::string(", ") + term2->code + std::string("\n");
        node->name = temp;
        $$ = node;
}
;

params_not_math: expression
{
  $$ = $1;
}

param: expression
{
  $$ = $1;
}
| math
{
  CodeNode* node1 = $1;
  CodeNode* node = new CodeNode;
  node->name = node1->name;
  node->code = node1->code;
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
| declaration
{  
  CodeNode* code_node1 = $1;
  CodeNode* node = new CodeNode;
  node->code = code_node1->code;
  $$ = node;
}
;
declaration: IDENTIFIER array_declaration INTEGER 
{
  CodeNode *code_node1 = $2;
  CodeNode *code_node = new CodeNode;
  std::string id = $1;
  code_node->code = std::string(".") + code_node1->code + id + std::string(", ") + code_node1->name + std::string("\n");
  code_node->name = id;
  code_node->is_array = true;
  $$ = code_node;
  std::string error = std::string("Symbol \"") + id + std::string("\" is multiply-defined.");
  std::string value = $1;
  if(find(id)) {
	yyerror(error.c_str());
  }
  Type t = Array;
  add_variable_to_symbol_table(value, t);
}
| IDENTIFIER INTEGER
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

array_declaration: ARRAY NUMBER 
{
  // Code for array declaration with a size//
  CodeNode *code_node = new CodeNode;
  code_node->code = std::string("[] ");
  code_node->name = $2;
  $$ = code_node;
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

math: multiplicative_expr ADDITION multiplicative_expr
{
	std::string temp = create_temp();
	std::string decl_temp = decl_temp_code(temp);
	CodeNode* term1 = $1;
	CodeNode* term2 = $3;
	std::string bad_var = "";
	std::string error = "";
	if (!find(term1->code)) {
		bad_var = term1->code;
		error = std::string("used variable \"") + bad_var + std::string("\" was not previously declared.");
		yyerror(error.c_str());
	}
	else if (!find(term2->code)) {
		bad_var = term2->code;
		error = std::string("used variable \"") + bad_var + std::string("\" was not previously declared.");
		yyerror(error.c_str());
	}
	/*if (find(term1->code) && get_type(term1->code) == "Array") {
		bad_var = term1->code;
		error = std::string("used array variable \"") + bad_var + std::string("\" is missing a specified index.");
		yyerror(error.c_str());
	}
	else if (find(term2->code) && get_type(term2->code) == "Array") {
		printf("HELL0");
		bad_var = term2->code;	
		error = std::string("used array variable \"") + bad_var + std::string("\" is missing a specified index.");
                yyerror(error.c_str());
	} */
	CodeNode *node = new CodeNode;
	node->code = decl_temp + std::string("\n") + std::string("+ ") + temp + std::string(", ") + term1->code + std::string(", ") + term2->code + std::string("\n");
	node->name = temp;
	$$ = node;
}
| multiplicative_expr SUBTRACTION multiplicative_expr
{
        std::string temp = create_temp();
        std::string decl_temp = decl_temp_code(temp);
        CodeNode* term1 = $1;
        CodeNode* term2 = $3;

        CodeNode *node = new CodeNode;
        node->code = decl_temp + std::string("- ") + temp + std::string(", ") + term1->code + std::string(", ") + term2->code + std::string("\n");
        node->name = temp;
        $$ = node;
}
| multiplicative_expr DIVISION multiplicative_expr
{
        std::string temp = create_temp();
        std::string decl_temp = decl_temp_code(temp);
        CodeNode* term1 = $1;
        CodeNode* term2 = $3;

        CodeNode *node = new CodeNode;
        node->code = decl_temp + std::string("/ ") + temp + std::string(", ") + term1->code + std::string(", ") + term2->code + std::string("\n");
        node->name = temp;
        $$ = node;
}
| multiplicative_expr MULTIPLICATION multiplicative_expr
{
        std::string temp = create_temp();
        std::string decl_temp = decl_temp_code(temp);
        CodeNode* term1 = $1;
        CodeNode* term2 = $3;

        CodeNode *node = new CodeNode;
        node->code = decl_temp + std::string("* ") + temp + std::string(", ") + term1->code + std::string(", ") + term2->code + std::string("\n");
        node->name = temp;
        $$ = node;
} 
| multiplicative_expr MOD multiplicative_expr
{
        std::string temp = create_temp();
        std::string decl_temp = decl_temp_code(temp);
        CodeNode* term1 = $1;
        CodeNode* term2 = $3;

        CodeNode *node = new CodeNode;
        node->code = decl_temp + std::string("% ") + temp + std::string(", ") + term1->code + std::string(", ") + term2->code + std::string("\n");
        node->name = temp;
        $$ = node;
}
;

expression: multiplicative_expr 
{
  $$ = $1;
  // printf("%s\n", $1->code.c_str());
}
;

multiplicative_expr: term 
{
  CodeNode * node = new CodeNode;
  node->code = $1;
  node->name = $1;
  // printf("%s\n", node->code.c_str());
  $$ = node;
}
;

term: var 
{
  $$ = $1;
}
| NUMBER 
{
  $$ = $1;
}
| LEFT_PAREN expressions END_PARAMS 
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
%%


int main(int argc, char **argv) {
	/*yyin = stdin;
	
	do {
	  printf("Ctrl + D to quit\n");
	  yyparse();
	} while(!feof(yyin));
	return 0;*/
	yyparse();
  print_symbol_table();
   	return 0;
}
