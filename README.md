# NAME: SAVVY
Final Project for Compiler Design.
## EXTENSION: .sav

## COMPILER NAME: Savvy Compiler Coalition 

A valid identifier:
- Is wrapped in double quotes 
- Contains only letters, digits, and spaces
- Is not case sensitive 

Features:
- Everything lowercase 
- Can't declare and assign in the same line
- Whitespaces are not ignored and are used for blocking, etc.

| **Language Feature**  | **Code Example** |
| --------------------- | ---------------- |
| Integer Scalar Variables  | \"x\" is a number. <br />\"y\" is a number.  |
| One-dimensional arrays of integers  | \"x\" has 10 numbers. <br />\"list\" has 64 numbers.  |
| Assignment Statements | \"x\" is 1 plus 1. (+) <br />\"y\" is 5 minus 3. (-) <br />\"z\" is 6 divided by 3. (/) <br />\"a\" is 9 times 4. (\*) <br />\"b\" is 5 modulo 1. (%) |
| Relational Operators | 5 is less than 2. (<) <br />8 is greater than 4. (>) <br />6 is greater than or equal to 5. (>=) <br />7 is less than or equal to 8. (<=) <br />6 equals 6. (==) <br />9 does not equal 4. (!=) |
| While loop | do this until (condition) |
| If-then-else | do this if (condition) <br />if not do this (condition) <br />otherwise do this |
| Read and write statements | show me \"x\". <br />give me \"y\". |
| Comments | I'm thinking that \[comment\] |
| Functions | use \[function_name\] with \[args\] ok <br />create tool \[function_name\] with \[args\] ok | 

| **Symbol In Language** | **Token Name** |
| ---------------------- | -------------- |
| 42, 64, etc. | NUMBER |
| "a", "b", etc. | IDENTIFIER |
| is a number \| numbers | INTEGER |
| has | ARRAY |
| at | ACCESS_ARRAY | 
| is | ASSIGNMENT |
| . | PERIOD |
| plus | ADDITION |
| minus | SUBTRACTION | 
| divided by | DIVISION |
| times | MULTIPLICATION |
| modulo | MOD |
| is less than | LESS |
| is greater than | GREATER |
| is greater than or equal to | GREATER_OR_EQUAL |
| is less than or equal to | LESSER_OR_EQUAL | 
| equals | EQUAL | 
| does not equal | DIFFERENT | 
| do this until | WHILE |
| do this if | IF |
| otherwise do this | ELSE |
| show me | PRINT |
| give me | READ |
| use | FUNC_EXEC |
| create tool | FUNCTION |
| with | BEGIN_PARAMS |
| ok | END_PARAMS |
| not | NOT |
| and | AND |
| or | OR |
| \tab | TAB |
| ; | SEMICOLON | 
| ( | LEFT_PAREN |
| ) | RIGHT_PAREN | 
| give back | RETURN |
| , | COMMA | 
| leave | BREAK | 
| \" | QUOTE |

### Usage
1. Make sure to have both flex and bison installed
2. Go to source directory (src/) and execute the Makefile
3. ./parser < path/to/your_file.sav

### Output Screenshots
#### array.sav
<img width="494" alt="array" src="https://github.com/seanjyi8424/sav_compiler-UCR/assets/108261874/7383242f-75a9-45e7-bef9-c2e8521625b8">

#### mil_tests/add.sav
<img width="546" alt="mil_test_add" src="https://github.com/seanjyi8424/sav_compiler-UCR/assets/108261874/632f437e-d719-4955-a3bb-d2260d88b876">

#### mil_tests/nested_loop.sav
<img width="601" alt="mil_test_nested_loop" src="https://github.com/seanjyi8424/sav_compiler-UCR/assets/108261874/25147185-3146-414d-b01b-1c9d2aaf52b8">

#### bison_tests/test.txt
<img width="561" alt="bison_test" src="https://github.com/seanjyi8424/sav_compiler-UCR/assets/108261874/0de417d5-ef22-4539-8f0b-991ad901177a">

#### bison_tests/function_id_error.txt
<img width="704" alt="function_id_error" src="https://github.com/seanjyi8424/sav_compiler-UCR/assets/108261874/785fc5c0-ca77-4404-a23d-1b8831c4c0e9">
