%{
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <string>
#include <sstream>
#include <map>
#include <iterator>
#include <list>
#include <vector>

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
	string valor;
	string tipo;
	string operador;
	int tamanhoString;
	string variaveisDoContexto;
	int inicializada;
	string argumentos;
	int quantidadeArgumentos;
	string tiposArgumentos;
	bool ehFuncao;
	bool implementada;
	bool temRetorno;
	bool ehParam;
	bool ehVetor;
	string tamanhoVetor;

};
typedef struct atributos atributos;
typedef map<string , atributos> TABELA;
typedef map<string , atributos>::iterator ITERATOR;

#define TRUE 1
#define FALSE 0

//Declarações de protótipos de funções
int yylex(void);
void yyerror(string);
string geraTemp(void);
string gerajumpLabel();
string geraCONDLabelINICIO(string looplabel);
string geraCONDLabelFIM(string looplabel);
string geraLoopLabelINICIO(string looplabel);
string geraLoopLabelFIM(string looplabel);
string geraLabelFuncao();
void estaInicializada(atributos * var);
TABELA *  existeID(string label);
void iniciaContexto();
void terminaContexto();
string declaraVariaveis();
string declaraVariaveisGlobais();
bool pertenceContextoAtual(string label);
void processaOperacaoAritmetica(atributos * d, atributos * d1, atributos * d2, atributos * d3);
void processaDeclaracao(atributos * d, atributos * d1, atributos * d2, atributos * d3, atributos * d4);
void processaTK_ID(atributos * d, atributos * d1, atributos * d2);
void processaAtribuicao(atributos * d, atributos * d1, atributos * d2, atributos * d3);
void processaDeclaracaoString(atributos * d, atributos * d1, atributos * d2, atributos * d3, atributos * d4);
void processaOperacaoAritmeticaString(atributos * d, atributos * d1, atributos * d2, atributos * d3);
void traducaoOpAritmeticaIncDec(atributos* d, atributos* d1, atributos* d2);
void castCharToString(atributos * d, atributos * d1);
void castTemp(atributos * d, atributos * d1, atributos* d2, atributos* d3,  string tipo);
void processaTK_VALOR(atributos * d, atributos * d1, string tipo);
int contaCHAR(char caractere, string texto);
string removeAspas(string text);
string getTipo(string operacao);


map<string, string> criaTabTipoRetorno();


//Declarações de variaveis globais
bool loopFor = false;
bool loopWhile = false;
TABELA vardescartadas;
map<string, string> tabTipos = criaTabTipoRetorno();
list<TABELA*> pilhaDeTabelas;

list<string> pilhaloopLabelsINICIO;
list<string> pilhaloopLabelsFIM;
list<string> pilhaIncremento;

list<string> labelsDeAbertura;
list<string> labelsDeFechamento;
list<string> caseLabel;
list<string> caseLabelTemp;
list<string> caseTraducao;


static int numTmp = 0;

%}

%token TK_NUM TK_REAL TK_VALOR_LOGICO TK_CHAR TK_STRING
%token TK_MAIN TK_ID TK_RETURN
%token TK_IF TK_ELSE TK_ELIF TK_SWITCH TK_CASE TK_DEFAULT
%token TK_FOR TK_WHILE TK_DO TK_OPERADOR_CREMENTO TK_BREAK TK_ALL TK_CONTINUE
%token TK_FIM TK_ERROR
%token TK_OPERADOR_LOGICO TK_OPERADOR_RELACIONAL TK_OPERADOR_ARITMETICO TK_ATRIBUICAO TK_DOIS_PONTOS
%token TK_TIPO_INT TK_TIPO_CHAR TK_TIPO_FLOAT TK_TIPO_STRING TK_TIPO_BOOLEAN TK_TIPO_VOID
%token TK_WRITE TK_READ
%token TK_VET_ID TK_TAMANHO_VET

%start START

%left '+' '-'
%left '*' '/' "||" 
%left '{'
%left '('
%nonassoc '='	


%%


START 		: CONTEXTO_GLOBAL S
			{
				cout << "/*Compilador snap*/\n" <<
				        "#include <iostream>\n" <<
				        "#include <string>\n" <<
				        "#include <string.h>\n" <<
				        "#include <stdio.h>\n"  <<
				        "using namespace std;\n";

				cout << $2.traducao << endl;       
			}
			;

S 			:DECL_GLOBAL ';' MAIN
			{
				$$.traducao = "\n" + declaraVariaveisGlobais() +
							  "\n" + $3.tipo + " main(void)\n{\n" +
							  $3.variaveisDoContexto + "\n" +
						      $1.traducao + "\n" +
							  $3.traducao + "\n" +
							  "\treturn 0;\n}";
			} 
			|DECL_GLOBAL ';' FUNCOES MAIN
			{
				$$.traducao = "\n" + declaraVariaveisGlobais()+
							"\n" + $3.traducao +
							"\n\n" + $4.tipo + " main(void)\n{\n" +
							$4.variaveisDoContexto + "\n" +
							$1.traducao + "\n" +
							$4.traducao + "\n" +
							"\treturn 0;\n}";
			}
			|FUNCOES MAIN
			{
				$$.traducao = "\n" + $1.traducao +
							  "\n" + $2.tipo + " main(void)\n{\n" +
							  $2.variaveisDoContexto + "\n" +
							  $2.traducao + "\n" +
							  "\treturn 0;\n}";
			}
			|MAIN
			{
				$$.traducao = "\n" + $1.tipo + " main(void)\n{\n" + 
				              $1.variaveisDoContexto + "\n" 
				              + $1.traducao + "\t"+
				              "return 0;\n}";        
			}
			;
MAIN        : TK_TIPO_INT TK_MAIN '(' ')' INI_CONTEXTO BLOCO FIM_CONTEXTO
			{
				
				$$.traducao = $6.traducao;
				$$.tipo = $1.tipo;
				$$.variaveisDoContexto = $7.variaveisDoContexto;
			}
			;

CONTEXTO_GLOBAL :
			{
				iniciaContexto();
			}
///////////////Inicio Declaração Global///////////////////////
DECL_GLOBAL : DECL_G
			{
				$$.traducao = $1.traducao;
			}
			|DECL_G DECL_GLOBAL ';'
			{
				$$.traducao = $1.traducao + $2.traducao;
			}
			;
DECL_G 		:TIPO TK_ID TK_ATRIBUICAO VALOR
			{
				processaDeclaracao(&$$, &$1, &$2, &$3, &$4);
			}
			|TIPO TK_ID
			{
				processaTK_ID(&$$, &$1, &$2);
			}
			|VALOR
			;		
///////////////Fim Declaração Global///////////////////////			
INI_CONTEXTO: '{'
			{
				iniciaContexto();
			}
FIM_CONTEXTO: '}'
			{	
				$$.variaveisDoContexto = declaraVariaveis();
				terminaContexto();
				
			}			
			;
BLOCO		: COMANDOS
			{
				$$.traducao = $1.traducao;
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
			|
			{
				$$.traducao = "";
			}
			;

COMANDO 	: DECLARACAO ';'
			| ATRIBUICAO ';'
			| COUT ';'
			| CIN ';'
			| IF
			| FOR
			| BREAK
			| CONTINUE
			| WHILE
			| DO
			| CHAMADA_FUNCAO ';'
			| RETURN ';'
			| SWITCH
			;

DECLARACAO	:|TIPO TK_ID TK_ATRIBUICAO E
			{
				processaDeclaracao(&$$, &$1, &$2, &$3, &$4);
			} 
			|TIPO TK_ID
			{
				processaTK_ID(&$$, &$1, &$2);
			}
			| TIPO TK_ID TK_TAMANHO_VET
			{
				TABELA * tab = pilhaDeTabelas.front();
				stringstream arg;

				if($1.tipo == "string")
				{

					$$.tmp = geraTemp();
					$$.label = $2.label;
					$$.tipo = $1.tipo;
					$$.tamanhoVetor = "[1024]";
					$$.ehFuncao = 0;
					$$.inicializada = 0;
					$$.ehVetor = TRUE;
					arg << "char " << $$.tmp << '[' <<$$.tamanhoVetor << ']';
					$$.argumentos = arg.str();

					(*tab)[$$.label].label = $$.label;
					(*tab)[$$.label].tmp = $$.tmp;
					(*tab)[$$.label].tipo = $$.tipo;
					(*tab)[$$.label].tamanhoVetor = $$.tamanhoVetor;
					(*tab)[$$.label].ehFuncao = $$.ehFuncao;
					(*tab)[$$.label].inicializada = $$.inicializada;
					(*tab)[$$.label].ehVetor = $$.ehVetor;
					(*tab)[$$.label].argumentos = $$.argumentos;
				}
				else
				{

					$$.tmp = geraTemp();
					$$.label = $2.label;
					$$.tipo = $1.tipo;
					$$.tamanhoVetor = $3.tamanhoVetor;
					$$.ehFuncao = 0;
					$$.inicializada = 0;
					$$.ehVetor = TRUE;
					$$.argumentos = $$.tipo + " " + $$.tmp + $$.tamanhoVetor;

					(*tab)[$$.label].label = $$.label;
					(*tab)[$$.label].tmp = $$.tmp;
					(*tab)[$$.label].tipo = $$.tipo;
					(*tab)[$$.label].tamanhoVetor = $$.tamanhoVetor;
					(*tab)[$$.label].ehFuncao = $$.ehFuncao;
					(*tab)[$$.label].inicializada = $$.inicializada;
					(*tab)[$$.label].ehVetor = $$.ehVetor;
					(*tab)[$$.label].argumentos = $$.argumentos;
				}
			}
			;

ATRIBUICAO	: TK_ID TK_ATRIBUICAO E
			{
				processaAtribuicao(&$$, &$1, &$2, &$3);
			}
			| TK_ID TK_ATRIBUICAO CHAMADA_FUNCAO
			{
				processaAtribuicao(&$$, &$1, &$2, &$3);	
			}
			| TK_ID TK_OPERADOR_CREMENTO // E++ ou E--
			{
				
				traducaoOpAritmeticaIncDec(&$$, &$1, &$2);
			}
			| TK_OPERADOR_CREMENTO TK_ID // ++E ou --E
			{
				traducaoOpAritmeticaIncDec(&$$, &$2, &$1);
			}
			;

////////////////////Inicio IO///////////////////////////////////////
COUT 		: TK_WRITE '(' E ')'	
			{
				$$.traducao = $3.traducao + "\tcout << " + $3.tmp + "<< endl;\n";
			}	
			;
CIN 		: TK_READ '(' TK_ID ')'

			{
				TABELA* tab = existeID($3.label);

				if(tab == NULL)
					yyerror("Variável " + $3.label + " não declarada.");

				$$.traducao = "\tcin >> " + (*tab)[$3.label].tmp + ";\n";
            			
    			if((*tab)[$3.label].tipo == "string"){
    				(*tab)[$3.label].tamanhoString = 1024;
    			}
			}			
            ;
////////////////////Inicio IO///////////////////////////////////////

////////////////////Inicio dos Desvios////////////////////
IF 			: TK_IF '(' E ')' '{' BLOCO '}'// ta certo
			{
				$$.label = 	gerajumpLabel();
				$$.jumpLabel = geraCONDLabelINICIO($$.label);
				$$.gotojumpLabel = geraCONDLabelFIM($$.label);

				$$.traducao= "\n" + $3.traducao + 
							 "\n\t" + "if(!" + $3.tmp + ") goto " + $$.gotojumpLabel + ";\n" + 
							 $6.traducao + 
							 "\n\t" + $$.gotojumpLabel + ":\n";
			}
			| TK_IF '(' E ')' '{' BLOCO '}' ELSES // ta certo
			{	
				$$.label = 	gerajumpLabel();
				$$.jumpLabel = geraCONDLabelINICIO($$.label);
				$$.gotojumpLabel = geraCONDLabelFIM($$.label);

				$$.traducao= "\n" + $3.traducao + 
							 "\n\t" + "if(!" + $3.tmp + ") goto " + $8.jumpLabel + ";\n" + 
							 $6.traducao + 
							 "\tgoto " + $8.gotojumpLabel +";\n" +
							 $8.traducao + 
							 "\n\t" + $8.gotojumpLabel + ":\n";			 		
			}
			;
ELSES		: ELIF
			| ELSE
			;
ELSE 		: TK_ELSE '{' BLOCO '}'
			{
				
				$$.label = 	gerajumpLabel();
				$$.jumpLabel = geraCONDLabelINICIO($$.label);
				$$.gotojumpLabel = geraCONDLabelFIM($$.label);

				$$.traducao = "\n\t" + $$.jumpLabel + ":\n" + $3.traducao;

			}
			;
ELIF		: TK_ELIF '(' E ')' '{' BLOCO '}'
			{
				
				$$.label = 	gerajumpLabel();
				$$.jumpLabel = geraCONDLabelINICIO($$.label);
				$$.gotojumpLabel = geraCONDLabelFIM($$.label);


				$$.traducao = "\n\t" + $$.jumpLabel + ":\n" +
							  $3.traducao + 
							  "\n\tif(!" + $3.tmp + ") goto " + $$.gotojumpLabel + ";\n" + 
							  $6.traducao;
							 "\n\t" + $$.gotojumpLabel + ":\n";  
			}
			|TK_ELIF '(' E ')' '{' BLOCO '}' ELSES
			{
				
				$$.label = 	gerajumpLabel();
				$$.jumpLabel = geraCONDLabelINICIO($$.label);
				$$.gotojumpLabel = $8.gotojumpLabel;

				$$.traducao = "\n\t" + $$.jumpLabel + ":\n" +
							  $3.traducao + 
							  "\n\tif(!" + $3.tmp + ") goto " + $8.jumpLabel + ";\n" + 
							  $6.traducao + 
							  "\tgoto " + $$.gotojumpLabel + ";\n" 
							  + $8.traducao; 			  
			}
			;


SWITCH		: SWITCH_C '(' E ')' '{' CASES '}'
			{

				list<string>::iterator i;
				$$.traducao = "";
	
				for(i = caseLabel.begin(); i != caseLabel.end(); i++)
				{
					$$.traducao += caseTraducao.front() + "\t" + caseLabelTemp.front() + " = (" + $3.tmp + " ==" + *i + ");\n";
					caseLabelTemp.pop_front();
					caseTraducao.pop_front();
				}


				
				
				$$.traducao += "\n\n" + $6.traducao + "\n\n\t" + pilhaloopLabelsFIM.front() + ":\n";
				pilhaloopLabelsINICIO.pop_front();
				pilhaloopLabelsFIM.pop_front();
			}
			;

SWITCH_C	: TK_SWITCH
			{
				string blocoIf = gerajumpLabel();
			    pilhaloopLabelsINICIO.push_front(blocoIf);
			    string blocoElse = gerajumpLabel();
			    pilhaloopLabelsFIM.push_front(blocoElse);
			}
			;

CASES		: CASE CASES
			{
				$$.traducao = $1.traducao + "\n" + $2.traducao;
			}
			| CASE
			{
				$$.traducao = $1.traducao;
			}
			| DEFAULT
			{
				$$.traducao = $1.traducao;
			}
			;

CASE		: CASE_C E TK_DOIS_PONTOS COMANDOS
			{

				$$.traducao = "";
	
				TABELA * mapa = pilhaDeTabelas.front();
				
				string label = geraTemp();
	
				(*mapa)[label].tmp = label;
				(*mapa)[label].label = label;
				(*mapa)[label].tipo = "int";
				caseLabelTemp.push_front(label);
	
				caseLabel.push_front($2.label);

				caseTraducao.push_front($2.traducao);
					
			
				$$.traducao += "\n\tif (!" + caseLabelTemp.front() +") goto " + pilhaloopLabelsFIM.front() + ";\n\n" + 		$4.traducao + "\n\n\t" + pilhaloopLabelsFIM.front() + ":\n";
				pilhaloopLabelsINICIO.pop_front();
				pilhaloopLabelsFIM.pop_front();
			}
			;

DEFAULT 	: TK_DEFAULT TK_DOIS_PONTOS COMANDOS
			{
				$$.traducao = $3.traducao;
			}
			;

CASE_C		: TK_CASE
			{
				string blocoIf = gerajumpLabel();
			    pilhaloopLabelsINICIO.push_front(blocoIf);
			    string blocoElse = gerajumpLabel();
			    pilhaloopLabelsFIM.push_front(blocoElse);
			}
			;

////////////////////Fim dos Desvios////////////////////////	

////////////////////Inicio do FOR/////////////////////////	
FOR 		:FOR_C '(' DECLARACAO ';' E ';' ATRIBUICAO ')' '{' BLOCO '}'//ta certo
			{
				string variaveisDoContexto = declaraVariaveis();
				$$.loopLabel = $1.loopLabel;
				$$.jumpLabel = $1.jumpLabel;
				$$.gotojumpLabel = $1.gotojumpLabel;
				string labelInc = pilhaIncremento.front();

				$$.traducao= "\n" + variaveisDoContexto + "\n" + $3.traducao + 
							 "\n\t" + $$.jumpLabel + ":\n" + $5.traducao +
							 "\n\tif(!" + $5.tmp + ") goto " + $$.gotojumpLabel + ";"
				             "\n" + $10.traducao + "\n" + 
				             "\t" + labelInc + ":" +
				 			 $7.traducao + "\tgoto " + $$.jumpLabel + ";\n" +
				 			 "\n\t" + $$.gotojumpLabel+ ":\n";

				pilhaloopLabelsINICIO.pop_front();
				pilhaloopLabelsFIM.pop_front();
				pilhaIncremento.pop_front();			 
				loopFor = false;

				terminaContexto();
			}
			;
FOR_C		: TK_FOR
			{
				iniciaContexto();
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

////////////////////Inicio BREAK E CONTINUE ////////////////////////////
BREAK 		: TK_BREAK ';'
			{
				string lInc = pilhaloopLabelsFIM.front();
				$$.traducao = "\tgoto " + lInc + ";\n";
			}
			| TK_BREAK TK_ALL ';'
			{
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

////////////////////Inicio BREAK E CONTINUE ////////////////////////////

////////////////////Inicio do WHILE////////////////////////	
WHILE 		:WHILE_C '(' E ')' '{' BLOCO  '}'   // ta certo
			{	

				string variaveisDoContexto = declaraVariaveis();

				$$.loopLabel = $1.loopLabel;
				$$.jumpLabel = $1.jumpLabel;
				$$.gotojumpLabel = $1.gotojumpLabel;

				$$.traducao= "\n" + variaveisDoContexto + "\n\t" + $$.jumpLabel + ":\n" + $3.traducao + 
							 "\n\tif(!" + $3.tmp + ")goto " + $$.gotojumpLabel + ";\n" + 
							 $6.traducao + 
							 "\n\tgoto " + $$.jumpLabel + ";\n"
							 + "\n\t" + $$.gotojumpLabel + ":\n";

				pilhaloopLabelsINICIO.pop_front();
				pilhaloopLabelsFIM.pop_front();
				
				if(loopFor)
				{
					loopFor = false;
					loopWhile = true;
				}
				terminaContexto();				 
			}
			;
WHILE_C		: TK_WHILE
			{
				iniciaContexto();
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
DO			: DO_C '{' BLOCO '}' TK_WHILE '(' E ')' ';' // ta certo
			{
				string variaveisDoContexto = declaraVariaveis();

				$$.loopLabel = $1.loopLabel;
				$$.jumpLabel = $1.jumpLabel;
				$$.gotojumpLabel = $1.gotojumpLabel;

				$$.traducao = "\n" + variaveisDoContexto + "\n\t" + $$.jumpLabel + ":" + 
							 $3.traducao + "\n" + $7.traducao + 
							 "\n\tif(!" + $7.tmp + ")goto " + $$.gotojumpLabel + ";\n" +
							 "\tgoto " + $$.jumpLabel + ";\n" +
							 "\n\t" + $$.gotojumpLabel + ":\n";


				pilhaloopLabelsINICIO.pop_front();
				pilhaloopLabelsFIM.pop_front();
				
				if(loopFor)
				{
					loopFor = false;
					loopWhile = true;
				}
				terminaContexto();	
			}
DO_C		: TK_DO
			{
				iniciaContexto();
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

////////////////////Inicio Funcao//////////////////////////////////////

FUNCOES		: FUNCOES FUNCAO
			{
				$$.traducao= $1.traducao + $2.traducao;

			}
			| FUNCAO
			{
				$$.traducao= $1.traducao;
			}
			;
FUNCAO		: FUNCAO_C '(' ARGUMENTOS ')' '{' BLOCO '}'
			{
				TABELA* tab = existeID($2.label);

				(*tab)[$1.label].argumentos = $3.traducao;
				(*tab)[$1.label].tiposArgumentos = $3.tiposArgumentos;
				(*tab)[$1.label].ehFuncao = TRUE;
				(*tab)[$1.label].inicializada = 1;


				if((*tab)[$1.label].tipo == "void"){
					(*tab)[$1.label].temRetorno= FALSE;
				}
				else{
					(*tab)[$1.label].temRetorno= TRUE;
				}

				int quantidade = contaCHAR(',', $3.traducao);

				(*tab)[$1.label].quantidadeArgumentos = quantidade + 1;	

				$$.tipo= (*tab)[$1.label].tipo;
				$$.implementada = 1;
				$$.label = (*tab)[$1.label].label;
				$$.tmp= (*tab)[$1.label].tmp;
				$$.argumentos = (*tab)[$1.label].argumentos;
				$$.tiposArgumentos = (*tab)[$1.label].tiposArgumentos;


				(*tab)[$1.label].implementada = 1;

				if ($$.tipo == "void") {
					$$.temRetorno= FALSE;

					if ($6.traducao.find("return") != -1) {

						yyerror("Função definida como void, remover a cláusula ‘return’.");
					}
					else {
							$$.traducao = "\n" + $$.tipo + " " + $$.tmp +
										  "(" + $3.traducao + ") \n{\n" +
										  declaraVariaveis() + "\n" +
										  $6.variaveisDoContexto + "\n" +
										  $6.traducao + "\n}";
					}

				} else {
					$$.temRetorno= TRUE;

					if ($6.traducao.find("return") == -1) {

						yyerror("Função com retorno, acrescentar a cláusula ‘return’.");
					}
					else{

						$$.traducao = "\n" + $$.tipo + " " + $$.tmp +
										  "(" + $3.traducao + ") {\n" +
										  declaraVariaveis() + "\n" +
										  $6.variaveisDoContexto + "\n" +
										  $6.traducao + "\n}";

					//	$$.traducao = "\n" + $$.tipo + " " + $$.tmp + "(" + $3.traducao + ") {\n" + $5.traducao + "}\n";
					}
				}

				terminaContexto();

			}			
			;

FUNCAO_C	: TIPO TK_ID
			{
				iniciaContexto(); 

				TABELA * tab = pilhaDeTabelas.back();

				$$.tmp = geraLabelFuncao();
				$$.label = $2.label;
				$$.tipo = $1.tipo;
				$$.tamanhoString = 1;
				$$.ehFuncao = 1;
				$$.inicializada = 1;
				//d->argumentos = d-> tipo + " " + d->tmp;

				(*tab)[$$.label].label = $$.label;
				(*tab)[$$.label].tmp = $$.tmp;
				(*tab)[$$.label].tipo = $$.tipo;
				(*tab)[$$.label].tamanhoString = $$.tamanhoString;
				(*tab)[$$.label].ehFuncao = $$.ehFuncao;
				(*tab)[$$.label].inicializada = $$.inicializada;
				//(*tab)[d->label].argumentos = d->argumentos;				
				
				/*$$.tipo = $1.tipo;
				$$.label = $2.label;*/
				
			}			
           	;

CHAMADA_FUNCAO : TK_ID '(' CHAMADA_TK_FUNCAO ')'
				{
					int quantidade = contaCHAR(',', $3.traducao);

					TABELA* tab = existeID($1.label);
					
					if(tab == NULL)
						yyerror("Função '" + $1.label + "' não declarada.");
					
					else
					{

						$$.tmp = (*tab)[$1.label].tmp;
						$$.tipo = (*tab)[$1.label].tipo;
						$$.quantidadeArgumentos = (*tab)[$1.label].quantidadeArgumentos;
						$$.ehFuncao = true;
						$$.inicializada = (*tab)[$1.label].inicializada;

						if($$.tipo == "void"){
							$$.temRetorno= FALSE;
						}
						else{
							$$.temRetorno= TRUE;
						}

						string tiposArgumentos = (*tab)[$1.label].tiposArgumentos;
						
						int quantidadeArgumentosDeclarada = (*tab)[$1.label].quantidadeArgumentos;
						int quantidadeArgumentosChamada = quantidade + 1;
					
						$$.label = (*tab)[$1.label].label;
						
						if (quantidadeArgumentosDeclarada != quantidadeArgumentosChamada) {
							yyerror("ERRO: Quantidade de argumentos não confere. Tipo de Arguementos são: " + tiposArgumentos);
						}
						else if (tiposArgumentos != $3.tiposArgumentos) {
							cout << tiposArgumentos << " " << $3.tiposArgumentos << endl;
							yyerror("ERRO: Tipos das variáveis declaradas não confere. Tipo de Arguementos são:" + tiposArgumentos);
						}
						else {

							if ($$.tipo == "void") {
								$$.traducao = "\t" + $$.tmp + "(" + $3.traducao + ");\n";
							}
							else {						
							
								TABELA* tab2 = pilhaDeTabelas.front();

								(*tab2)[$$.label].label = $$.label;
								(*tab2)[$$.label].tipo = $$.tipo;
								(*tab2)[$$.label].tmp = geraTemp(); 

								(*tab2)[$$.label].temRetorno= TRUE;
								
								$$.tmp= (*tab2)[$$.label].tmp;

								$$.traducao = "\t" + $$.tmp + " = " + (*tab)[$1.label].tmp + "(" + $3.traducao + ");\n";
							}
						}
					}					
				}
				;

CHAMADA_TK_FUNCAO : TK_ID ',' CHAMADA_TK_FUNCAO
				{
					TABELA* tab = existeID($1.label);

					if(tab == NULL)
						yyerror("Variável '" + $1.label + "' não declarada na função.");

					$$.label = (*tab)[$1.label].label;
					$$.tmp = (*tab)[$1.label].tmp;
					$$.tipo = (*tab)[$1.label].tipo;
					$$.tiposArgumentos = $$.tipo + ", " + $3.tiposArgumentos;
					$$.traducao = $$.tmp + ", " + $3.traducao;
				}
				| TK_ID
				{
					TABELA* tab = existeID($1.label);

					if(tab == NULL)
						yyerror("Variável '" + $1.label + "' não declarada na função.");

					$$.label = (*tab)[$1.label].label;
					$$.tmp = (*tab)[$1.label].tmp;
					$$.tipo = (*tab)[$1.label].tipo;
					$$.tiposArgumentos = $$.tipo;
					$$.traducao = $$.tmp;
				}
				|
				{
					$$.traducao = "";
				}
				;

ARGUMENTOS 	: DECLARACAO ',' ARGUMENTOS
			{
				TABELA * tab = existeID($1.label);
				(*tab)[$1.label].ehParam = TRUE;
				(*tab)[$1.label].inicializada = TRUE;

				TABELA * tab2 = existeID($1.label);
				(*tab2)[$1.label].ehParam = TRUE;
				(*tab)[$1.label].inicializada = TRUE;


				$$.tiposArgumentos = $1.tipo + ", " + $3.tiposArgumentos;
				//$$.traducao = $1.argumentos + ", " + $3.traducao;
				$$.traducao = $1.argumentos + ", " + $3.traducao;

			}
			| DECLARACAO
			{
				TABELA * tab = existeID($1.label);
				(*tab)[$1.label].ehParam = TRUE;
				(*tab)[$1.label].inicializada = TRUE;

				$$.label = $1.label;
				$$.tiposArgumentos = $1.tipo;
				$$.traducao = $1.argumentos;
				
			}
			| 
			{
				$$.traducao = "";
			}
			;

RETURN 		: TK_RETURN TK_ID
			{
				TABELA* tab = existeID($2.label);


				if(tab == NULL)
				{
					yyerror("Variável " + $2.label + " não declarada.");
				}

				$$.label = (*tab)[$2.label].label;
				$$.tipo = (*tab)[$2.label].tipo;
				$$.tmp = (*tab)[$2.label].tmp;
				
				$$.traducao = "\treturn " + $$.tmp + ";";
			}
			| TK_RETURN VALOR
			{ //verificar se o valor bate com o tipo de retorno da funcao
				
				$$.traducao = $2.traducao + "\n" +
							"\treturn " + $2.tmp + ";\n";
			}
			| TK_RETURN
			{
				$$.traducao = "\n\treturn;";   
			}
			;	           	
////////////////////Fim Funcao//////////////////////////////////////
E 			:'(' E ')'
			{
				$$.tmp = $2.tmp;
				$$.label = $2.label;
				$$.tipo = $2.tipo;
				$$.inicializada = $2.inicializada;
				$$.traducao = $2.traducao;
				
			} 
			|E TK_OPERADOR_ARITMETICO E
			{

				processaOperacaoAritmetica(&$$, &$1, &$2, &$3);

			}
			|E TK_OPERADOR_LOGICO E
			{
				TABELA * tab = pilhaDeTabelas.front();
				TABELA * tab2;

				estaInicializada(&$1);
				estaInicializada(&$3);

				//cout << $1.label << " "<< $1.tmp<< endl;
				//Verificando tipo das variaveis para decidir o tipo da nova variavel temporaria 
				if($1.tipo != $3.tipo)
				{
					yyerror("Operação " + $1.tipo +  $2.operador + $3.tipo + " Inválida!");
				}	
				else
				{
					$$.tmp = geraTemp();
					$$.label = $$.tmp;
					$$.tipo = $1.tipo;
					$$.inicializada = 1; 	
					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.tmp + " = (" +
					              $1.tmp + " " + $2.operador + " " + $3.tmp + ");\n";	
				}

				(*tab)[$$.label].label = $$.label;
				(*tab)[$$.label].tmp = $$.tmp;
				(*tab)[$$.label].tipo = $$.tipo;
				(*tab)[$$.label].inicializada = $$.inicializada;

			}
			|E TK_OPERADOR_RELACIONAL E
			{
				TABELA * tab = pilhaDeTabelas.front();

				estaInicializada(&$1);
				estaInicializada(&$3);

				//Verificando tipo das variaveis para decidir o tipo da nova variavel temporaria 
				if($1.tipo != $3.tipo)
				{

					yyerror("Operação " + $1.tipo +  $2.operador + $3.tipo + " Inválida!");
				}	
				else
				{
					$$.tmp = geraTemp();
					$$.label = $$.tmp;
					$$.tipo = $1.tipo;
					$$.inicializada = 1;	
					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.tmp + " = " + 
					              $1.tmp + " " + $2.operador + " "  + $3.tmp + ";\n";	
				}

				(*tab)[$$.label].label = $$.label;
				(*tab)[$$.label].tmp = $$.tmp;
				(*tab)[$$.label].tipo = $$.tipo;
				(*tab)[$$.label].inicializada = $$.inicializada;
			}	
			| VALOR
			| TK_ID
			{    
				TABELA * tab;

				if (pertenceContextoAtual($1.label))
				{
					tab = pilhaDeTabelas.front();

					$$.tmp = (*tab)[$1.label].tmp;
					$$.label = (*tab)[$1.label].label;
					$$.valor = (*tab)[$1.label].valor;
					$$.tipo = (*tab)[$1.label].tipo;
					$$.tamanhoString = (*tab)[$1.label].tamanhoString;
					$$.valor = (*tab)[$1.label].valor;
					$$.inicializada = (*tab)[$1.label].inicializada;


				}
				else
				{	
					tab = existeID($1.label);

					if(tab == NULL )
					{
						yyerror("Variavel " + $1.label + " não declarada!");
					}		
					else
					{
						$$.tmp = (*tab)[$1.label].tmp;
						$$.label = (*tab)[$1.label].label;
						$$.valor = (*tab)[$1.label].valor;
						$$.tipo = (*tab)[$1.label].tipo;
						$$.tamanhoString = (*tab)[$1.label].tamanhoString;
						$$.valor = (*tab)[$1.label].valor;
						$$.inicializada = (*tab)[$1.label].inicializada;
					}
				}								
			}
			;

TIPO 		: TK_TIPO_INT | TK_TIPO_CHAR | TK_TIPO_FLOAT | TK_TIPO_STRING | TK_TIPO_VOID
			| TK_TIPO_BOOLEAN 
			{
				$$.tipo = "int";
			};

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
				string newValue= removeAspas($1.valor);
				$1.valor = newValue;
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
				string newValue= removeAspas($1.valor);
				$1.valor = newValue;
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

string geraTemp(void){
	
	stringstream ss;
	ss << "temp" << numTmp++;

	return ss.str();
}	

void estaInicializada(atributos * var)
{
	if(var->inicializada == 0)
	{
		yyerror("ERRO: Variavel " + var->label + " não inicializada");
	}
}		

////////////////////Iicio do Setor de Controle de Contexto////////////////////////////
TABELA *  existeID(string label)
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
void iniciaContexto()
{
	TABELA* tab = new  TABELA();
	pilhaDeTabelas.push_front(tab);
}

void terminaContexto()
{
	pilhaDeTabelas.pop_front();
}	

string declaraVariaveis()
{

	TABELA * tab = pilhaDeTabelas.front();
	stringstream var;
	string varVet;


	//for(i = pilhaDeTabelas.begin(); i != pilhaDeTabelas.end(); i++)
	for (TABELA::iterator it=tab->begin(); it!=tab->end(); it++)
	{
		atributos  atr = it->second;
		if(atr.ehParam == 1)
		{
			continue;
		}
		else if(atr.ehVetor == 1)
		{

			var << "\t" << atr.tipo << " " << atr.tmp << atr.tamanhoVetor + ";\n";
		}
		else if(atr.ehVetor == 1 && atr.tipo == "string" )
		{
			var << "\t" << "char" << " " << atr.tmp << atr.tamanhoVetor + ";\n";
		}
		else
		{	
			if(atr.tipo == "string")
			{
				//varVet = "[" + atr.tamanhoString + "]";
				var << "\t" << "char" << " " << atr.tmp << "[" << atr.tamanhoString << "];\n";
				//varVet = "";
			}
			else
			{
				var << "\t" << atr.tipo << " " << atr.tmp << ";\n";
			}
		}

	}

	return var.str();
}
string declaraVariaveisGlobais()
{
	TABELA * tab = pilhaDeTabelas.back();
	stringstream var;
	string varVet;

	//for(i = pilhaDeTabelas.begin(); i != pilhaDeTabelas.end(); i++)
	for (TABELA::iterator it=tab->begin(); it!=tab->end(); it++)
	{
		atributos  atr = it->second;
		if(atr.ehFuncao == 1)
		{
			continue;
		}
		else if(atr.ehVetor == 1)
		{
			var << "\t" << atr.tipo << " " << atr.tmp << atr.tamanhoVetor + ";\n";
		}
		else if(atr.ehVetor == 1 && atr.tipo == "string" )
		{
			var << "\t" << "char" << " " << atr.tmp << atr.tamanhoVetor + ";\n";
		}
		else
		{
			if(atr.tipo == "string")
			{
				
				var << "char" << " " << atr.tmp << "[" << atr.tamanhoString << "];\n";
			}
			else
			{
				var << atr.tipo << " " << atr.tmp << ";\n";
			}
		}
	}

	for (TABELA::iterator it=vardescartadas.begin(); it!=vardescartadas.end(); it++)
	{
		atributos  atr = it->second;
		
		if(atr.tipo == "string")
		{
			
			var << "char" << " " << atr.tmp << "[" << atr.tamanhoString << "];\n";
		}
		else
		{
			var << atr.tipo << " " << atr.tmp << ";\n";
		}
	}


	return var.str();
}
////////////////////Fim do Setor de Controle de Contexto////////////////////////////

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

void processaOperacaoAritmetica(atributos * d, atributos * d1, atributos * d2, atributos * d3)
{
	TABELA * tab = pilhaDeTabelas.front();
	
	estaInicializada(d1);
	estaInicializada(d3);

	if(d1->tipo == "string" || d3->tipo == "string")
	{

		processaOperacaoAritmeticaString(d,d1,d2,d3);
	}
	else
	{
		if(d1->tipo != d3->tipo)
		{

			string tipo = getTipo(d1->tipo +  d2->operador + d3->tipo);

			castTemp(d,d1,d2,d3,tipo);
		}	
		else
		{
			d->tmp = geraTemp();
			d->label = d->tmp;
			d->tipo = d1->tipo;
			d->inicializada = 1;

			(*tab)[d->label].tmp = d->tmp;
			(*tab)[d->label].label = d->label;
			(*tab)[d->label].tipo = d->tipo;
			(*tab)[d->label].inicializada = d->inicializada;
			//Verificar como recuperar o tamanho de uma string em operação aritmetica

			d->traducao = d1->traducao + d3->traducao + "\t" + d->tmp + " = " + d1->tmp + " " + 
			              d2->operador + " " + d3->tmp + ";\n";	
		}
	}
	
}
void castTemp(atributos * d, atributos * d1, atributos* d2, atributos* d3,  string tipo)
{
	
	TABELA * tab = pilhaDeTabelas.front();
	TABELA * tab1;

	atributos castT;


	if (d1->tipo != tipo)
	{
		
		castT.tmp = geraTemp();
		castT.label = castT.tmp;
		castT.tipo = tipo;
		castT.inicializada = 1;

		(*tab)[castT.label].tmp = castT.tmp;
		(*tab)[castT.label].label = castT.label;
		(*tab)[castT.label].tipo = castT.tipo;
		(*tab)[castT.label].inicializada = castT.inicializada;

		castT.traducao = "\t" + castT.tmp + " = (" +  tipo + ") "  + d1->tmp + ";\n";


		d->tmp = geraTemp();
		d->label = d->tmp;
		d->tipo = tipo;	
		d->inicializada = 1;

		(*tab)[d->label].tmp = d->tmp;
		(*tab)[d->label].label = d->label;
		(*tab)[d->label].tipo = d->tipo;
		(*tab)[d->label].inicializada = d->inicializada;

		d->traducao = d1->traducao + d3->traducao + castT.traducao + "\t" + 
		              d->tmp + " = " + castT.tmp + " " + d2->operador + " " + d3->tmp + ";\n";

	}
	else
	{
		
		castT.tmp = geraTemp();
		castT.label = castT.tmp;
		castT.tipo = tipo;
		castT.inicializada = 1;

		(*tab)[castT.label].tmp = castT.tmp;
		(*tab)[castT.label].label = castT.label;
		(*tab)[castT.label].tipo = castT.tipo;
		(*tab)[castT.label].inicializada = castT.inicializada;

		castT.traducao = "\t" + castT.tmp + " = (" +  tipo + ") "  + d3->tmp + ";\n";

		d->tmp = geraTemp();
		d->label = d->tmp;
		d->tipo = tipo;	
		d->inicializada = 1;

		(*tab)[d->label].tmp = d->tmp;
		(*tab)[d->label].label = d->label;
		(*tab)[d->label].tipo = d->tipo;
		(*tab)[d->label].inicializada = d->inicializada;

		d->traducao = d1->traducao + d3->traducao + castT.traducao + "\t" + d->tmp + " = " + 
		              d1->tmp + " " + d2->operador + " " + castT.tmp + ";\n";

	}
}

void processaDeclaracao(atributos * d, atributos * d1, atributos * d2, atributos * d3, atributos * d4)
{
	TABELA * tab = pilhaDeTabelas.front();

	estaInicializada(d4);
		
	if(d1->tipo == "string")
	{
		processaDeclaracaoString(d,d1,d2,d3,d4);
	}
	else
	{
		//Verificando tipo das variaveis para decidir o tipo da nova variavel temporaria 
		if(d1->tipo != d4->tipo)
		{	
			
			string tipo = getTipo(d1->tipo + d3->operador + d4->tipo);

			d->tmp  =  geraTemp();
			d->label = d2->label;
			d->tipo = d1->tipo;
			d->tamanhoString = d4->tamanhoString;
			d->valor = d4->valor;
			d->inicializada = 1;

			(*tab)[d->label].label = d->label;
			(*tab)[d->label].tmp = d->tmp;
			(*tab)[d->label].tipo = d->tipo;
			(*tab)[d->label].tamanhoString = d->tamanhoString;
			(*tab)[d->label].valor = d->valor;
			(*tab)[d->label].inicializada = d->inicializada;
		
			d->traducao = d4->traducao + "\t" + d->tmp + " = " + "(" + tipo + ") " + d4->tmp + ";\n";
		}	
		else
		{

			d->tmp = geraTemp();
			d->label = d2->label;
			d->tipo = d1->tipo;
			d->tamanhoString = d4->tamanhoString;
			d->valor = d4->valor;
			d->inicializada = 1;
			
			(*tab)[d->label].label = d->label;
			(*tab)[d->label].tmp = d->tmp;
			(*tab)[d->label].tipo = d->tipo;
			(*tab)[d->label].tamanhoString = d->tamanhoString;
			(*tab)[d->label].valor = d->valor;
			(*tab)[d->label].inicializada = d->inicializada;

			d->traducao = d4->traducao + "\t" + d->tmp + " = " + d4->tmp + ";\n";
			
		}
	}
	
}
void processaAtribuicao(atributos * d, atributos * d1, atributos * d2, atributos * d3)
{

	TABELA * tab; 
	
	estaInicializada(d3);

	if (pertenceContextoAtual(d1->label))
	{
		tab = pilhaDeTabelas.front();

		d->tmp = (*tab)[d1->label].tmp;
		d->tipo = (*tab)[d1->label].tipo;
	}
	else
	{	//Precisa Verificar se variavel retornada é global////////////////
		tab = existeID(d1->label);

		if(tab == NULL )
		{
			yyerror("Variavel " + d1->label + " não declarada!");
		}		
		else
		{
			d->tmp = (*tab)[d1->label].tmp;
			d->tipo = (*tab)[d1->label].tipo;
		}
	}

	//Verificando tipo das variaveis para decidir o tipo da nova variavel temporaria 
	if(d->tipo != d3->tipo)
	{		

		if(d->tipo == "string")
		{
			atributos  aux;
			string tipo = getTipo(d->tipo + d2->operador + d3->tipo);
			int tamanho = d3->valor.size() + 1;

			//Declara uma variavel para fazer cast do char para string
			atributos cast;

			castCharToString(&cast, d3);

			d->tmp = geraTemp();
			d->label = d1->label;
			d->tipo = tipo;
			d->tamanhoString = tamanho;
			d->valor = d3->valor;
			d->inicializada = 1;

			///Realocando a antiga temporária do TK_ID para que ela 
			//ainda seja declarada no código intermediário
			aux.label = (*tab)[d1->label].tmp;
			aux.tmp = (*tab)[d1->label].tmp;
			aux.tipo = (*tab)[d1->label].tipo;
			aux.tamanhoString = (*tab)[d1->label].tamanhoString;
			aux.valor = (*tab)[d1->label].valor;
			aux.inicializada = (*tab)[d1->label].inicializada;

			vardescartadas[aux.label] = aux;

			(*tab)[d->label].tmp = d->tmp;
			(*tab)[d->label].label = d->label;
			(*tab)[d->label].tamanhoString = d->tamanhoString;
			(*tab)[d->label].tipo = d->tipo;
			(*tab)[d->label].valor = d->valor;
			(*tab)[d->label].inicializada = d->inicializada;

			d->traducao = d1->traducao + d3->traducao + cast.traducao + 
							  "\tstrcpy(" + d->tmp + " , " + cast.tmp + ");\n";
		}
		else
		{
			string tipo = getTipo(d1->tipo + d2->operador + d3->tipo);

			d->traducao = d1->traducao + d3->traducao + "\t" + d->tmp + 
			              " = " + "(" + d->tipo + ") " + d3->tmp + ";\n";

			(*tab)[d->label].valor = d3->valor;
			(*tab)[d->label].tamanhoString = d3->tamanhoString;
			(*tab)[d->label].inicializada = 1;

       }
	}	
	else
	{
		if(d->tipo == "string")
		{
			atributos  aux;
			string tipo = getTipo(d->tipo + d2->operador + d3->tipo);
			int tamanho = d3->valor.size() + 1;						

			d->tmp = geraTemp();
			d->label = d1->label;
			d->tipo = tipo;
			d->tamanhoString = tamanho;
			d->valor = d3->valor;
			d->inicializada = 1;

			///Realocando a antiga temporária do TK_ID para que ela 
			//ainda seja declarada no código intermediário
			aux.label = (*tab)[d1->label].tmp;
			aux.tmp = (*tab)[d1->label].tmp;
			aux.tipo = (*tab)[d1->label].tipo;
			aux.tamanhoString = (*tab)[d1->label].tamanhoString;
			aux.valor = (*tab)[d1->label].valor;
			aux.inicializada = (*tab)[d1->label].inicializada;

			vardescartadas[aux.label] = aux;


			(*tab)[d->label].tmp = d->tmp;
			(*tab)[d->label].label = d->label;
			(*tab)[d->label].tamanhoString = d->tamanhoString;
			(*tab)[d->label].tipo = d->tipo;
			(*tab)[d->label].valor = d->valor;
			(*tab)[d->label].inicializada = d->inicializada;

			d->traducao = d1->traducao + d3->traducao +
							  "\tstrcpy(" + d->tmp + " , " + d3->tmp + ");\n";
		}
		else
		{	
			d->traducao = d1->traducao + d3->traducao + "\t" + d->tmp + " = " + d3->tmp + ";\n";

			(*tab)[d->label].valor = d3->valor;
			(*tab)[d->label].tamanhoString = d3->tamanhoString;
			(*tab)[d->label].inicializada = 1;
		}
	}

}
void processaTK_ID(atributos * d, atributos * d1, atributos * d2)
{
	TABELA * tab = pilhaDeTabelas.front();


	if(d1->tipo == "string")
	{
		stringstream arg;

		d->tmp = geraTemp();
		d->label = d2->label;
		d->tipo = d1->tipo;
		d->tamanhoString = 1;
		d->ehFuncao = 0;
		d->inicializada = 0;
		arg << "char " << d->tmp << "[]";
		d->argumentos = arg.str();

		(*tab)[d->label].label = d->label;
		(*tab)[d->label].tmp = d->tmp;
		(*tab)[d->label].tipo = d->tipo;
		(*tab)[d->label].tamanhoString = d->tamanhoString;
		(*tab)[d->label].ehFuncao = d->ehFuncao;
		(*tab)[d->label].inicializada = d->inicializada;
		(*tab)[d->label].argumentos = d->argumentos;
	}
	else
	{
		d->tmp = geraTemp();
		d->label = d2->label;
		d->tipo = d1->tipo;
		d->tamanhoString = 1;
		d->ehFuncao = 0;
		d->inicializada = 0;
		d->argumentos = d-> tipo + " " + d->tmp;

		(*tab)[d->label].label = d->label;
		(*tab)[d->label].tmp = d->tmp;
		(*tab)[d->label].tipo = d->tipo;
		(*tab)[d->label].tamanhoString = d->tamanhoString;
		(*tab)[d->label].ehFuncao = d->ehFuncao;
		(*tab)[d->label].inicializada = d->inicializada;
		(*tab)[d->label].argumentos = d->argumentos;
	}
}
////////////Inicio Processamento de String ////////////////////////////////////////////
void processaDeclaracaoString(atributos * d, atributos * d1, atributos * d2, atributos * d3, atributos * d4)
{

	TABELA * tab = pilhaDeTabelas.front();

	estaInicializada(d4);

	int tamanho = d2->tamanhoString + d4->tamanhoString;

	//Verificando tipo das variaveis para decidir o tipo da nova variavel temporaria 
	if(d1->tipo != d4->tipo)
	{	
		
		string tipo = getTipo(d1->tipo + d3->operador + d4->tipo);

		//Declara uma variavel para fazer cast do char para string
		atributos cast;

		castCharToString(&cast, d4);

		d->tmp = geraTemp();
		d->label = d2->label;
		d->tipo = d1->tipo;
		d->valor = d4->valor;
		d->tamanhoString = tamanho;
		d->inicializada = 1;

		(*tab)[d2->label].tmp = d->tmp;
		(*tab)[d2->label].tipo = d->tipo;
		(*tab)[d2->label].label = d->label;
		(*tab)[d2->label].valor = d->valor;
		(*tab)[d2->label].tamanhoString = d->tamanhoString;
		(*tab)[d2->label].inicializada = d->inicializada;

		d->traducao =  d4->traducao +
					   cast.traducao + 
					   "\tstrcpy(" + d->tmp + ", " + cast.tmp +");\n";
	}	
	else
	{
		
		d->tmp = geraTemp();
		d->label = d2->label;
		d->tipo = d1->tipo;
		d->valor = d4->valor;
		d->tamanhoString = tamanho;
		d->inicializada = 1;

		(*tab)[d2->label].tmp = d->tmp;
		(*tab)[d2->label].tipo = d->tipo;
		(*tab)[d2->label].label = d->label;
		(*tab)[d2->label].valor = d->valor;
		(*tab)[d2->label].tamanhoString = d->tamanhoString;
		(*tab)[d2->label].inicializada = d->inicializada;

		d->traducao =  d4->traducao + 
						   "\tstrcpy(" + d->tmp + " , " + d4->tmp +");\n";

						   
		
	}
}

void processaOperacaoAritmeticaString(atributos * d, atributos * d1, atributos * d2, atributos * d3)
{
	TABELA * tab = pilhaDeTabelas.front();
	int tamanho;

	estaInicializada(d1);
	estaInicializada(d3);

	if(d2->operador == "+")
	{
		if(d1->tipo == "string" && d3->tipo == "string")
		{
			tamanho = d1->valor.size() + d3->valor.size() + 1;

			d->tmp = geraTemp();
			d->label = d->tmp;
			d->tipo = "string";
			d->valor = d1->valor + d3->valor;
			d->tamanhoString = tamanho;
			d->inicializada = 1;

			d->traducao = d1->traducao + d3->traducao +
							  "\tstrcpy(" + d->tmp + " , " + d1->tmp + ");\n"
							  "\tstrcat(" + d->tmp + " , " + d3->tmp + ");\n";

			(*tab)[d->label].tmp =  d->tmp;
			(*tab)[d->label].label = d->label;
			(*tab)[d->label].tipo = d->tipo;				  
			(*tab)[d->label].tamanhoString = d->tamanhoString;
			(*tab)[d->label].inicializada = d->inicializada;

		}
		else if(d1->tipo != "string" || d3->tipo != "string")
		{
			if(d1->tipo == "char" && d3->tipo == "string")
			{
				tamanho = d1->valor.size() + d3->valor.size() + 1;

				d->tmp = geraTemp();
				d->label = d->tmp;
				d->tipo = "string";
				d->tamanhoString = tamanho;
				d->inicializada = 1;

				d->traducao = d1->traducao + d3->traducao +
								  "\tstrcpy(" + d->tmp + " , " + d1->tmp + ");\n"
								  "\tstrcat(" + d->tmp + " , " + d3->tmp + ");\n";

				(*tab)[d->label].tmp =  d->tmp;
				(*tab)[d->label].label = d->label;
				(*tab)[d->label].tipo = d->tipo;				  
				(*tab)[d->label].tamanhoString = d->tamanhoString;
				(*tab)[d->label].inicializada = d->inicializada;
			}
			/*else if (d1->tipo != "char" && d3->tipo == "string")
			{
				tamanho = 1024;

				d->tmp = geraTemp();
				d->label = d->tmp;
				d->tipo = "string";
				d->tamanhoString = tamanho;

				atributos cast;

				cast.tmp = geraTemp();
				cast.label = cast.tmp;
				cast.tipo = "stirng";
				cast.tamanhoString = tamanho;

				cast.traducao = "\t" + cast.tmp + " = to_string(" + d1->tmp + ");\n";  

				d->traducao = d1->traducao + d3->traducao + cast.traducao +
								  "\tstrcpy(" + d->tmp + " , " + cast.tmp + ");\n"
								  "\tstrcat(" + d->tmp + " , " + d3->tmp + ");\n";

				(*tab)[d->label].tmp =  d->tmp;
				(*tab)[d->label].label = d->label;
				(*tab)[d->label].tipo = d->tipo;				  
				(*tab)[d->label].tamanhoString = d->tamanhoString;
			}*/
		}
	}
	/*else if (d2->operador == "-" and (d1->tipo = "int" || d3->tipo == "int"))
	{	
		tamanho = d1->tamanhoString - d3->tamanhoString;

		if (d1->tipo != d2->tipo)
		{
			if(d1->tipo == "int")
			{
				d->tmp = geraTempString(tamanho, LOCAL);
				d->label = d->tmp;
				d->tipo = "string";
				d->tamanhoString = tamanho;

			}
		}
		else
	}
	else if (d2->operador == "*" and (d1->tipo = "int" || d3->tipo == "int"))
	{
		//Verifica quem é do tipo int para fazer a conta correta na hora de gerar a nova string	
		if(d1->tipo == "int")
		{
			tamanho = atoi(d1->valor) * d3->tamanhoString + atoi(d1->valor);
		
			d->tmp = geraTempString(tamanho, LOCAL);
			d->label = d->tmp;
			d->tipo = "string";
			d->tamanhoString = tamanho;
		}
		else
		{
			tamanho = atoi(d3->valor) * d1->tamanhoString + atoi(d3->valor);
		
			d->tmp = geraTempString(tamanho, LOCAL);
			d->label = d->tmp;
			d->tipo = "string";
			d->tamanhoString = tamanho;
		}
	}*/
	else
	{
		yyerror("Operacao Invalida " + d1->tipo +  d2->operador + d3->tipo);
	}

}

void castCharToString(atributos * d, atributos * d1)
{

	TABELA * tab = pilhaDeTabelas.front();

	int tamanho = d1->tamanhoString;

	d->tmp = geraTemp();
	d->label = d->tmp;
	d->tipo = "string";
	d->tamanhoString = tamanho;

	(*tab)[d->label].tmp =  d->tmp;
	(*tab)[d->label].label = d->label;
	(*tab)[d->label].tipo = d->tipo;
	(*tab)[d->label].tamanhoString = d->tamanhoString;

	d->traducao = "\n\t" + d->tmp + "[0] = " + d1->tmp + ";\n";

}
////////////Fim Processamento de String ////////////////////////////////////////////
void processaTK_VALOR(atributos * d, atributos * d1, string tipo)
{
	TABELA * tab = pilhaDeTabelas.front();
	int tamanho = d1->valor.size() + 1;

	if (d1->tipo == "string")
	{
		
		d->tmp = geraTemp();;
		d->label = d->tmp;
		d->tipo = d1->tipo;
		d->valor = d1->valor;
		d->tamanhoString = tamanho;
		d->traducao = "\tstrcpy(" + d->tmp  + " , \"" + d1->valor + "\");\n";
		d->inicializada = 1;
		
		(*tab)[d->label].tmp =  d->tmp;
		(*tab)[d->label].label = d->label;
		(*tab)[d->label].tipo = d->tipo;
		(*tab)[d->label].valor = d->valor;
		(*tab)[d->label].tamanhoString = d->tamanhoString;
		(*tab)[d->label].inicializada = d->inicializada;

	}
	else
	{
		d->tmp = geraTemp();;
		d->label = d->tmp;
		d->tipo = d1->tipo;
		d->valor = d1->valor;
		d->tamanhoString = tamanho;
		d->inicializada = 1;

		if(d1->tipo == "char")
			d->traducao = "\n\t" + d->tmp  + " = \'" + d1->valor + "\';\n";
		else
			d->traducao = "\n\t" + d->tmp  + " = " + d1->valor + ";\n";
		
		(*tab)[d->label].tmp =  d->tmp;
		(*tab)[d->label].label = d->label;
		(*tab)[d->label].tipo = d->tipo;
		(*tab)[d->label].valor = d->valor;
		(*tab)[d->label].tamanhoString = d->tamanhoString;
		(*tab)[d->label].inicializada = d->inicializada;
	}
}

////////////Inicio Condicionais/////////////////////////////////////////////////////
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
////////////Fim Condicionais/////////////////////////////////////////////////////

////////////Inicio Loop//////////////////////////////////////////////////////////
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

void traducaoOpAritmeticaIncDec(atributos* d, atributos* d1,atributos* d2)
{	
		TABELA * tab;

		//estaInicializada(d1);

		if (pertenceContextoAtual(d1->label))
		{
			tab = pilhaDeTabelas.front();

			d->tipo = (*tab)[d1->label].tipo;
			d->inicializada = (*tab)[d1->label].inicializada;
			estaInicializada(d);
			
		}
		else
		{	//Precisa Verificar se variavel retornada é global////////////////
			tab = existeID(d1->label);

			if(tab == NULL )
			{
				yyerror("Variavel " + d1->label + " não declarada!");
			}		
			else
			{
				d->tipo = (*tab)[d1->label].tipo;
				d->inicializada = (*tab)[d1->label].inicializada;
				estaInicializada(d);
			}
		}
		d->tmp = geraTemp();
		d->label = d->tmp; 
		d->tipo = (*tab)[d1->label].tipo;
		d->inicializada = 1;	
		d->traducao = "\n\t" + d->tmp + " = " + "1;\n";	
	
		if (d2->operador == "++")
		{ 	
			d->traducao += "\t" + (*tab)[d1->label].tmp + " = " + (*tab)[d1->label].tmp + " + " + d->tmp + ";\n";
		}
		else if (d2->operador == "--")
		{
			d->traducao += "\t" + (*tab)[d1->label].tmp + " = " + (*tab)[d1->label].tmp + " - " + d->tmp + ";\n";
		}
		else
		{
			yyerror( "Variavel " + d2->operador + " em formato incorreto !");
		}

		
		(*tab)[d->label].tmp =  d->tmp;
		(*tab)[d->label].label = d->label;
		(*tab)[d->label].tipo = d->tipo;
		(*tab)[d->label].inicializada = d->inicializada;
	
}

////////////Fim Loop//////////////////////////////////////////////////////////

////////////Inicio Processamento Função//////////////////////////////////////
string geraLabelFuncao()
{
	static int ll = 0;
	stringstream ss;

	ss << "FUNCAO" << ll++;
	
	return ss.str();	
}

int contaCHAR(char caractere, string texto) 
{
	int quantidade= 0;

	for (int i = 0; i < texto.size(); i++) {
		if (texto[i] == caractere) {

			quantidade++;
		}
	}
	return quantidade;
}
////////////Fm Processamento Função//////////////////////////////////////

string removeAspas(string text)
{
	int tam = text.size() - 1;

	string newText = "";

	/*strcpy(newText, text[1]);*/

	for(int i = 1; i < tam; i++)
		newText += text[i];

	return newText;
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