all: 	
		clear
		lex lexica.l
		yacc -d sintatica.y
		g++ -o glf y.tab.c -lfl

		./glf < exemplo7.snap > Test.c

		g++ Test.c -o t

		./t
