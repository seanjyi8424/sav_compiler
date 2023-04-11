# NAME: SAVVY
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
| is a number | INTEGER |
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
| greater than or equal to | GREATER_OR_EQUAL |
| less than or equal to | LESSER_OR_EQUAL | 
| equals | EQUAL | 
| does not equal | DIFFERENT | 
| do this until | WHILE |
| do this if | IF |
| if not do this | THEN |
| otherwise do this | ELSE |
| show me | PRINT |
| give me | READ |
| i'm thinking that | COMMENT |
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


