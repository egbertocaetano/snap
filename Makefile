all: 	
		clear
		lex parser_lexicon.l
		yacc -d sintatica.y
		g++ -o glf y.tab.c -lfl

		./glf < Text.snap
