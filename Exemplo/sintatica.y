%{
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <string>
#include <sstream>
#include <map>
#include <iterator>
#include <list>
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
typedef struct atributos atributos;
typedef map<string , atributos> TABELA;
typedef map<string , atributos>::iterator ITERATOR;
#define GLOBAL 1
#define LOCAL 0
//Declarações de protótipos de funções
int yylex(void);
void yyerror(string);
string geraTemp(string tipo, int ehGlobal);
bool pertenceContextoAtual(string label);
TABELA * existeID(string label);
string getTipo(string operacao);
map<string, string> criaTabTipoRetorno();
//void declaracoes();/*Essa função cria uma string que ira declarar as variaveis que serão utilizadas durante a execução do código*/
void processaDECLARACAO(atributos * dolar, atributos * dolar1, atributos * dolar2, atributos * dolar3, atributos * dolar4, int ehGlobal);
void processaTK_ATRIBUICAO(atributos * dolar, atributos * dolar1, atributos * dolar2, atributos * dolar3);
void processaTK_VALOR(atributos * dolar, atributos * dolar1, string tipo);
void operacaoAritmetica(atributos * dolar, atributos * dolar1, atributos * dolar2, atributos * dolar3);
void castTemp(atributos * dolar, atributos * dolar1, atributos* dolar2, atributos* dolar3, string tipo);
void iniciaEscopo();
void terminaEscopo();
//Declarações de variaveis globais
string declaraVariaveis="";
string declaraVariaveisGlobais="";
TABELA tabLabel;
map<string, string> tabTipos = criaTabTipoRetorno();
list<TABELA*> pilhaDeTabelas;
%}
%token TK_NUM TK_REAL TK_VALOR_LOGICO TK_CHAR
%token TK_MAIN TK_ID
%token TK_FIM TK_ERROR
%token TK_OPERADOR_LOGICO TK_OPERADOR_RELACIONAL TK_OPERADOR_MATEMATICO TK_ATRIBUICAO
%token TK_TIPO_INT TK_TIPO_CHAR TK_TIPO_FLOAT TK_TIPO_STRING TK_TIPO_BOOLEAN
%start START
%left '+' '-'
%left '*' '/' 
%nonassoc '='	
%%
START 		: ESCOPO_GLOBAL S 
			{
				cout << "/*Compilador snap*/\n" << "#include <iostream>\n#include <string.h>\n#include <stdio.h>\n";
				cout <<$2.traducao << endl;
			};
S 			: DECL_GLOBAL ';' MAIN
			{
				$$.traducao = "\n" + declaraVariaveisGlobais + "\n" + $1.tipo + " main(void)\n{\n" 
							  + declaraVariaveis + "\n" 
							  + $1.traducao 
							  + $3.traducao 
							  + "\treturn 0;\n}"; 
			}
			| MAIN;
MAIN        :TK_TIPO_INT TK_MAIN '(' ')' BLOCO
			{
				$$.traducao = $5.traducao; 
				
			}
			;
ESCOPO_GLOBAL: 
			 {
			 	iniciaEscopo(); 
			 };
INICIA_ESCOPO:	'{'
			 {
			 	iniciaEscopo();
			 }
TERMINA_ESCOPO:	 '}'
			  {
			  	terminaEscopo();
			  }		 
BLOCO		: INICIA_ESCOPO COMANDOS TERMINA_ESCOPO
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
DECL_GLOBAL : TIPO TK_ID TK_ATRIBUICAO VALOR
			{
				processaDECLARACAO(&$$, &$1, &$2, &$3, &$4, GLOBAL);
			}
			|TIPO TK_ID
			{
				TABELA * tab = pilhaDeTabelas.front();
				atributos id;
				id.tmp =  geraTemp($1.tipo, GLOBAL);
				id.tipo = $1.tipo;
				id.label = $2.label;
				$$.tmp = id.tmp;
				$$.label = id.label;
				tabLabel[$$.label] = id;
				(*tab)[$$.label] = id;
				$$.traducao = "";
				//$$.traducao = "\t" + tabLabel[$$.label].tipo + " "  + $$.tmp + ";\n";
			};
DECLARACAO	:TIPO TK_ID TK_ATRIBUICAO VALOR
			{
									
				processaDECLARACAO(&$$, &$1, &$2, &$3, &$4, LOCAL);
				
			} 
			|TIPO TK_ID TK_ATRIBUICAO E
			{	
				processaDECLARACAO(&$$, &$1, &$2, &$3, &$4, LOCAL);
			} 
			|TIPO TK_ID
			{
				TABELA * tab = pilhaDeTabelas.front();
				atributos id;
				id.tmp =  geraTemp($1.tipo, LOCAL);
				id.tipo = $1.tipo;
				id.label = $2.label;
				$$.tmp = id.tmp;
				$$.label = id.label;
				tabLabel[$$.label] = id;
				(*tab)[$$.label] = id;
				$$.traducao = "";
				//$$.traducao = "\t" + tabLabel[$$.label].tipo + " "  + $$.tmp + ";\n";
			};
ATRIBUICAO	: TK_ID TK_ATRIBUICAO E
			{	
				//Nessa parte precisa verificar se TK_ID pertence ao contexto atual
				//processaTK_ATRIBUICAO(&$$, &$1, &$2, &$3, &$4);
				TABELA * tab = existeID($1.label);
cout<< "------------ "+$1.tipo;
				if(tab != NULL)
				{
					 
					//Verificando tipo das variaveis para decidir o tipo da nova variavel temporaria 
					if($1.tipo != $3.tipo)
					{	

						string tipo = getTipo((*tab)[$1.label].tipo + $2.operador + $3.tipo);	
						$$.traducao = $1.traducao + $3.traducao + "\t" + (*tab)[$1.label].tmp + " = " + "(" + tipo + ") " + $3.tmp + ";\n";
					}	
					else 
					{
						$$.traducao = $1.traducao + $3.traducao + "\t" + (*tab)[$1.label].tmp + " = " + $3.tmp + ";\n";
					}
					
				}	
			}
			;
E 			:'(' E ')'
			{
				$$.tmp = $2.tmp;
				$$.traducao = $2.traducao;
			} 
			|E TK_OPERADOR_MATEMATICO E
			{
				operacaoAritmetica(&$$, &$1, &$2, &$3); 
				
			}//Refazer esse operador	
			|E TK_OPERADOR_RELACIONAL E //Refazer esse operador
			{
				//Verificando tipo das variaveis para decidir o tipo da nova variavel temporaria 
				if($1.tipo != $3.tipo)
				{
					string tipo = getTipo($1.tipo +  $2.operador + $3.tipo);
					$$.tmp = geraTemp(tipo, LOCAL);
					$$.tipo = tipo;	
					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.tmp + " = " + $1.tmp + $2.operador + $3.tmp + ";\n";
				}	
				else
				{
					$$.tmp = geraTemp($1.tipo, LOCAL);
					$$.tipo = $1.tipo;	
					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.tmp + " = " + $1.tmp + $2.operador + $3.tmp + ";\n";	
				}
			}	
			|E TK_OPERADOR_LOGICO E //Refazer esse operador
			{
				//Verificando tipo das variaveis para decidir o tipo da nova variavel temporaria 
				if($1.tipo != $3.tipo)
				{
					string tipo = getTipo($1.tipo +  $2.operador + $3.tipo);
					$$.tmp = geraTemp(tipo, LOCAL);
					$$.tipo = tipo;	
					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.tmp + " = " + $1.tmp + $2.operador + $3.tmp + ";\n";
				}	
				else
				{
					$$.tmp = geraTemp($1.tipo, LOCAL);
					$$.tipo = $1.tipo;	
					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.tmp + " = " + $1.tmp + $2.operador + $3.tmp + ";\n";	
				}
			}	
			|VALOR
			|TK_ID
			{
				//Nessa parte precisa verificar se TK_ID pertence ao contexto atual
				TABELA * tab = existeID($1.label);
				if(tab != NULL)
				{
					$$.tmp = (*tab)[$1.label].tmp;
					$$.label = (*tab)[$1.label].label;
					$$.valor = (*tab)[$1.label].valor;
					$$.tipo = (*tab)[$1.label].tipo;
				}
				
			}
			;
TIPO 		: TK_TIPO_INT | TK_TIPO_CHAR | TK_TIPO_FLOAT | TK_TIPO_STRING | TK_TIPO_BOOLEAN;
VALOR 		: TK_NUM
			{
				processaTK_VALOR(&$$, &$1, "int");
			}
			| TK_REAL
			{
				processaTK_VALOR(&$$, &$1, "float");
			}
			|TK_CHAR
			{
				processaTK_VALOR(&$$, &$1, "char");
			}
			|TK_VALOR_LOGICO
			{
				processaTK_VALOR(&$$, &$1, "boolean");
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
string geraTemp(string tipo, int ehGlobal){
	
	static int i = 0;
	stringstream ss;
	ss << "temp" << i++;
	if(ehGlobal == 1)
		declaraVariaveisGlobais += tipo + " " + ss.str() + ";\n";
	else
		declaraVariaveis += "\t" + tipo + " " + ss.str() + ";\n";
	
	return ss.str();
}			
void iniciaEscopo()
{
	TABELA* tab = new  TABELA();
	pilhaDeTabelas.push_front(tab);
}
void terminaEscopo()
{
	pilhaDeTabelas.pop_front();
}
TABELA * existeID(string label)
{
	list<TABELA*>::iterator i;
	for(i = pilhaDeTabelas.begin(); i != pilhaDeTabelas.end(); i++)
	{
		
		TABELA * tab = *i;
		if(tab->find(label) != tab->end())
		{
			return 	tab;
		}
	}
	return NULL;
}
bool pertenceContextoAtual(string label)
{
	TABELA * tab = pilhaDeTabelas.front();
	if(tab->find(label) == tab->end())
		return false;
	else
		return true;
}
string getTipo(string operacao)
{
	string tipo = tabTipos[operacao];
	if(tipo == "ERRO")
	{
		yyerror("Operação inválida: '" + operacao + "'");
		return 0;
	}
	return tipo;
}
void processaTK_ATRIBUICAO(atributos * dolar, atributos * dolar1, atributos * dolar2, atributos * dolar3)
{
	TABELA * tab1 = existeID(dolar1->label);
	if(tab1 == NULL)
	{
		cout << "dolar1" << endl;
		yyerror( "Variavel " + dolar1->label + " nao declarada!");
	}
	
	TABELA * tab2 = existeID(dolar3->label);
	if(tab2 == NULL)
	{
		cout << "dolar3" << endl;
		yyerror( "Variavel " + dolar3->label + " nao declarada!");
	}

	cout << (*tab1)[dolar1->label].tipo << endl;
	//Verificando tipo para ver a necessidade de cast
	if((*tab1)[dolar1->label].tipo != (*tab2)[dolar3->label].tipo)
	{	
		string tipo = getTipo((*tab1)[dolar1->label].tipo + dolar2->operador + (*tab2)[dolar3->label].tipo);
		
		
		dolar->traducao = dolar1->traducao + dolar3->traducao + "\t" + 
		                  (*tab1)[dolar1->label].tmp + " = " + "(" + tipo + ") " + 
		                  (*tab2)[dolar3->label].tmp + ";\n";
	}	
	else
	{
		dolar->traducao = dolar1->traducao + dolar3->traducao  + "\t" + 
		                  (*tab1)[dolar1->label].tmp + " = " + 
		                  (*tab2)[dolar3->label].tmp + ";\n";
	}
}

void processaDECLARACAO(atributos * dolar, atributos * dolar1, atributos * dolar2, atributos * dolar3, atributos * dolar4, int ehGlobal)
{
	TABELA * tab = pilhaDeTabelas.front();
	//Verificando tipo para ver a necessidade de cast
	if(dolar1->tipo != dolar4->tipo)
	{	
		string tipo = getTipo(dolar1->tipo + dolar3->operador + dolar4->tipo);
		(*tab)[dolar2->label].tmp =  geraTemp(tipo, ehGlobal);
		(*tab)[dolar2->label].tipo = dolar1->tipo;
		(*tab)[dolar2->label].label = dolar2->label;
		
		dolar->tmp = (*tab)[dolar2->label].tmp;
		dolar->label = (*tab)[dolar2->label].label;
		dolar->traducao = dolar4->traducao + "\t" + (*tab)[dolar2->label].tmp + " = " + "(" + tipo + ") " + dolar4->tmp + ";\n";
	}	
	else
	{
		(*tab)[dolar2->label].tmp =  geraTemp(dolar1->tipo, ehGlobal);
		(*tab)[dolar2->label].tipo = dolar1->tipo;
		(*tab)[dolar2->label].label = dolar2->label;
		dolar->tmp = (*tab)[dolar2->label].tmp;
		dolar->label = (*tab)[dolar2->label].label;
		dolar->traducao = dolar4->traducao  + "\t" + (*tab)[dolar2->label].tmp + " = " + dolar4->tmp + ";\n";
	}
}
void processaTK_VALOR(atributos * dolar, atributos * dolar1, string tipo)
{

	TABELA * tab = pilhaDeTabelas.front();
	atributos id;
	id.tmp =  geraTemp(tipo, LOCAL);
	id.label = id.tmp;
	id.tipo = tipo;
	id.valor = dolar1->valor;
	dolar->tmp = id.tmp;
	dolar->label = id.tmp;
	(*tab)[dolar->label] = id;
	dolar->traducao = "\t" + dolar->tmp  + " = " + dolar1->valor + ";\n";
}
void operacaoAritmetica(atributos * dolar, atributos * dolar1, atributos * dolar2, atributos * dolar3)
{
	TABELA * tab = pilhaDeTabelas.front();
	//Verificando se há necessidade de fazer cast. Caso sim, decidir o tipo da nova variavel temporaria para o cast
	if(dolar1->tipo != dolar3->tipo)
	{
		string tipo = getTipo(dolar1->tipo +  dolar2->operador + dolar3->tipo);
		castTemp(dolar, dolar1, dolar2, dolar3, tipo);
	}	
	else
	{
		dolar->tmp = geraTemp(dolar1->tipo, LOCAL);
		dolar->tipo = dolar1->tipo;	
		dolar->traducao = dolar1->traducao + dolar3->traducao + "\t" + dolar->tmp + " = " + dolar1->tmp + " " + dolar2->operador + " " + dolar3->tmp + ";\n";	
		atributos id;
		id.tmp = dolar->tmp;
		id.tmp = dolar->tmp;
		id.tipo = dolar->tipo;
		(*tab)[id.label] = id;
	}
}
void castTemp(atributos * dolar, atributos * dolar1, atributos* dolar2, atributos* dolar3,  string tipo)
{
	atributos castT;


	if (dolar1->tipo != tipo)
	{
		castT.tmp = geraTemp(tipo, LOCAL);
		castT.label = castT.tmp;
		castT.tipo = tipo;
		castT.traducao = "\t" + castT.tmp + " = (" +  tipo + ") "  + dolar1->tmp + ";\n";
		tabLabel[castT.label] = castT;
		
		dolar->tmp = geraTemp(tipo, LOCAL);
		dolar->tipo = tipo;	
		dolar->traducao += dolar1->traducao + dolar3->traducao + castT.traducao + "\t" + dolar->tmp + " = " + dolar1->tmp + " " + dolar2->operador + " " + castT.tmp + ";\n";
		atributos id;
		id.tmp = dolar->tmp;
		id.tmp = dolar->tmp;
		id.tipo = dolar->tipo;
		tabLabel[id.label] = id;
	}
	else
	{
		castT.tmp = geraTemp(tipo, LOCAL);
		castT.label = castT.tmp;
		castT.tipo = tipo;
		castT.traducao = "\t" + castT.tmp + " = (" +  tipo + ") "  + dolar3->tmp + ";\n";
		tabLabel[castT.label] = castT;
		dolar->tmp = geraTemp(tipo, LOCAL);
		dolar->tipo = tipo;	
		dolar->traducao += dolar1->traducao + dolar3->traducao + castT.traducao + "\t" + dolar->tmp + " = " + dolar1->tmp + " " + dolar2->operador + " " + castT.tmp + ";\n";
		atributos id;
		id.tmp = dolar->tmp;
		id.tmp = dolar->tmp;
		id.tipo = dolar->tipo;
		tabLabel[id.label] = id;
	}
}
/*void declaracoes()
{	
	ITERATOR it;
	stringstream ss;
		
	for (it = tabLabel.begin(); it!=tabLabel.end(); it++)
	{
		ss << "\t" << it->second.tipo << " " << it->second.tmp << ";\n"; 
	}
	declaraVariaveis += ss.str();
}*/
map<string, string> criaTabTipoRetorno()
{
    map<string, string> tabela_tipos;
    
    //Tabela de Operação para soma
tabela_tipos["int+int"] = "int";
    tabela_tipos["int+float"] = "float";
    tabela_tipos["float+int"] = "float";
    tabela_tipos["int+string"] = "string";
    tabela_tipos["string+int"] = "string";
    tabela_tipos["int+char"] = "char"; //Feature: Concactena o char com o inteiro
    tabela_tipos["char+int"] = "char";//Feature: Concactena o char com o inteiro
    tabela_tipos["float+float"] = "float";
    tabela_tipos["float+string"] = "string";
    tabela_tipos["string+float"] = "string";
    tabela_tipos["char+char"] = "string";
    tabela_tipos["char+string"] = "string";
    tabela_tipos["string+char"] = "string";
    tabela_tipos["string+string"] = "string";
 
    //Tabela de Operação para subtração    
    tabela_tipos["int-int"] = "int";
    tabela_tipos["int-float"] = "float";
    tabela_tipos["float-int"] = "float";
    tabela_tipos["int-string"] = "string";
    tabela_tipos["string-int"] = "string";
    tabela_tipos["int-char"] = "ERRO"; //ERRO
    tabela_tipos["char-int"] = "ERRO";//ERRO
    tabela_tipos["float-float"] = "float";
    tabela_tipos["float-string"] = "ERRO";
    tabela_tipos["string-float"] = "ERRO";
    tabela_tipos["char-char"] = "string";
    tabela_tipos["char-string"] = "string";
    tabela_tipos["string-char"] = "string";
    tabela_tipos["string-string"] = "string";

    //Tabela de Operação para multiplicação
    tabela_tipos["int*int"] = "int";
    tabela_tipos["int*float"] = "float";
    tabela_tipos["float*int"] = "float";
    tabela_tipos["int*string"] = "ERRO";//Feature: multiplica string pela quantidade de vezes do inteiro
    tabela_tipos["string*int"] = "ERRO";//Feature: multiplica string pela quantidade de vezes do inteiro
    tabela_tipos["int*char"] = "ERRO"; //Feature: Verificar qual tipo de feature pode ser adcionada
    tabela_tipos["char*int"] = "ERRO";//Feature: Verificar qual tipo de feature pode ser adcionada
    tabela_tipos["float*float"] = "float";
    tabela_tipos["float*string"] = "ERRO";//Feature: multiplica string pela quantidade de vezes do float
    tabela_tipos["string*float"] = "ERRO";//Feature: multiplica string pela quantidade de vezes do float
    tabela_tipos["char*char"] = "ERRO";
    tabela_tipos["char*string"] = "ERRO";
    tabela_tipos["string*char"] = "ERRO";
    tabela_tipos["string*string"] = "ERRO";
    
    //Tabela de Operação para divisão
    tabela_tipos["int/int"] = "int";
    tabela_tipos["int/float"] = "ERRO";
    tabela_tipos["float/int"] = "float";
    tabela_tipos["int/string"] = "ERRO";
    tabela_tipos["string/int"] = "ERRO";
    tabela_tipos["int/char"] = "ERRO"; //Verificar se será esse tipo mesmo para essa operação
    tabela_tipos["char/int"] = "ERRO";
    tabela_tipos["float/float"] = "float";
    tabela_tipos["float/string"] = "ERRO";
    tabela_tipos["string/float"] = "ERRO";
    tabela_tipos["char/char"] = "ERRO";
    tabela_tipos["char/string"] = "ERRO";
    tabela_tipos["string/char"] = "ERRO";
    tabela_tipos["string/string"] = "ERRO";
   
   	
	// Para operadores relacionais, lógicos e atribuicao, a tabela da o tipo de cast6
	
	//Tabela de Operação para maior    
    tabela_tipos["int>int"] = "int";
    tabela_tipos["int>float"] = "ERRO";
    tabela_tipos["float>int"] = "ERRO";
    tabela_tipos["int>string"] = "ERRO";
    tabela_tipos["string>int"] = "ERRO";
    tabela_tipos["int>char"] = "ERRO"; //ERRO
    tabela_tipos["char>int"] = "ERRO";//ERRO
    tabela_tipos["float>float"] = "int";
    tabela_tipos["float>string"] = "ERRO";
    tabela_tipos["string>float"] = "ERRO";
    tabela_tipos["char>char"] = "int";
    tabela_tipos["char>string"] = "ERRO";
    tabela_tipos["string>char"] = "ERRO";
    tabela_tipos["string>string"] = "int"; 

    //Tabela de Operação para maior e igual
    tabela_tipos["int>=int"] = "int";
    tabela_tipos["int>=float"] = "ERRO";
    tabela_tipos["float>=int"] = "ERRO";
    tabela_tipos["int>=string"] = "ERRO";
    tabela_tipos["string>=int"] = "ERRO";
    tabela_tipos["int>=char"] = "ERRO"; //ERRO
    tabela_tipos["char>=int"] = "ERRO";//ERRO
    tabela_tipos["float>=float"] = "int";
    tabela_tipos["float>=string"] = "ERRO";
    tabela_tipos["string>=float"] = "ERRO";
    tabela_tipos["char>=char"] = "int";
    tabela_tipos["char>=string"] = "ERRO";
    tabela_tipos["string>=char"] = "ERRO";
    tabela_tipos["string>=string"] = "int"; 

    //Tabela de Operação para menor    
    tabela_tipos["int<int"] = "int";
    tabela_tipos["int<float"] = "ERRO";
    tabela_tipos["float<int"] = "ERRO";
    tabela_tipos["int<string"] = "ERRO";
    tabela_tipos["string<int"] = "ERRO";
    tabela_tipos["int<char"] = "ERRO"; //ERRO
    tabela_tipos["char<int"] = "ERRO";//ERRO
    tabela_tipos["float<float"] = "int";
    tabela_tipos["float<string"] = "ERRO";
    tabela_tipos["string<float"] = "ERRO";
    tabela_tipos["char<char"] = "int";
    tabela_tipos["char<string"] = "ERRO";
    tabela_tipos["string<char"] = "ERRO";
    tabela_tipos["string<string"] = "int";


    //Tabela de Operação para menor e igual    
    tabela_tipos["int<=int"] = "int";
    tabela_tipos["int<=float"] = "ERRO";
    tabela_tipos["float<=int"] = "ERRO";
    tabela_tipos["int<=string"] = "ERRO";
    tabela_tipos["string<=int"] = "ERRO";
    tabela_tipos["int<=char"] = "ERRO"; //ERRO
    tabela_tipos["char<=int"] = "ERRO";//ERRO
    tabela_tipos["float<=float"] = "int";
    tabela_tipos["float<=string"] = "ERRO";
    tabela_tipos["string<=float"] = "ERRO";
    tabela_tipos["char<=char"] = "int";
    tabela_tipos["char<=string"] = "ERRO";
    tabela_tipos["string<=char"] = "ERRO";
    tabela_tipos["string<=string"] = "int";

    //Tabela de Operação para  igual    
    tabela_tipos["int==int"] = "int";
    tabela_tipos["int==float"] = "ERRO";
    tabela_tipos["float==int"] = "ERRO";
    tabela_tipos["int==string"] = "ERRO";
    tabela_tipos["string==int"] = "ERRO";
    tabela_tipos["int==char"] = "ERRO"; //ERRO
    tabela_tipos["char==int"] = "ERRO";//ERRO
    tabela_tipos["float==float"] = "int";
    tabela_tipos["float==string"] = "ERRO";
    tabela_tipos["string==float"] = "ERRO";
    tabela_tipos["char==char"] = "int";
    tabela_tipos["char==string"] = "ERRO";
    tabela_tipos["string==char"] = "ERRO";
    tabela_tipos["string==string"] = "int";

    //Tabela de Operação para  diferente    
    tabela_tipos["int!=int"] = "int";
    tabela_tipos["int!=float"] = "ERRO";
    tabela_tipos["float!=int"] = "ERRO";
    tabela_tipos["int!=string"] = "ERRO";
    tabela_tipos["string!=int"] = "ERRO";
    tabela_tipos["int!=char"] = "ERRO"; //ERRO
    tabela_tipos["char!=int"] = "ERRO";//ERRO
    tabela_tipos["float!=float"] = "int";
    tabela_tipos["float!=string"] = "ERRO";
    tabela_tipos["string!=float"] = "ERRO";
    tabela_tipos["char!=char"] = "int";
    tabela_tipos["char!=string"] = "ERRO";
    tabela_tipos["string!=char"] = "ERRO";
    tabela_tipos["string!=string"] = "int";
   	
   	//Tabela de Operação para atribuição 
   	tabela_tipos["int=int"] = "int";
    tabela_tipos["int=float"] = "int";
    tabela_tipos["float=int"] = "float";
    tabela_tipos["int=string"] = "ERRO";
    tabela_tipos["string=int"] = "ERRO";
    tabela_tipos["int=char"] = "ERRO";
    tabela_tipos["char=int"] = "ERRO";
    tabela_tipos["float=float"] = "float";
    tabela_tipos["float=string"] = "ERRO";
    tabela_tipos["string=float"] = "ERRO";
    tabela_tipos["char=char"] = "char";
    tabela_tipos["char=string"] = "ERRO";
    tabela_tipos["string=char"] = "string";
    tabela_tipos["string=string"] = "string";
   	
    
    return tabela_tipos;   
}