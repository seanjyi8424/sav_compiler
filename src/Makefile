all: parser
y.tab.c y.tab.h: compiler.y
	bison -t -v -d --file-prefix=y compiler.y
lex.yy.c: lexer.lex y.tab.h
	flex lexer.lex
parser: lex.yy.c y.tab.c y.tab.h
	g++ -o parser y.tab.c lex.yy.c -lfl
clean:
	rm parser y.tab.c lex.yy.c y.tab.h y.output
