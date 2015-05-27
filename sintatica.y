%{
#include <iostream>
#include <string>
#include <sstream>
#include <stdlib.h>

#define YYSTYPE atributos

int num_tmp = 0;
std:: string temp;

using namespace std;

struct atributos 
{
	string label;
	string traducao;
	string temp;
};


int yylex(void);
void yyerror(string);
string getTemp(void);
%}

%token TK_NUM TK_SOMA TK_SUB TK_IGUAL
%token TK_MAIN TK_ID TK_TIPO_INT
%token TK_FIM TK_ERROR

%start S

%left '+'

%%

S 			: TK_TIPO_INT TK_MAIN '(' ')' BLOCO
			{
				cout << "/*Compilador FOCA*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << $5.traducao << "\treturn 0;\n}" << endl; 
			}
			;

BLOCO		: '{' COMANDOS '}'
			{
				$$.traducao = $2.traducao;
			}
			;

COMANDOS	: COMANDO COMANDOS
			{
				$$.traducao = $1.traducao + $2.traducao;
			}
			|COMANDO 
			{

				$$.traducao = $1.traducao;
			}
			;

COMANDO 	: E ';'
			;

E 			: TK_ID TK_IGUAL E TK_SOMA E
			{
				$$.traducao = $1.label + $3.traducao + $5.traducao + "\t" + $1.temp + " = " + $3.temp + " + " + $5.temp + "\n"; 
			}
			| E TK_SOMA E
			{

				$$.temp = getTemp();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.temp + " = " + $1.temp + " + " + $3.temp + ";\n";
				
			}
			| E TK_SUB E
			{

				$$.temp = getTemp();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.temp + " = " + $1.temp + " - " + $3.temp + ";\n";
				
			}
			|TIPO E
			{
				$$.traducao = "\t" + $1.traducao + $2.traducao;
			}
			| TK_NUM
			{
				$$.temp = getTemp();
				$$.traducao = "\t" + $$.temp + " = " + $1.traducao + ";\n";
			}
			| TK_ID
			{
				$$.temp = getTemp();
			}
			;

TIPO		: TK_TIPO_INT
			{
				$$.traducao = "int ";
			}
			;		
			
%%

#include "lex.yy.c"

int yyparse();

int main( int argc, char* argv[] )
{
	yyparse();

	return 0;
}

void yyerror( string MSG )
{
	cout << MSG << endl;
	exit (0);
}				

string getTemp(void)
{	 
	std::string result;
	std::stringstream sstm;
	sstm << "temp" << num_tmp;
	result = sstm.str();
	num_tmp++;
	return result;
}