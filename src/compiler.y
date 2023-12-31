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
bool error_free = true;
bool in_loop = false;

enum Type { Integer, Array, If, Else, End_If, Begin_Loop, Body_Loop, End_Loop };

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

bool find_func(std::string &value) {
   for (int i = 0; i < symbol_table.size(); i++) {
	if (symbol_table[i].name == value) {
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
    bool arr;
    std::string code; // generated code as a string.
    std::string name;
    std::string size;
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

static int if_n = 0;
static int else_n = 0;
static int end = 0;
static int beg_loop = 0;
static int body_loop = 0;
static int end_loop = 0;

std::string create_label(Type t) {
  std::string value = "";

  if (t == If) {
    value = std::string("if_true") + std::to_string(if_n);
    ++if_n;
  }
  else if (t == Else) {
    value = std::string("else") + std::to_string(else_n);
    ++else_n;
  }
  else if (t == End_If) {
    value = std::string("endif") + std::to_string(end);
    ++end;
  }
  else if (t == Begin_Loop) {
    value = std::string("beginloop") + std::to_string(beg_loop);
    ++beg_loop;
  }
  else if (t == Body_Loop) {
    value = std::string("loopbody") + std::to_string(body_loop);
    ++body_loop;
  }
  else if (t == End_Loop) {
    value = std::string("endloop") + std::to_string(end_loop);
    ++end_loop;
  }
  return value;
}

std::string jump_label(std::string &label) {
  return std::string(":= ") + label; 
}

std::string decl_label(std::string &temp) {
  return std::string(": ") + temp;
}

    /*Phase 3 end*/
%}


%union {
  struct CodeNode *node;
  char *op_val;
  int int_val;
}

%define parse.error verbose
%token INTEGER ARRAY ACCESS_ARRAY ASSIGNMENT PERIOD LESS GREATER GREATER_OR_EQUAL LESSER_OR_EQUAL EQUAL DIFFERENT WHILE IF THEN ELSE PRINT READ FUNC_EXEC FUNCTION BEGIN_PARAMS END_PARAMS NOT AND OR TAB SEMICOLON LEFT_PAREN RIGHT_PAREN RETURN COMMA QUOTE LEFT_CBRACKET RIGHT_CBRACKET
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
%type  <node>   bool_exp
%token  <node>   CONTINUE
%token  <node>   BREAK
%type  <node>   comp
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
  if (error_free) {
  	printf("%s\n", node->code.c_str());
  }
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
  if (!find_func(func_name)) {
  	add_function_to_symbol_table(func_name);
  }
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
  CodeNode *node = new CodeNode;
  // printf("%s\n", expr->code.c_str());
  node->code = std::string("[]= ") + dest + std::string(", ") + index + std::string(", ") + val + std::string("\n");
  $$ = node;
}
| var ACCESS_ARRAY NUMBER ASSIGNMENT array_math PERIOD
{
  std::string dest = $1;
  std::string index = $3;
  CodeNode* mat = $5;
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
  if(!find(dest)) {
    Type t = Integer;
    add_variable_to_symbol_table(dest, t);
  }
  node->arr = false;
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
/*| ELSE SEMICOLON statements 
{
}*/
| IF bool_exp LEFT_PAREN statements RIGHT_PAREN tabs ELSE LEFT_PAREN statements RIGHT_PAREN
{
  CodeNode* condition = $2;
  CodeNode* body1 = $4;
  CodeNode* body2 = $9;
  std::string temp_if = create_label(If);
  std::string temp_else = create_label(Else);
  std::string temp_endif = create_label(End_If);
  std::string if_decl = decl_label(temp_if);
  std::string else_decl = decl_label(temp_else);
  std::string end_decl = decl_label(temp_endif);
  CodeNode* node = new CodeNode;
  node->code = condition->code + std::string("?") +
  jump_label(temp_if) + std::string(", ") + condition->name + std::string("\n")
  + jump_label(temp_else) + std::string("\n") + if_decl + std::string("\n")
  + body1->code + jump_label(temp_endif) + std::string("\n") + 
  else_decl + std::string("\n") + body2->code + end_decl + std::string("\n");
  $$ = node;
}
| WHILE bool_exp LEFT_PAREN statements RIGHT_PAREN
{
  CodeNode* condition = $2;
  CodeNode* body = $4;
  std::string temp_begin = create_label(Begin_Loop);
  std::string temp_body = create_label(Body_Loop);
  std::string temp_end = create_label(End_Loop);
  std::string begin_decl = decl_label(temp_begin);
  std::string body_decl = decl_label(temp_body);
  std::string end_decl = decl_label(temp_end);
  CodeNode* node = new CodeNode;
  node->code = 
  // create begin loop label
    begin_decl + std::string("\n") +
  // check condition for true case and jump
    condition->code + 
    std::string("?") + jump_label(temp_body) + std::string(", ") + condition->name + std::string("\n") +
  // unconditional jump to end of the loop
    jump_label(temp_end) + std::string("\n") +
  // create label for loopbody
    body_decl + std::string("\n") +
  // loop body code
    body->code +
  // jump to the beginning of the loop
    jump_label(temp_begin) + std::string("\n") +
  // declare endloop
    end_decl + std::string("\n");
  $$ = node;
}
| PRINT var ACCESS_ARRAY NUMBER PERIOD 
{
  std::string temp = create_temp();
  std::string temp_decl = decl_temp_code(temp);
  std::string arra = $2;
  std::string index = $4;
  CodeNode *node = new CodeNode;
  std::string var = $2;
  node->code = temp_decl + std::string("\n") + std::string("=[] ") + temp + std::string(", ") + arra + std::string(", ") + index + std::string("\n") + std::string(".> ") + temp + std::string("\n");
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
  CodeNode * node = new CodeNode;
  std::string code_label = std::string("endloop") + std::to_string(end_loop) + std::string("\n");
  node->code = jump_label(code_label);
  $$ = node;

}
| CONTINUE PERIOD 
{
  CodeNode * node = new CodeNode;
  node->code = "";
  if(!in_loop) {
    std::string error = "continue statement not within a loop.";
    yyerror(error.c_str());
    error_free = false;
  }
  $$ = node;
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

 

array_math: array_expression MULTIPLICATION LEFT_PAREN array_math RIGHT_PAREN
{
  std::string temp = create_temp();
  std::string temp_decl = decl_temp_code(temp);
  CodeNode* val1 = $1;
  CodeNode* val2 = $4;
  CodeNode* node = new CodeNode;
  node->code =val1->code + val2->code + temp_decl + std::string("\n") + std::string("* ") + temp + std::string(", ") + val1->name 
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
  std::string check_var = val1->code;
  CodeNode* node = new CodeNode;
  if(find(val1->name)) {
    check_var = "";
  }
  node->code = check_var + temp_decl + std::string("\n") + std::string("+ ") + temp + std::string(", ") + val1->name 
  + std::string(", ") + val2->name + std::string("\n");
  node->name = temp;
  $$ = node;
}
;

array_expression: accessing_array
{
  $$ = $1;
}
| var {
  CodeNode* node = new CodeNode;
  node->code = $1;
  node->name = $1;
  $$ = node;
}
| NUMBER
{
  CodeNode* node = new CodeNode;
  node->code = $1;
  node->name = $1;
  $$ = node;
}
;

accessing_array: var ACCESS_ARRAY NUMBER
{
  std::string arra = $1;
  std::string index = $3;
  std::string temp = create_temp();
  std::string temp_decl = decl_temp_code(temp);
  CodeNode* node = new CodeNode;
  node->code = temp_decl + std::string("\n") + std::string("=[] ") + temp + 
  std::string(", ") + arra + std::string(", ") + index + std::string("\n");
  node->name = temp;
  $$ = node;
}
;

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
  // std::string error = std::string("used variable \"") + term1->name +("\" was not previously declared.") + std::string("\n");
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
| multiplicative_expr MULTIPLICATION multiplicative_expr
{
  std::string temp = create_temp();
  std::string decl_temp = decl_temp_code(temp);
  CodeNode* term1 = $1;
  CodeNode* term2 = $3;
  CodeNode *node = new CodeNode;
  node->code = std::string("= ") + term1->code + std::string(", $0") + std::string("\n") + std::string("= ") + term2->code + std::string(", $1") + std::string("\n") + decl_temp +std::string("\n") + std::string("* ") + temp + std::string(", ") + term1->code + std::string(", ") + term2->code + std::string("\n");
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
  CodeNode* val1 = $2;
  CodeNode* val2 = $4;
  CodeNode* comp = $3;
  std::string temp = create_temp();
  CodeNode* node = new CodeNode;
  node->code = decl_temp_code(temp) + std::string("\n") + 
  comp->code + temp + std::string(", ") + val1->code + std::string(", ")
   + val2->code + std::string("\n");
  node->name = temp;
  $$ = node;
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
  code_node->code = std::string(".") + code_node1->code + id + std::string(", ") + code_node1->size + std::string("\n");
  code_node->name = id;
  std::string error = std::string("Symbol \"") + id + std::string("\" is multiply-defined.");
  std::string value = $1;
  if(find(id)) {
	yyerror(error.c_str());
	error_free = false;
  }
  else {
    Type t = Array;
    add_variable_to_symbol_table(id, t);
    code_node->arr = true;
  }
  // code_node->arr = true;
  $$ = code_node;
}
| IDENTIFIER INTEGER
{
  CodeNode *node = new CodeNode;
  std::string id = $1;
  node->code = std::string(". ") + id + std::string("\n");
  node->name = id;
  Type t = Integer;
  add_variable_to_symbol_table(id, t);
  $$ = node;
}
;

array_declaration: ARRAY NUMBER 
{
  // Code for array declaration with a size//
  CodeNode *node = new CodeNode;
  node->code = std::string("[] ");
  node->arr = true;
  node->size = $2;
  $$ = node;
}
;

comp: LESS 
{
  CodeNode* node = new CodeNode;
  node->code = std::string("< ");
  $$ = node;
}
| GREATER 
{
  CodeNode* node = new CodeNode;
  node->code = std::string("> ");
  $$ = node;
}
| GREATER_OR_EQUAL 
{
  CodeNode* node = new CodeNode;
  node->code = std::string(">= ");
  $$ = node;
}
| LESSER_OR_EQUAL 
{
  CodeNode* node = new CodeNode;
  node->code = std::string("<= ");
  $$ = node;
}
| EQUAL 
{
  CodeNode* node = new CodeNode;
  node->code = std::string("== ");
  $$ = node;
}
;

math: multiplicative_expr ADDITION multiplicative_expr
{
  std::string temp = create_temp();
  std::string decl_temp = decl_temp_code(temp);
  CodeNode* term1 = $1;
  CodeNode* term2 = $3;
  std::string error;
  CodeNode *node = new CodeNode;
  if (!find(term1->name)) {
    error = std::string("used variable \"") + term1->name +("\" was not previously declared.");
    yyerror(error.c_str());
    error_free = false;
  }
  if (term2->arr == true && find(term2->name)) {
    error = std::string("used array variable ") + term2->name + (" is missing a specified index.");
    yyerror(error.c_str());
    error_free = false;
  }
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
        node->code = decl_temp + std::string("\n") + std::string("- ") + temp + std::string(", ") + term1->code + std::string(", ") + term2->code + std::string("\n");
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
  node->code = decl_temp + std::string("\n") + std::string("/ ") + temp + std::string(", ") + term1->code + std::string(", ") + term2->code + std::string("\n");
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
  node->code = decl_temp + std::string("\n") + std::string("* ") + temp + std::string(", ") + term1->code + std::string(", ") + term2->code + std::string("\n");
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
  node->code = decl_temp + std::string("\n") + std::string("% ") + temp + std::string(", ") + term1->code + std::string(", ") + term2->code + std::string("\n");
  node->name = temp;
  $$ = node;
}
| LEFT_PAREN math RIGHT_PAREN MULTIPLICATION NUMBER
{
  CodeNode* term1 = $2;
  std::string term2 = $5;
  std::string temp = create_temp();
  std::string decl_temp = decl_temp_code(temp);
  CodeNode* node = new CodeNode;
  node->code = term1->code + decl_temp + std::string("\n") + std::string("* ") + 
  temp + std::string(", ") + term1->name + std::string(", ") + term2 + std::string("\n");
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
  CodeNode* node = new CodeNode;
  node->code = $1;
  node->arr = false;
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
	if (error_free) {
  	  print_symbol_table();
	}
   	return 0;
}
