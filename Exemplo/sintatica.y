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
	string jumpLabel;
	string gotojumpLabel;
	string loopLabel;
	string traducao;
	string tmp;
	int tamanhoString;
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
string geraTempString(int tamanho, int ehGlobal);
string gerajumpLabel();
string geraLoopLabelINICIO(string looplabel);
string geraLoopLabelFIM(string looplabel);
string geraCONDLabelINICIO(string looplabel);
string geraCONDLabelFIM(string looplabel);
string geraCASELabelINICIO(string looplabel);
string geraCASELabelFIM(string looplabel);
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
void operacaoRelacional(atributos * dolar, atributos * dolar1, atributos * dolar2, atributos * dolar3);
void operacaoLogica(atributos * dolar, atributos * dolar1, atributos * dolar2, atributos * dolar3);
void traducaoOpAritmeticaIncDec(atributos* dolar, atributos* dolar1, atributos* dolar2);
void castTemp(atributos * dolar, atributos * dolar1, atributos* dolar2, atributos* dolar3, string tipo);
void iniciaEscopo();
void terminaEscopo();


//Declarações de variaveis globais
int numTmp = 0;
string declaraVariaveis="";
string declaraVariaveisGlobais="";
bool loopFor = false;
bool loopWhile = false;
//TABELA tabLabel;
map<string, string> tabTipos = criaTabTipoRetorno();
list<TABELA*> pilhaDeTabelas;
list<string> pilhaloopLabelsINICIO;
list<string> pilhaloopLabelsFIM;
list<string> pilhaIncremento;
list<string> pilhaDeSwitch;


%}

%token TK_NUM TK_REAL TK_VALOR_LOGICO TK_CHAR TK_STRING
%token TK_MAIN TK_ID TK_IF TK_ELSE TK_ELIF TK_SWITCH TK_CASE TK_DEFAULT
%token TK_FOR TK_WHILE TK_DO TK_BREAK TK_CONTINUE
%token TK_FIM TK_ERROR
%token TK_OPERADOR_LOGICO TK_OPERADOR_RELACIONAL TK_OPERADOR_MATEMATICO TK_ATRIBUICAO TK_OPERADOR_CREMENTO
%token TK_TIPO_INT TK_TIPO_CHAR TK_TIPO_FLOAT TK_TIPO_STRING TK_TIPO_BOOLEAN
%token TK_WRITE TK_READ

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
			| IF
			| WHILE
			| DO 
			| FOR 
			| BREAK
			| CONTINUE
			//| SWITCH
			//| CASES
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
			| TK_ID TK_OPERADOR_CREMENTO // E++ ou E--
			{
				traducaoOpAritmeticaIncDec(&$$, &$1, &$2);
			}
			| TK_OPERADOR_CREMENTO TK_ID // ++E ou --E
			{
				traducaoOpAritmeticaIncDec(&$$, &$2, &$1);
			};

////////////////////Inicio dos Desvios////////////////////
IF 			: TK_IF '(' E ')' BLOCO  // ta certo
			{
				$$.label = 	gerajumpLabel();
				$$.jumpLabel = geraCONDLabelINICIO($$.label);
				$$.gotojumpLabel = geraCONDLabelFIM($$.label);

				$$.traducao= "\n" + $3.traducao + 
							 "\n\t" + "if(!" + $3.tmp + ") goto " + $$.gotojumpLabel + ";\n" + 
							 $5.traducao + 
							 "\n\t" + $$.gotojumpLabel + ":\n";
			}
			| TK_IF '(' E ')' BLOCO ELSES // ta certo
			{	
				$$.label = 	gerajumpLabel();
				$$.jumpLabel = geraCONDLabelINICIO($$.label);
				$$.gotojumpLabel = geraCONDLabelFIM($$.label);

				$$.traducao= "\n" + $3.traducao + 
							 "\n\t" + "if(!" + $3.tmp + ") goto " + $6.jumpLabel + ";\n" + 
							 $5.traducao + 
							 "\tgoto " + $6.gotojumpLabel +";\n" +
							 $6.traducao + 
							 "\n\t" + $6.gotojumpLabel + ":\n";			 		
			}
			;
ELSES		: ELIF
			| ELSE
			;
ELSE 		: TK_ELSE BLOCO
			{
				
				$$.label = 	gerajumpLabel();
				$$.jumpLabel = geraCONDLabelINICIO($$.label);
				$$.gotojumpLabel = geraCONDLabelFIM($$.label);

				$$.traducao = "\n\t" + $$.jumpLabel + ":\n" + $2.traducao;

			}
			;
ELIF		: TK_ELIF '(' E ')' BLOCO
			{
				
				$$.label = 	gerajumpLabel();
				$$.jumpLabel = geraCONDLabelINICIO($$.label);
				$$.gotojumpLabel = geraCONDLabelFIM($$.label);


				$$.traducao = "\n\t" + $$.jumpLabel + ":\n" +
							  $3.traducao + 
							  "\n\tif(!" + $3.tmp + ") goto " + $$.gotojumpLabel + ";\n" + 
							  $5.traducao;
							 "\n\t" + $$.gotojumpLabel + ":\n";  
			}
			|TK_ELIF '(' E ')' BLOCO ELSES
			{
				
				$$.label = 	gerajumpLabel();
				$$.jumpLabel = geraCONDLabelINICIO($$.label);
				$$.gotojumpLabel = $6.gotojumpLabel;

				$$.traducao = "\n\t" + $$.jumpLabel + ":\n" +
							  $3.traducao + 
							  "\n\tif(!" + $3.tmp + ") goto " + $6.jumpLabel + ";\n" + 
							  $5.traducao + 
							  "\tgoto " + $$.gotojumpLabel + ";\n" 
							  + $6.traducao; 			  
			}
			;
////////////////////Fim dos Desvios////////////////////////	


////////////////////Inicio do FOR/////////////////////////	
FOR 		:FOR_C '(' DECLARACAO ';' E ';' ATRIBUICAO ')' BLOCO //ta certo
			{
				
				$$.loopLabel = $1.loopLabel;
				$$.jumpLabel = $1.jumpLabel;
				$$.gotojumpLabel = $1.gotojumpLabel;
				string labelInc = pilhaIncremento.front();

				$$.traducao= "\n" + $3.traducao + 
							 "\n\t" + $$.jumpLabel + ":\n" + $5.traducao +
							 "\n\tif(!" + $5.tmp + ") goto " + $$.gotojumpLabel + ";"
				             "\n" + $9.traducao + "\n" + 
				             "\t" + labelInc + ":" +
				 			 $7.traducao + "\tgoto " + $$.jumpLabel + ";\n" +
				 			 "\n\t" + $$.gotojumpLabel+ ":\n";

				pilhaloopLabelsINICIO.pop_front();
				pilhaloopLabelsFIM.pop_front();
				pilhaIncremento.pop_front();			 
				loopFor = false;
			}
			;
FOR_C		: TK_FOR
			{
				loopFor = true;
				//Gera a label referente ao Loop
				$$.loopLabel = gerajumpLabel();

				//Gera a label referente ao inicio do Loop
				$$.jumpLabel = geraLoopLabelINICIO($$.loopLabel);
				//Gera a label referente ao fim do Loop
				$$.gotojumpLabel = geraLoopLabelFIM($$.loopLabel);

				//Empilha as labels dos loops de inicio
				pilhaloopLabelsINICIO.push_front($$.jumpLabel);

				//Empilha as labels dos loops de fim
				pilhaloopLabelsFIM.push_front($$.gotojumpLabel);

				//Gerando e empilhando as labels de incremento
				string labelInc = gerajumpLabel();
				pilhaIncremento.push_front(labelInc);
			}			
////////////////////Fim do FOR////////////////////////////	


////////////////////Inicio do WHILE////////////////////////	
WHILE 		:WHILE_C '(' E ')' BLOCO // ta certo
			{	
				$$.loopLabel = $1.loopLabel;
				$$.jumpLabel = $1.jumpLabel;
				$$.gotojumpLabel = $1.gotojumpLabel;

				$$.traducao= "\n\t" + $$.jumpLabel + ":\n" + $3.traducao + 
							 "\n\tif(!" + $3.tmp + ")goto " + $$.gotojumpLabel + ";\n" + 
							 $5.traducao + 
							 "\n\tgoto " + $$.jumpLabel + ";\n"
							 + "\n\t" + $$.gotojumpLabel + ":\n";

				pilhaloopLabelsINICIO.pop_front();
				pilhaloopLabelsFIM.pop_front();
				
				if(loopFor)
				{
					loopFor = false;
					loopWhile = true;
				}				 
			}
			;
WHILE_C		: TK_WHILE
			{
				if(loopFor)
				{
					loopFor = false;
					loopWhile = true;
				}
				//Gera a label referente ao Loop
				$$.loopLabel = gerajumpLabel();
				//Gera a label referente ao inicio do Loop
				$$.jumpLabel = geraLoopLabelINICIO($$.loopLabel);
				//Gera a label referente ao fim do Loop
				$$.gotojumpLabel = geraLoopLabelFIM($$.loopLabel);
				//Empilha as labels dos loops de inicio
				pilhaloopLabelsINICIO.push_front($$.jumpLabel);
				//Empilha as labels dos loops de fim
				pilhaloopLabelsFIM.push_front($$.gotojumpLabel);

			}	
			;	
DO			: DO_C BLOCO TK_WHILE '(' E ')' ';' // ta certo
			{
				$$.loopLabel = $1.loopLabel;
				$$.jumpLabel = $1.jumpLabel;
				$$.gotojumpLabel = $1.gotojumpLabel;

				$$.traducao = "\n\t" + $$.jumpLabel + ":" + 
							 $2.traducao + "\n" + $5.traducao + 
							 "\n\tif(" + $5.tmp + ")goto " + $$.gotojumpLabel + ";\n" +
							 "\tgoto " + $$.jumpLabel + ";\n" +
							 "\n\t" + $$.gotojumpLabel + ":\n";


				pilhaloopLabelsINICIO.pop_front();
				pilhaloopLabelsFIM.pop_front();
				
				if(loopFor)
				{
					loopFor = false;
					loopWhile = true;
				}	
			}
DO_C		: TK_DO
			{
				if(loopFor)
				{
					loopFor = false;
					loopWhile = true;
				}
				//Gera a label referente ao Loop
				$$.loopLabel = gerajumpLabel();

				//Gera a label referente ao inicio do Loop
				$$.jumpLabel = geraLoopLabelINICIO($$.loopLabel);
				//Gera a label referente ao fim do Loop
				$$.gotojumpLabel = geraLoopLabelFIM($$.loopLabel);

				//Empilha as labels dos loops de inicio
				pilhaloopLabelsINICIO.push_front($$.jumpLabel);

				//Empilha as labels dos loops de fim
				pilhaloopLabelsFIM.push_front($$.gotojumpLabel);
			}			
			;
////////////////////Fim do WHILE//////////////////////////	


////////////////////Inicio do SWITCH////////////////////////
/*SWITCH		: SWITCH_C '(' ID_C ')' '{' CASES '}'
			{
				$$.loopLabel = $1.loopLabel;
				$$.jumpLabel = $1.jumpLabel;
				$$.gotojumpLabel = $1.gotojumpLabel;



				$$.traducao = "\n\t" + $$.loopLabel + "\n" +
							  $6.traducao +
							  "\n\t goto " + $$.gotojumpLabel + ";\n";	
			}
			;

SWITCH_C	: TK_SWITCH
			{

				$$.loopLabel = gerajumpLabel();
				//Gera a label referente ao inicio do Loop
				$$.jumpLabel = geraCASELabelINICIO($$.loopLabel);
				//Gera a label referente ao fim do Loop
				$$.gotojumpLabel = geraCASELabelFIM($$.loopLabel);
				//Empilha as labels dos loops de inicio
				pilhaloopLabelsINICIO.push_front($$.jumpLabel);
				//Empilha as labels dos loops de fim
				pilhaloopLabelsFIM.push_front($$.gotojumpLabel);


			};	
ID_C		: TK_ID
			{
				
				TABELA * map = existeID($1.label);

				if(map == NULL)
				{
					yyerror("Variavel " + $1.label + " nao declarada!");
				}	
				else
				{
					pilhaDeSwitch.push_front($1.label);

					$$.label =  $1.label;
					$$.tmp =  $1.tmp;
					$$.tipo =  $1.tipo;

				}
				
			}
			;
CASES		: CASE CASES
			{

				$$.traducao = $1.traducao + $2.traducao;
			}
			| DEFAULT
			;

CASE 		: CASE_C VALOR ':' COMANDOS
			{
				
				string label = pilhaDeSwitch.front();
				TABELA * map = existeID(label);

				if(map == NULL)
				{
					yyerror("Variavel " + label + " nao declarada!");
				}	
				else
				{	

					$$.label = 	$1.label;
					$$.jumpLabel = $1.jumpLabel;
					$$.gotojumpLabel = $1.gotojumpLabel;

					atributos dolarOp;
					atributos dolarTr;

					dolarOp.operador = "==";

					operacaoLogica(&dolarTr, &$2, &dolarOp, &(*map)[label]);

					$$.traducao= "\n\t" + $2.traducao +
								 "\n\t" + $$.jumpLabel + ":\n" +
								 dolarTr.traducao + "\n" +	
								 "\n\t" + "if(!" + dolarTr.tmp + ") goto " + $$.gotojumpLabel + ";\n" + 
								 $4.traducao + 
								 "\tgoto " + $$.gotojumpLabel +";\n" +
								 "\n\t" + $$.gotojumpLabel + ":\n";
				}
			}
			;
CASE_C		: TK_CASE
			{

				$$.label = 	gerajumpLabel();
				$$.jumpLabel = geraCASELabelINICIO($$.label);
				$$.gotojumpLabel = geraCASELabelFIM($$.label);

			}
			;
DEFAULT		: TK_DEFAULT ':' COMANDOS
			{
				$$.label = 	gerajumpLabel();
				$$.jumpLabel = geraCASELabelINICIO($$.label);
				$$.gotojumpLabel = geraCASELabelFIM($$.label);

				$$.traducao= 
							 "\n\t" + $$.jumpLabel + ":\n" +
							 $3.traducao + 
							 "\tgoto " + $$.gotojumpLabel +";\n" +
							 "\n\t" + $$.gotojumpLabel + ":\n";
			}	
			;												*/

////////////////////Fim do SWITCH////////////////////////
BREAK 		: TK_BREAK ';'
			{
				//Verificar se realmente deve fazer um break que sai de todos os loops em execução
				string lInc = pilhaloopLabelsFIM.back();
				$$.traducao = "\tgoto " + lInc + ";\n";
				
			}
			;

CONTINUE 	: TK_CONTINUE ';'
			{
				string loopLabel;

				if(loopFor)
				{
					loopLabel = pilhaIncremento.front();
				}
				else
				{
					loopLabel = pilhaloopLabelsINICIO.front();
				}

				$$.traducao = "\tgoto " + loopLabel + ";\n";
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
				
			}
			|E TK_OPERADOR_RELACIONAL E //Refazer esse operador
			{
				operacaoRelacional(&$$, &$1, &$2, &$3);	
			}	
			|E TK_OPERADOR_LOGICO E //Refazer esse operador
			{
				operacaoLogica(&$$, &$1, &$2, &$3);	
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
			| TK_STRING
			{
				processaTK_VALOR(&$$, &$1, "string");
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

string geraTemp(string tipo, int ehGlobal)
{

		//static int i = 0;
	 stringstream ss;

	 ss << "temp" << numTmp++;
	 
	 if(tipo == "string")
	 {
	 	tipo = "char";
		if(ehGlobal == 1)
		{
			declaraVariaveisGlobais += tipo + " * " + ss.str() + ";\n";
		}
		else
		{	
			declaraVariaveis += "\t" + tipo + " * " + ss.str() + ";\n";
		}
	 }
	 else
	 {
	 	if(ehGlobal == 1)
		{
			declaraVariaveisGlobais += tipo + " " + ss.str() + ";\n";
		}
		else
		{	
			declaraVariaveis += "\t" + tipo + " " + ss.str() + ";\n";
		}
	 }
		return ss.str();
		
}

string geraTempString(int tamanho, int ehGlobal){

	stringstream ss, sv;

	ss << "temp" << numTmp++;
	sv << "[" << tamanho << "]";

 	string tipo = "char";

	if(ehGlobal == 1)
	{
		declaraVariaveisGlobais += tipo + " " + ss.str() + sv.str() + ";\n";
	}
	else
	{	
		declaraVariaveis += "\t" + tipo + " " +  ss.str() + sv.str() + ";\n";
	}
	
	return ss.str();

}

string gerajumpLabel()
{
	static int ll = 0;
	stringstream ss;

	ss << "LABEL" << ll++;
	
	return ss.str();	
}			
string geraCONDLabelINICIO(string looplabel)
{
	stringstream ss;

	ss << "INICIO_COND_" << looplabel;

	return ss.str();
}

string geraCONDLabelFIM(string looplabel)
{
	stringstream ss;

	ss << "FIM_COND_" << looplabel;

	return ss.str();
}
string geraLoopLabelINICIO(string looplabel)
{
	stringstream ss;

	ss << "INICIO_LOOP_" << looplabel;

	return ss.str();
}

string geraLoopLabelFIM(string looplabel)
{
	stringstream ss;

	ss << "FIM_LOOP_" << looplabel;

	return ss.str();
}

string geraCASELabelINICIO(string looplabel)
{
	stringstream ss;

	ss << "INICIO_CASE_" << looplabel;

	return ss.str();
}

string geraCASELabelFIM(string looplabel)
{
	stringstream ss;

	ss << "FIM_CASE_" << looplabel;

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

	int tamanho = (*tab2)[dolar3->label].tamanhoString;

	//Verificando tipo para ver a necessidade de cast
	if((*tab1)[dolar1->label].tipo != (*tab2)[dolar3->label].tipo)
	{	
		if((*tab1)[dolar1->label].tipo == "string")
		{
			string tipo = getTipo((*tab1)[dolar1->label].tipo + dolar2->operador + (*tab2)[dolar3->label].tipo);

			dolar->tmp = geraTempString(tamanho, LOCAL);
			dolar->tamanhoString = tamanho;

			(*tab1)[dolar1->label].tmp = dolar->tmp;
			(*tab1)[dolar1->label].tamanhoString = dolar->tamanhoString;

			dolar->traducao = dolar1->traducao + dolar3->traducao + "\tstrcpy(" + dolar->tmp + " , " + (*tab2)[dolar3->label].tmp + ");\n";

		}
		else
		{
			string tipo = getTipo((*tab1)[dolar1->label].tipo + dolar2->operador + (*tab2)[dolar3->label].tipo);
		
			dolar->traducao = dolar1->traducao + dolar3->traducao + "\t" + (*tab1)[dolar1->label].tmp + " = " + "(" + tipo + ") " + (*tab2)[dolar3->label].tmp + ";\n";
		}
	}	
	else
	{
		if((*tab1)[dolar1->label].tipo == "string")
		{
			
			dolar->tmp = geraTempString(tamanho, LOCAL);
			dolar->tamanhoString = tamanho;

			(*tab1)[dolar1->label].tmp = dolar->tmp;
			(*tab1)[dolar1->label].tamanhoString = dolar->tamanhoString;

			dolar->traducao = dolar1->traducao + dolar3->traducao + "\tstrcpy(" + dolar->tmp + " , " + (*tab2)[dolar3->label].tmp + ");\n";

		}
		else
		{
			dolar->traducao = dolar1->traducao + dolar3->traducao  + "\t" + (*tab1)[dolar1->label].tmp + " = " + (*tab2)[dolar3->label].tmp + ";\n";
		}
	}
}

void processaDECLARACAO(atributos * dolar, atributos * dolar1, atributos * dolar2, atributos * dolar3, atributos * dolar4, int ehGlobal)
{
	TABELA * tab = pilhaDeTabelas.front();
	int tamanho = dolar2->tamanhoString + dolar4->tamanhoString;
	//Verificando tipo para ver a necessidade de cast
	if(dolar1->tipo != dolar4->tipo)
	{			

		if(dolar1->tipo == "string")
		{
			
			string tipo = getTipo(dolar1->tipo + dolar3->operador + dolar4->tipo);

			dolar->tmp = geraTempString(tamanho, ehGlobal);
			dolar->label = dolar2->label;
			dolar->tipo = dolar1->tipo;
			dolar->valor = dolar4->valor;
			dolar->tamanhoString = tamanho;

			(*tab)[dolar2->label].tmp = dolar->tmp;
			(*tab)[dolar2->label].tipo = dolar->tipo;
			(*tab)[dolar2->label].label = dolar->label;
			(*tab)[dolar2->label].valor = dolar->valor;
			(*tab)[dolar2->label].tamanhoString = dolar->tamanhoString;

			//Precisa verificar a necessidade d

			dolar->traducao =  dolar4->traducao + 
							   "\tstrcpy(" + dolar->tmp + ", " + dolar4->tmp +");\n";
		}
		else
		{
			string tipo = getTipo(dolar1->tipo + dolar3->operador + dolar4->tipo);

			dolar->tmp = geraTemp(tipo, ehGlobal);
			dolar->label = dolar2->label;
			dolar->tipo = dolar1->tipo;
			dolar->valor = dolar4->valor;
			dolar->tamanhoString = tamanho;
			
			(*tab)[dolar2->label].tmp =  dolar->tmp;
			(*tab)[dolar2->label].tipo = dolar->tipo;
			(*tab)[dolar2->label].label = dolar->label;
			(*tab)[dolar2->label].valor = dolar->valor;
			(*tab)[dolar2->label].tamanhoString = dolar->tamanhoString;

			dolar->traducao = dolar4->traducao + "\t" + (*tab)[dolar2->label].tmp + " = " + "(" + tipo + ") " + dolar4->tmp + ";\n";
		}
	}	
	else
	{
		if(dolar1->tipo == "string")
		{
			string tipo = getTipo(dolar1->tipo + dolar3->operador + dolar4->tipo);

			dolar->tmp = geraTempString(tamanho, ehGlobal);
			dolar->label = dolar2->label;
			dolar->tipo = dolar1->tipo;
			dolar->valor = dolar4->valor;
			dolar->tamanhoString = tamanho;

			(*tab)[dolar2->label].tmp = dolar->tmp;
			(*tab)[dolar2->label].tipo = dolar->tipo;
			(*tab)[dolar2->label].label = dolar->label;
			(*tab)[dolar2->label].valor = dolar->valor;
			(*tab)[dolar2->label].tamanhoString = dolar->tamanhoString;

			dolar->traducao =  dolar4->traducao + 
							   "\tstrcpy(" + dolar->tmp + " , " + dolar4->tmp +");\n";
		}
		else
		{	
			
			dolar->tmp = geraTemp(dolar1->tipo, ehGlobal);
			dolar->label = dolar2->label;
			dolar->tipo = dolar1->tipo;
			dolar->tamanhoString = tamanho;
	
			(*tab)[dolar2->label].tmp =  dolar->tmp;
			(*tab)[dolar2->label].tipo = dolar->tipo;
			(*tab)[dolar2->label].label = dolar->label;
			(*tab)[dolar2->label].tamanhoString = dolar->tamanhoString;

			dolar->traducao = dolar4->traducao  + "\t" + (*tab)[dolar2->label].tmp + " = " + dolar4->tmp + ";\n";
		}
	}
}

void processaTK_ID(atributos * dolar, atributos * dolar1, atributos * dolar2, int ehGlobal)
{
	TABELA * tab = pilhaDeTabelas.front();
	int tamanho = dolar2->tamanhoString + 1;

	if(dolar1->tipo == "string")
	{
		dolar->tmp = geraTempString(tamanho,ehGlobal);
		dolar->label = dolar2->label;
		dolar->tipo = dolar1->tipo;
		dolar->tamanhoString = tamanho;

		(*tab)[dolar2->label].tmp = dolar->tmp;
		(*tab)[dolar2->label].tipo = dolar->tipo;
		(*tab)[dolar2->label].label = dolar->label;
		(*tab)[dolar2->label].tamanhoString = dolar->tamanhoString;

	}
	else
	{
		dolar->tmp = geraTemp(dolar1->tipo, ehGlobal);
		dolar->label = dolar2->label;
		dolar->tipo = dolar1->tipo;
		dolar->tamanhoString = tamanho;

		(*tab)[dolar2->label].tmp = dolar->tmp;
		(*tab)[dolar2->label].tipo = dolar->tipo;
		(*tab)[dolar2->label].label = dolar->label;
		(*tab)[dolar2->label].tamanhoString = dolar->tamanhoString;
	}
		
	
	dolar->traducao = "";
}

void processaTK_VALOR(atributos * dolar, atributos * dolar1, string)
{
	TABELA * tab = pilhaDeTabelas.front();
	int tamanho = dolar1->valor.size() + 1;

	if (dolar1->tipo == "string")
	{
		
		dolar->tmp = geraTempString(tamanho, LOCAL);;
		dolar->label = dolar->tmp;
		dolar->tipo = dolar1->tipo;
		dolar->valor = dolar1->valor;
		dolar->tamanhoString = tamanho;
		dolar->traducao = "\tstrcpy(" + dolar->tmp  + " , " + dolar1->valor + ");\n";
	
		(*tab)[dolar->label].tmp =  dolar->tmp;
		(*tab)[dolar->label].label = dolar->label;
		(*tab)[dolar->label].tipo = dolar->tipo;
		(*tab)[dolar->label].valor = dolar->valor;
		(*tab)[dolar->label].tamanhoString = dolar->tamanhoString;

	}
	else
	{
		dolar->tmp = geraTemp(dolar->tipo, LOCAL);;
		dolar->label = dolar->tmp;
		dolar->tipo = dolar->tipo;
		dolar->valor = dolar1->valor;
		dolar->tamanhoString = tamanho;
		dolar->traducao = "\t" + dolar->tmp  + " = " + dolar1->valor + ";\n";
	
		(*tab)[dolar->label].tmp =  dolar->tmp;
		(*tab)[dolar->label].label = dolar->label;
		(*tab)[dolar->label].tipo = dolar->tipo;
		(*tab)[dolar->label].valor = dolar->valor;
		(*tab)[dolar->label].tamanhoString = dolar->tamanhoString;

	}
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

void operacaoRelacional(atributos * dolar, atributos * dolar1, atributos * dolar2, atributos * dolar3)
{
	TABELA * tab = pilhaDeTabelas.front();
	string tipo;

	if(dolar1->tipo != dolar3->tipo)
	{
		string tipo = getTipo(dolar1->tipo +  dolar2->operador + dolar3->tipo);
		dolar->tmp = geraTemp(tipo, LOCAL);
		dolar->tipo = tipo;	
		dolar->traducao = dolar1->traducao + dolar3->traducao + "\t" + dolar->tmp + " = " + dolar1->tmp + " " + dolar2->operador + " "+ dolar3->tmp + ";\n";
	}	
	else
	{
		dolar->tmp = geraTemp(dolar1->tipo, LOCAL);
		dolar->tipo = tipo;	
		dolar->traducao = dolar1->traducao + dolar3->traducao + "\t" + dolar->tmp + " = " + dolar1->tmp + " " + dolar2->operador + " " + dolar3->tmp + ";\n";	

	}
}

void operacaoLogica(atributos * dolar, atributos * dolar1, atributos * dolar2, atributos * dolar3)
{
	TABELA * tab = pilhaDeTabelas.front();
	string tipo;
	//Verificando se há necessidade de fazer cast. Caso sim, decidir o tipo da nova variavel temporaria para o cast
	if(dolar1->tipo != dolar3->tipo)
	{
		string tipo = getTipo(dolar1->tipo +  dolar2->operador + dolar3->tipo);
		dolar->tmp = geraTemp(tipo, LOCAL);
		dolar->tipo = tipo;	
		dolar->traducao = dolar1->traducao + dolar3->traducao + "\t" + dolar->tmp + " = " + dolar1->tmp + " " + dolar2->operador + " "+ dolar3->tmp + ";\n";
	}	
	else
	{
		dolar->tmp = geraTemp(dolar1->tipo, LOCAL);
		dolar->tipo = tipo;	
		dolar->traducao = dolar1->traducao + dolar3->traducao + "\t" + dolar->tmp + " = " + dolar1->tmp + " " + dolar2->operador + " " + dolar3->tmp + ";\n";	

	}
}

void traducaoOpAritmeticaIncDec(atributos* dolar, atributos* dolar1,atributos* dolar2)
{	
		TABELA * tab = existeID(dolar1->label);

		if(tab == NULL)
		{
			yyerror( "Variavel " + dolar1->label + " nao declarada!");
		}
		
		dolar->tmp = geraTemp((*tab)[dolar1->label].tipo, LOCAL);
		dolar->tipo = (*tab)[dolar1->label].tipo;	
		dolar->traducao = "\n\t" + dolar->tmp + " = " + "1;\n";
		dolar2->valor = 1;	
	
		if (dolar2->operador == "++")
		{ 	
			dolar->traducao += "\t" + (*tab)[dolar1->label].tmp + " = " + (*tab)[dolar1->label].tmp + " + " + dolar->tmp + ";\n";
		}
		else if (dolar2->operador == "--")
		{
			dolar->traducao += "\t" + (*tab)[dolar1->label].tmp + " = " + (*tab)[dolar1->label].tmp + " - " + dolar->tmp + ";\n";
		}
		else
		{
			yyerror( "Variavel " + dolar2->operador + " em formato incorreto !");
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
