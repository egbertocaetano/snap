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
	string operador;
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
int verificaInicializacao(atributos a);
%}

%token TK_NUM TK_REAL TK_VALOR_LOGICO TK_CHAR
%token TK_MAIN TK_ID
%token TK_FIM TK_ERROR
%token TK_OPERADOR_LOGICO TK_OPERADOR_RELACIONAL TK_OPERADOR_MATEMATICO
%token TK_TIPO_INT TK_TIPO_CHAR TK_TIPO_FLOAT TK_TIPO_STRING TK_TIPO_BOOLEAN

%start S

%left '+' '-'
%left '*' '/' 
%nonassoc '='	


%%

S 			: TK_TIPO_INT TK_MAIN '(' ')' BLOCO
			{
				cout << "/*Compilador snap*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\n" + $1.tipo + " main(void)\n{\n" << $5.traducao << "\treturn 0;\n}" << endl; 
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
				$$.traducao = $4.traducao + "\t" + tabID[$$.label].tipo + " " + $$.tmp + " = " + $4.tmp + ";\n";
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
				$$.traducao = "\t" + tabID[$$.label].tipo + " "  + $$.tmp + ";\n";
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
			|E OPERADOR E
			{

				if(verificaInicializacao($1) && verificaInicializacao($3)){
					
					$$.tmp = geraTemp();	
					$$.traducao = $1.traducao+ $3.traducao+ "\t" + $$.tmp+ " = " + $1.tmp+ $2.operador + $3.tmp + ";\n";
				}			
			}	
			| VALOR
			| TK_ID
			{
				if(existeID($1.label))
				{
					$$.tmp = tabID[$1.label].temp;
					$$.label = tabID[$$.label].label;
					//$$.traducao = "\t" + $$.tmp + " = " + tabID[$$.label].label + ";\n";
				}
				
			}
			;

OPERADOR 	: TK_OPERADOR_LOGICO | TK_OPERADOR_RELACIONAL | TK_OPERADOR_MATEMATICO

TIPO 		: TK_TIPO_INT | TK_TIPO_CHAR | TK_TIPO_FLOAT | TK_TIPO_STRING | TK_TIPO_BOOLEAN;

VALOR 		: TK_NUM
			{
				$$.tmp = geraTemp();
				$$.traducao = "\t" + $1.tipo + " " + $$.tmp + " = " + $1.valor + ";\n";
			}
			| TK_REAL
			{
				$$.tmp = geraTemp();
				$$.traducao = "\t" + $1.tipo + " " + $$.tmp + " = " + $1.valor + ";\n";
			}
			|TK_CHAR
			{
				$$.tmp = geraTemp();
				$$.traducao = "\t" + $1.tipo + " " + $$.tmp + " = " + $1.valor + ";\n";
			}
			|TK_VALOR_LOGICO
			{
				$$.tmp = geraTemp();
				$$.traducao = "\t" + $1.tipo + " " + $$.tmp + " = " + $1.valor + ";\n";
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

	yyerror("Variavel '" + label + "' nao declarada.");
	return 0;
}	

int verificaInicializacao(atributos a)
{
	if(existeID(a.label)){
		if(tabID[a.label].valor != "")			
			return 1; // eh uma variavel inicializada
	}else if(a.valor != "")
		return 1; // eh um numero
	yyerror("Variavel '" + a.label + "' nao inicializada.");
	return 0;	
}
