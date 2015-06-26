all: 	
		clear
		lex lexica.l
		yacc -dv sintatica.y
		g++ -o snp y.tab.c -lfl

		./snp < exemplo.snap
