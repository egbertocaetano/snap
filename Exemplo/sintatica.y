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
	string tipo;
	string operadorLogico;
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

%token TK_NUM TK_REAL TK_VALOR_LOGICO TK_CHAR
%token TK_MAIN TK_ID
%token TK_FIM TK_ERROR
%token TK_OPERADOR_LOGICO TK_OPERADOR_RELACIONAL
%token TK_TIPO_INT TK_TIPO_CHAR TK_TIPO_FLOAT TK_TIPO_STRING TK_TIPO_BOOLEAN

%start S

%left '+' '-'
%left '*' '/'
%nonassoc '='


%%

S 			: TK_TIPO_INT TK_MAIN '(' ')' BLOCO
			{
				cout << "/*Compilador FOCA*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\n" + $1.tipo + " main(void)\n{\n" << $5.traducao << "\treturn 0;\n}" << endl; 
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

DECLARACAO	:TIPO TK_ID '=' VALOR
			{
				struct ID id;
				id.temp =  geraTemp();
				id.tipo = $1.tipo;
				id.label = $2.label;
				id.valor = $4.valor;
				$$.tmp = id.temp;
				$$.label = id.label;
				tabID[$$.label] = id;
				$$.traducao = "\t" + tabID[$$.label].tipo + " " + $$.tmp + " = " + tabID[$$.label].valor + ";\n";
			} 
			|TIPO TK_ID
			{
				struct ID id;
				id.temp =  geraTemp();
				id.tipo = $1.tipo;
				id.label = $2.label;
				$$.tmp = id.temp;
				$$.label = id.label;
				tabID[$$.label] = id;
				$$.traducao = "\t" + tabID[$$.label].tipo + " "  + $$.tmp + " = " + tabID[$$.label].label + ";\n";
			}
			/*TK_TIPO_INT TK_ID '=' VALOR
			{
				struct ID id;
				id.temp =  geraTemp();
				id.tipo = $1.tipo;
				id.label = $2.label;
				id.valor = $4.valor;
				$$.tmp = id.temp;
				$$.label = id.label;
				tabID[$$.label] = id;
				//$$.traducao = "\t" + tabID[$$.label].tipo + " " + $$.tmp + " = " + tabID[$$.label].valor + ";\n";
			} 
			|TK_TIPO_INT TK_ID
			{
				struct ID id;
				id.temp =  geraTemp();
				id.tipo = $1.tipo;
				id.label = $2.label;
				$$.tmp = id.temp;
				$$.label = id.label;
				tabID[$$.label] = id;
				//$$.traducao = "\t" + tabID[$$.label].tipo + " "  + $$.tmp + " = " + tabID[$$.label].label + ";\n";
			}
			|TK_TIPO_FLOAT TK_ID '=' TK_REAL
			{
				struct ID id;
				id.temp =  geraTemp();
				id.tipo = $1.tipo;
				id.label = $2.label;
				id.valor = $4.valor;
				$$.tmp = id.temp;
				$$.label = id.label;
				tabID[$$.label] = id;
				//$$.traducao = "\t" + tabID[$$.label].tipo + " " + $$.tmp + " = " + tabID[$$.label].valor + ";\n";
			} 
			|TK_TIPO_FLOAT TK_ID
			{
				struct ID id;
				id.temp =  geraTemp();
				id.tipo = $1.tipo;
				id.label = $2.label;
				$$.tmp = id.temp;
				$$.label = id.label;
				tabID[$$.label] = id;
				//$$.traducao = "\t" + tabID[$$.label].tipo + " "  + $$.tmp + " = " + tabID[$$.label].label + ";\n";
			}
			|TK_TIPO_FLOAT TK_ID '=' TK_REAL
			{
				struct ID id;
				id.temp =  geraTemp();
				id.tipo = $1.tipo;
				id.label = $2.label;
				id.valor = $4.valor;
				$$.tmp = id.temp;
				$$.label = id.label;
				tabID[$$.label] = id;
				//$$.traducao = "\t" + tabID[$$.label].tipo + " " + $$.tmp + " = " + tabID[$$.label].valor + ";\n";
			} 
			|TK_TIPO_FLOAT TK_ID
			{
				struct ID id;
				id.temp =  geraTemp();
				id.tipo = $1.tipo;
				id.label = $2.label;
				$$.tmp = id.temp;
				$$.label = id.label;
				tabID[$$.label] = id;
				//$$.traducao = "\t" + tabID[$$.label].tipo + " "  + $$.tmp + " = " + tabID[$$.label].label + ";\n";
			}
			;*/

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
			| VALOR
			/*{
				$$.tmp = geraTemp();
				$$.traducao = "\t" + $$.tmp + " = " + $1.valor + ";\n";
			}*/
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

TIPO 		: TK_TIPO_INT | TK_TIPO_CHAR | TK_TIPO_FLOAT | TK_TIPO_STRING | TK_TIPO_BOOLEAN;

VALOR 		: TK_NUM
			{
				$$.tmp = geraTemp();
				$$.traducao = "\t" + $$.tmp + " = " + $1.valor + ";\n";
			}
			| TK_REAL
			{
				$$.tmp = geraTemp();
				$$.traducao = "\t" + $$.tmp + " = " + $1.valor + ";\n";
			}
			|TK_CHAR
			{
				$$.tmp = geraTemp();
				$$.traducao = "\t" + $$.tmp + " = " + $1.valor + ";\n";
			}
			|TK_VALOR_LOGICO
			{
				$$.tmp = geraTemp();
				$$.traducao = "\t" + $$.tmp + " = " + $1.valor + ";\n";
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