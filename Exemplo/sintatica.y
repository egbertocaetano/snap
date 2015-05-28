%{
#include <iostream>
#include <string>
#include <sstream>
#include <map>

#define YYSTYPE atributos

using namespace std;

struct atributos
{
	string label;
	string traducao;
	string tmp;
	string valor;
};

struct ID
{
	string tipo;
	string label;
	string valor;
	string temp;
};

map <string , ID> tabID;



int yylex(void);
void yyerror(string);
string geraTemp(void);
int existeID(string label);
//string verificaInicializacao(string label);
%}

%token TK_NUM
%token TK_MAIN TK_ID TK_TIPO_INT
%token TK_FIM TK_ERROR

%start S

%left '+' '-'
%left '*' '/'
%nonassoc '='


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

COMANDOS	: COMANDO
			{
				$$.traducao = $1.traducao;
			}
			|COMANDO COMANDOS
			{

				$$.traducao = $1.traducao + $2.traducao;
			}
			;

COMANDO 	: DECLARACAO ';'
			| ATRIBUICAO ';'
			;

DECLARACAO	:TK_TIPO_INT TK_ID '=' TK_NUM
			{
				struct ID id;
				id.temp =  geraTemp();
				id.tipo = $1.traducao;
				id.label = $2.label;
				id.valor = $4.valor;
				$$.tmp = id.temp;
				$$.label = id.label;
				tabID[$$.label] = id;
				//$$.traducao = "\t" + $$.tmp + " = " + tabID[$$.label].valor + ";\n";
			} 
			|TK_TIPO_INT TK_ID
			{
				struct ID id;
				id.temp =  geraTemp();
				id.tipo = $1.traducao;
				id.label = $2.label;
				$$.tmp = id.temp;
				$$.label = id.label;
				tabID[$$.label] = id;
				//$$.traducao = "\t" + $$.tmp + " = " + tabID[$$.label].label + ";\n";
			}
			;
ATRIBUICAO	: TK_ID '=' E
			{
				
				$$.traducao = $1.traducao + $3.traducao + "\t" + tabID[$1.label].temp + " = " + $3.tmp + ";\n";
			} 
			;

E 			:'(' E ')'
			{
				$$.tmp = $2.tmp;
				$$.traducao = $2.traducao;
			} 
			|E '+' E
			{
				/*string v1 = verificaInicializacao($1.traducao);
				string v3 = verificaInicializacao($3.traducao);
				cout << v1 + " " + v3 << endl;*/
				$$.tmp = geraTemp();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.tmp + " = " + $1.tmp + "+" + $3.tmp + ";\n";
			}
			|E '-' E
			{
				$$.tmp = geraTemp();	
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.tmp + " = " + $1.tmp + "-" + $3.tmp + ";\n";
			}
			|E '*' E
			{
				$$.tmp = geraTemp();	
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.tmp + " = " + $1.tmp + "*" + $3.tmp + ";\n";
			}
			|E '/' E
			{
				$$.tmp = geraTemp();	
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.tmp + " = " + $1.tmp + "/" + $3.tmp + ";\n";
			}
			| TK_NUM
			{
				$$.tmp = geraTemp();
				$$.traducao = "\t" + $$.tmp + " = " + $1.valor + ";\n";
			}
			| TK_ID
			{
				if(existeID($1.label))
				{
					$$.tmp = tabID[$1.label].temp;
					$$.label = tabID[$$.label].label;
					//$$.traducao = "\t" + $$.tmp + " = " + tabID[$$.label].label + ";\n";
				}
				else
				{
					yyerror("Variavel '" + $1.label + "' nao declarada.");
					return 0;
				}
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

string geraTemp(void){
	
	static int i = 0;
	stringstream ss;
	ss << "temp" << i++;

	return ss.str();
}			

int existeID(string label)
{
	if(label == tabID[label].label)
		return 1;
	return 0;
}	

/*int verificaInicializacao(string label)
{
	if(label == tabID[label].label)
		return 1;
	
	return "";	
}*/