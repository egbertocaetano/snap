all: 	
		clear
		flex parser_lexicon.l
		gcc -o lexicon lex.yy.c -lfl
		./lexicon < Text.txt
