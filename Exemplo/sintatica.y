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

#define TRUE 1
#define FALSE 0

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
void processaATRIBUICAO(atributos * dolar, atributos * dolar1, atributos * dolar2, atributos * dolar3);
void processaTK_VALOR(atributos * dolar, atributos * dolar1, string tipo);
void processaTK_ID(atributos * dolar, atributos * dolar1, atributos * dolar2, int ehGlobal);
void operacaoAritmetica(atributos * dolar, atributos * dolar1, atributos * dolar2, atributos * dolar3);
void traducaoOpAritmeticaIncDec(atributos* dolar, atributos* dolar1, atributos* dolar2);
void castTemp(atributos * dolar, atributos * dolar1, atributos* dolar2, atributos* dolar3, string tipo);
void iniciaEscopo();
void terminaEscopo();


//Declarações de variaveis globais
string declaraVariaveis="";
string declaraVariaveisGlobais="";
//TABELA tabLabel;
map<string, string> tabTipos = criaTabTipoRetorno();
list<TABELA*> pilhaDeTabelas;


%}

%token TK_NUM TK_REAL TK_VALOR_LOGICO TK_CHAR
%token TK_MAIN TK_ID TK_IF TK_ELSE TK_FOR TK_WHILE TK_DO
%token TK_FIM TK_ERROR
%token TK_OPERADOR_LOGICO TK_OPERADOR_RELACIONAL TK_OPERADOR_MATEMATICO TK_ATRIBUICAO TK_OPERADOR_CREMENTO
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
				$$.traducao = "\n" + declaraVariaveisGlobais + $3.traducao; 
							   
			}
			| MAIN;

MAIN        :TK_TIPO_INT TK_MAIN '(' ')' BLOCO
			{

				$$.traducao = "\n" + $1.tipo + " main(void)\n{\n" + declaraVariaveis + "\n" + $5.traducao + "\treturn 0;\n}"; 
				
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
			| TK_IF '(' E ')' BLOCO
			{
				$$.traducao= "\n" + $3.traducao + "\n\t" + "if(!" + $3.tmp + ")goto FIM_IF\n" + $5.traducao + "\n\tFIM_IF:\n";
			}
			| TK_IF '(' E ')' BLOCO TK_ELSE BLOCO
			{
				
				$$.traducao= "\n" + $3.traducao + "\n\t" + "if(!" + $3.tmp + ")goto ELSE\n" + $5.traducao + "\tgoto FIM_IF\n" 
							+ "\n\tELSE:\n" + $7.traducao + "\n\tFIM_IF:\n";				
			}
			| TK_WHILE '(' E ')' BLOCO // obs: ve se precisa colocar ; pra fechar  while e do while
			{
				$$.traducao= "\n" + $3.traducao + "\n\t" + "LOOP:\n\twhile(!" + $3.tmp + ")goto FIM_WHILE\n" + $5.traducao + "\tgoto LOOP\n"
				+"\tFIM_WHILE:\n";

			}
			| TK_DO BLOCO TK_WHILE '(' E ')' ';'
			{
				$$.traducao= "\n" + $5.traducao + "\n\t" + "LOOP:\n\tdo\n" + $2.traducao + "\twhile(" + $5.tmp + ")goto LOOP\n";
			}
			|  TK_FOR '(' DECLARACAO ';' E ';' TK_ID TK_OPERADOR_CREMENTO ')' BLOCO 
			{
				$$.traducao= "\n" + $5.traducao + "\n\t" + "\n" + $3.traducao + "\n\t" "LOOP:\n\tfor(" + $3.tmp + ";" + $5.tmp + ";" + $8.traducao +")"
				 + $9.traducao + "FIM_FOR"; // corrigir o ++ e -- ta cagado
			}
			;



DECL_GLOBAL : TIPO TK_ID TK_ATRIBUICAO VALOR
			{
				processaDECLARACAO(&$$, &$1, &$2, &$3, &$4, GLOBAL);
			}
			|TIPO TK_ID
			{
				processaTK_ID(&$$, &$1, &$2, GLOBAL);
			};

DECLARACAO	:TIPO TK_ID TK_ATRIBUICAO E
			{	

				processaDECLARACAO(&$$, &$1, &$2, &$3, &$4, LOCAL);

			} 
			|TIPO TK_ID
			{
				 processaTK_ID(&$$, &$1, &$2, LOCAL);
			};

ATRIBUICAO	: TK_ID TK_ATRIBUICAO E
			{	
				//Nessa parte precisa verificar se TK_ID pertence ao contexto atual
				processaATRIBUICAO(&$$, &$1, &$2, &$3);

			}
			| TK_ID TK_OPERADOR_CREMENTO // E ++
			{
				traducaoOpAritmeticaIncDec(&$$, &$1, &$2);
			}
			| TK_OPERADOR_CREMENTO TK_ID // ++ E
			{
				traducaoOpAritmeticaIncDec(&$$, &$2, &$1);
			}
			
			// |TK_ID TK_OPERADOR_CREMENTO
			// {	
			// 	//Nessa parte precisa verificar se TK_ID pertence ao contexto atual
			// 	if ($2.label == "++")
			// 	{
			// 		$2.valor = 1 ;
			// 		$2.tipo = "int" ;
			// 		operacaoAritmetica(&$$, &$1, "+", &$2);
			// 	}
			//};;

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
				string tipo;
				//Verificando tipo das variaveis para decidir o tipo da nova variavel temporaria 			
				if($1.tipo != $3.tipo)
				{	
					tipo = getTipo($1.tipo +  $2.operador + $3.tipo);				
					//cout << $1.tipo +  $2.operador + $3.tipo<< endl;
					$$.tmp = geraTemp(tipo, LOCAL);
					$$.tipo = tipo;	
					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.tmp + " = " + $1.tmp + $2.operador + $3.tmp + ";\n";
				}	
				else
				{
					
					$$.tmp = geraTemp($1.tipo, LOCAL);
					$$.tipo = tipo;	
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

TIPO 		: TK_TIPO_INT
			{
				$$.tipo = "int";
			} 
			| TK_TIPO_CHAR
			{
				$$.tipo = "char";
			} 
			| TK_TIPO_FLOAT 
			{
				$$.tipo = "float";	
			}
			| TK_TIPO_STRING
			{
				$$.tipo = "string";	
			} 
			| TK_TIPO_BOOLEAN
			{
				$$.tipo = "int";
			}
			;

VALOR 		: TK_NUM
			{
				processaTK_VALOR(&$$, &$1, "int");
			}
			| TK_REAL
			{
				processaTK_VALOR(&$$, &$1, "float");
			}
			| TK_CHAR
			{
				processaTK_VALOR(&$$, &$1, "char");
			}
			|TK_VALOR_LOGICO
			{	
				if($1.valor == "TRUE")
					$1.valor = "1";
				else
					$1.valor = "0";
				 
				processaTK_VALOR(&$$, &$1, "int");
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
	{
		declaraVariaveisGlobais += tipo + " " + ss.str() + ";\n";
	}
	else
	{
		declaraVariaveis += "\t" + tipo + " " + ss.str() + ";\n";
	}
	

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

void processaATRIBUICAO(atributos * dolar, atributos * dolar1, atributos * dolar2, atributos * dolar3)
{

	//cout << dolar1->label + dolar3->label << endl;

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

	//Verificando tipo para ver a necessidade de cast
	if((*tab1)[dolar1->label].tipo != (*tab2)[dolar3->label].tipo)
	{	
		string tipo = getTipo((*tab1)[dolar1->label].tipo + dolar2->operador + (*tab2)[dolar3->label].tipo);

		cout << (*tab1)[dolar1->label].tipo + (*tab2)[dolar3->label].tipo << endl;

		dolar->traducao = dolar1->traducao + dolar3->traducao + "\t" + (*tab1)[dolar1->label].tmp + " = " + "(" + tipo + ") " + (*tab2)[dolar3->label].tmp + ";\n";
	}	
	else
	{
		dolar->traducao = dolar1->traducao + dolar3->traducao  + "\t" + (*tab1)[dolar1->label].tmp + " = " + (*tab2)[dolar3->label].tmp + ";\n";
	}
}

void processaDECLARACAO(atributos * dolar, atributos * dolar1, atributos * dolar2, atributos * dolar3, atributos * dolar4, int ehGlobal)
{
	TABELA * tab = pilhaDeTabelas.front();

	//Verificando tipo para ver a necessidade de cast
	if(dolar1->tipo != dolar4->tipo)
	{			

		string tipo = getTipo(dolar1->tipo + dolar3->operador + dolar4->tipo);

		dolar->tmp = geraTemp(tipo, ehGlobal);
		dolar->label = dolar2->label;
		dolar->tipo = dolar1->tipo;
		
		(*tab)[dolar2->label].tmp =  dolar->tmp;
		(*tab)[dolar2->label].tipo = dolar->tipo;
		(*tab)[dolar2->label].label = dolar->label;

		dolar->traducao = dolar4->traducao + "\t" + (*tab)[dolar2->label].tmp + " = " + "(" + tipo + ") " + dolar4->tmp + ";\n";
	}	
	else
	{
		dolar->tmp = geraTemp(dolar1->tipo, ehGlobal);
		dolar->label = dolar2->label;
		dolar->tipo = dolar1->tipo;

		(*tab)[dolar2->label].tmp =  dolar->tmp;
		(*tab)[dolar2->label].tipo = dolar->tipo;
		(*tab)[dolar2->label].label = dolar->label;

		dolar->traducao = dolar4->traducao  + "\t" + (*tab)[dolar2->label].tmp + " = " + dolar4->tmp + ";\n";
	}
}

void processaTK_ID(atributos * dolar, atributos * dolar1, atributos * dolar2, int ehGlobal)
{
	TABELA * tab = pilhaDeTabelas.front();

	dolar->tmp = geraTemp(dolar1->tipo, ehGlobal);
	dolar->label = dolar2->label;
	dolar->tipo = dolar1->tipo;

	(*tab)[dolar2->label].tmp = dolar->tmp;
	(*tab)[dolar2->label].tipo = dolar->tipo;
	(*tab)[dolar2->label].label = dolar->label;
	
	dolar->traducao = "";
}

void processaTK_VALOR(atributos * dolar, atributos * dolar1, string tipo)
{
	TABELA * tab = pilhaDeTabelas.front();

	dolar->tmp = geraTemp(tipo, LOCAL);;
	dolar->label = dolar->tmp;
	dolar->tipo = tipo;
	dolar->valor = dolar1->valor;
	dolar->traducao = "\t" + dolar->tmp  + " = " + dolar1->valor + ";\n";

	(*tab)[dolar->label].tmp =  dolar->tmp;
	(*tab)[dolar->label].label = dolar->label;
	(*tab)[dolar->label].tipo = dolar->tipo;
	(*tab)[dolar->label].valor = dolar->valor;
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

		(*tab)[dolar->label].tmp =  dolar->tmp;
		(*tab)[dolar->label].label = dolar->label;
		(*tab)[dolar->label].tipo = dolar->tipo;
	}
}

void traducaoOpAritmeticaIncDec(atributos* dolar, atributos* dolar1,atributos* dolar2)
{	
		TABELA * tab = pilhaDeTabelas.front();
	//Verificando se há necessidade de fazer cast. Caso sim, decidir o tipo da nova variavel temporaria para o cast
	
		// dolar->tmp = geraTemp(dolar1->tipo, LOCAL);
		// dolar->tipo = dolar1->tipo;	
		//dolar->traducao = dolar1->traducao + dolar2->traducao + "\t" + dolar->tmp + " = " + dolar1->tmp + " + " + dolar2->tmp + ";\n";	
	
		if (dolar2->label == "++") { 
			dolar->traducao = dolar1->traducao + "\t" + dolar->tmp + " = " + dolar1->tmp + " + 1;\n";	
	
		}
		else if (dolar2->label == "--") {
			dolar->traducao = dolar1->traducao + "\t" + dolar->tmp + " = " + dolar1->tmp + " - 1;\n";	
		}

		(*tab)[dolar->label].tmp =  dolar->tmp;
		(*tab)[dolar->label].label = dolar->label;
		(*tab)[dolar->label].tipo = dolar->tipo;
		
	
}

void castTemp(atributos * dolar, atributos * dolar1, atributos* dolar2, atributos* dolar3,  string tipo)
{
	
	TABELA * tab = pilhaDeTabelas.front();
	atributos castT;


	if (dolar1->tipo != tipo)
	{
		castT.tmp = geraTemp(tipo, LOCAL);
		castT.label = castT.tmp;
		castT.tipo = tipo;
		castT.traducao = "\t" + castT.tmp + " = (" +  tipo + ") "  + dolar1->tmp + ";\n";
		(*tab)[castT.label] = castT;
		
		dolar->tmp = geraTemp(tipo, LOCAL);
		dolar->label = dolar->tmp;
		dolar->tipo = tipo;	
		dolar->traducao = dolar1->traducao + dolar3->traducao + castT.traducao + "\t" + dolar->tmp + " = " + dolar1->tmp + " " + dolar2->operador + " " + castT.tmp + ";\n";

		(*tab)[dolar->label].tmp =  dolar->tmp;
		(*tab)[dolar->label].label = dolar->label;
		(*tab)[dolar->label].tipo = dolar->tipo;

	}
	else
	{
		castT.tmp = geraTemp(tipo, LOCAL);
		castT.label = castT.tmp;
		castT.tipo = tipo;
		castT.traducao = "\t" + castT.tmp + " = (" +  tipo + ") "  + dolar3->tmp + ";\n";
		(*tab)[castT.label] = castT;

		dolar->tmp = geraTemp(tipo, LOCAL);
		dolar->label = dolar->tmp;
		dolar->tipo = tipo;	
		dolar->traducao = dolar1->traducao + dolar3->traducao + castT.traducao + "\t" + dolar->tmp + " = " + dolar1->tmp + " " + dolar2->operador + " " + castT.tmp + ";\n";

		(*tab)[dolar->label].tmp =  dolar->tmp;
		(*tab)[dolar->label].label = dolar->label;
		(*tab)[dolar->label].tipo = dolar->tipo;
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
    tabela_tipos["int-char"] = "char"; //ERRO
    tabela_tipos["char-int"] = "char";//ERRO
    tabela_tipos["float-float"] = "float";
    tabela_tipos["float-string"] = "string";
    tabela_tipos["string-float"] = "string";
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
    tabela_tipos["int/float"] = "float";
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
    tabela_tipos["string=int"] = "string";
    tabela_tipos["int=char"] = "ERRO";
    tabela_tipos["char=int"] = "ERRO";
    tabela_tipos["float=float"] = "float";
    tabela_tipos["float=string"] = "ERRO";
    tabela_tipos["string=float"] = "string";
    tabela_tipos["char=char"] = "char";
    tabela_tipos["char=string"] = "ERRO";
    tabela_tipos["string=char"] = "string";
    tabela_tipos["string=string"] = "string";
   	
    
    return tabela_tipos;   
}
