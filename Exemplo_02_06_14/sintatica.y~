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


//Declarações de protótipos de funções
int yylex(void);
void yyerror(string);
string geraTemp(void);
int existeID(string label);
//string verificaInicializacao(string label);
string getTipo(string operacao);
map<string, string> criaTabTipoRetorno();


//Declarações de variaveis globais
map <string , ID> tabID;
map<string, string> tabTipos = criaTabTipoRetorno();
%}

%token TK_NUM TK_REAL TK_VALOR_LOGICO TK_CHAR
%token TK_MAIN TK_ID
%token TK_FIM TK_ERROR
%token TK_OPERADOR_LOGICO TK_OPERADOR_RELACIONAL TK_OPERADOR_MATEMATICO TK_ATRIBUICAO
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

DECLARACAO	:TIPO TK_ID TK_ATRIBUICAO VALOR
			{

				//Verificando tipo das variaveis para decidir o tipo da nova variavel temporaria 
				if($1.tipo != $4.tipo)
				{	
					string tipo = getTipo($1.tipo + $3.operador + $4.tipo);

					struct ID id;
					id.temp =  geraTemp();
					id.tipo = $1.tipo;
					id.label = $2.label;
					id.valor = $4.valor;
					$$.tmp = id.temp;
					$$.label = id.label;
					tabID[$$.label] = id;
					
					$$.traducao = $1.traducao + $4.traducao + "\t" + tabID[$$.label].tipo + " " + tabID[$2.label].temp + " = " + "(" + tipo + ") " + $3.tmp + ";\n";
				}	
				else
				{
					struct ID id;
					id.temp =  geraTemp();
					id.tipo = $1.tipo;
					id.label = $2.label;
					id.valor = $4.valor;
					$$.tmp = id.temp;
					$$.label = id.label;
					tabID[$$.label] = id;
					$$.traducao = $4.traducao + "\t" + tabID[$$.label].tipo + " " + tabID[$2.label].temp + " = " + $4.tmp + ";\n";
					
					//$$.traducao = $1.traducao + $3.traducao + "\t" +  + " = " + $3.tmp + ";\n";
				}
				
			} 
			|TIPO TK_ID TK_ATRIBUICAO E
			{
				//Verificando tipo das variaveis para decidir o tipo da nova variavel temporaria 
				if($1.tipo != $4.tipo)
				{	
					string tipo = getTipo($1.tipo + $3.operador + $4.tipo);

					struct ID id;
					id.temp =  geraTemp();
					id.tipo = $1.tipo;
					id.label = $2.label;
					id.valor = $4.valor;
					$$.tmp = id.temp;
					$$.label = id.label;
					tabID[$$.label] = id;
					
					$$.traducao = $1.traducao + $4.traducao + "\t" + tabID[$$.label].tipo + " " +  tabID[$2.label].temp + " = " + "(" + tipo + ") " + $4.tmp + ";\n";
				}	
				else
				{
					struct ID id;
					id.temp =  geraTemp();
					id.tipo = $1.tipo;
					id.label = $2.label;
					id.valor = $4.valor;
					$$.tmp = id.temp;
					$$.label = id.label;
					tabID[$$.label] = id;
					$$.traducao = $4.traducao + "\t" + tabID[$$.label].tipo + " " + tabID[$2.label].temp + " = " + $4.tmp + ";\n";
					
					//$$.traducao = $1.traducao + $3.traducao + "\t" +  + " = " + $3.tmp + ";\n";
				}
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

ATRIBUICAO	: TK_ID TK_ATRIBUICAO E
			{
				if(existeID($1.label))
				{

					//Verificando tipo das variaveis para decidir o tipo da nova variavel temporaria 
					if($1.tipo != $3.tipo)
					{	
						string tipo = getTipo(tabID[$1.label].tipo + $2.operador + $3.tipo);	
						$$.traducao = $1.traducao + $3.traducao + "\t" + tabID[$1.label].temp + " = " + "(" + tipo + ") " + $3.tmp + ";\n";
					}	
					else 
					{
						$$.traducao = $1.traducao + $3.traducao + "\t" + tabID[$1.label].temp + " = " + $3.tmp + ";\n";
					}
					
				}	
			}
			;

E 			:'(' E ')'
			{
				$$.tmp = $2.tmp;
				$$.traducao = $2.traducao;
			} 
			|E OPERADOR E
			{
				//Verificando tipo das variaveis para decidir o tipo da nova variavel temporaria 
				if($1.tipo != $3.tipo)
				{
					string tipo = getTipo($1.tipo +  $2.operador + $3.tipo);
					$$.tmp = geraTemp();
					$$.tipo = tipo;	
					$$.traducao = $1.traducao + $3.traducao + "\t" + tipo + " " + $$.tmp + " = " + $1.tmp + $2.operador + $3.tmp + ";\n";
				}	
				else
				{
					$$.tmp = geraTemp();
					$$.tipo = $1.tipo;	
					$$.traducao = $1.traducao + $3.traducao + "\t" + $1.tipo + " " + $$.tmp + " = " + $1.tmp + $2.operador + $3.tmp + ";\n";	
				}
			}	
			| VALOR
			| TK_ID
			{
				if(existeID($1.label))
				{
					$$.tmp = tabID[$1.label].temp;
					$$.label = tabID[$$.label].label;
					$$.valor = tabID[$$.label].valor;
					$$.tipo = tabID[$$.label].tipo;
					//$$.traducao = "\t" + $$.tmp + " = " + tabID[$$.label].label + ";\n";
				}
				
			}
			;

OPERADOR 	: TK_OPERADOR_LOGICO | TK_OPERADOR_RELACIONAL | TK_OPERADOR_MATEMATICO;

TIPO 		: TK_TIPO_INT | TK_TIPO_CHAR | TK_TIPO_FLOAT | TK_TIPO_STRING | TK_TIPO_BOOLEAN;

VALOR 		: TK_NUM
			{
				$$.tmp = geraTemp();
				$$.tipo = $1.tipo;
				$$.traducao = "\t" + $1.tipo + " " + $$.tmp + " = " + $1.valor + ";\n";
			}
			| TK_REAL
			{
				$$.tmp = geraTemp();
				$$.tipo = $1.tipo;
				$$.traducao = "\t" + $1.tipo + " " + $$.tmp + " = " + $1.valor + ";\n";
			}
			|TK_CHAR
			{
				$$.tmp = geraTemp();
				$$.tipo = $1.tipo;
				$$.traducao = "\t" + $1.tipo + " " + $$.tmp + " = " + $1.valor + ";\n";
			}
			|TK_VALOR_LOGICO
			{
				$$.tmp = geraTemp();
				$$.tipo = $1.tipo;
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

/*int verificaInicializacao(string label)
{
	if(label == tabID[label].label)
		return 1;
	
	return "";	
}*/

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

map<string, string> criaTabTipoRetorno()
{
    map<string, string> tabela_tipos;
    
    //Tabela de Operação para soma
    tabela_tipos["int+int"] = "int";
    tabela_tipos["int+float"] = "float";
    tabela_tipos["float+int"] = "float";
    tabela_tipos["int+string"] = "string";
    tabela_tipos["string+int"] = "string";
    tabela_tipos["int+char"] = "char"; //Verificar se será esse tipo mesmo para essa operação
    tabela_tipos["char+int"] = "char";
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
    tabela_tipos["int-char"] = "char"; //Verificar se será esse tipo mesmo para essa operação
    tabela_tipos["char-int"] = "char";
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
    tabela_tipos["int*string"] = "ERRO";
    tabela_tipos["string*int"] = "ERRO";
    tabela_tipos["int*char"] = "ERRO"; //Verificar se será esse tipo mesmo para essa operação
    tabela_tipos["char*int"] = "ERRO";
    tabela_tipos["float*float"] = "float";
    tabela_tipos["float*string"] = "ERRO";
    tabela_tipos["string*float"] = "ERRO";
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
   
   	
	// Para operadores relacionais e atribuicao, a tabela da o tipo de cast6  
    tabela_tipos["float>float"] = "boolean";
    tabela_tipos["int>int"] = "boolean";
    tabela_tipos["float>int"] = "boolean";
    tabela_tipos["char>char"] = "boolean";    
	tabela_tipos["string>string"] = "boolean"; 
    tabela_tipos["int>=int"] = "boolean";
    tabela_tipos["float>=float"] = "boolean";
    tabela_tipos["float>=int"] = "boolean";
    tabela_tipos["char>=char"] = "boolean";
    tabela_tipos["string>=string"] = "boolean"; 
    
    tabela_tipos["int<int"] = "boolean";
    tabela_tipos["float<float"] = "boolean";
    tabela_tipos["float<int"] = "boolean";
    tabela_tipos["char<char"] = "boolean";
    tabela_tipos["string<string"] = "boolean";
    tabela_tipos["int<=int"] = "boolean";
    tabela_tipos["float<=float"] = "boolean";
    tabela_tipos["float<=int"] = "boolean";
    tabela_tipos["char<=char"] = "boolean";
    tabela_tipos["string<=string"] = "boolean";
    
    tabela_tipos["int==int"] = "boolean";
    tabela_tipos["float==float"] = "boolean";
    tabela_tipos["float==int"] = "boolean";
    tabela_tipos["char==char"] = "boolean";
    tabela_tipos["string==string"] = "boolean";
    
    tabela_tipos["int!=int"] = "boolean";
    tabela_tipos["float!=float"] = "boolean";
    tabela_tipos["float!=int"] = "boolean";
    tabela_tipos["char!=char"] = "boolean";
    tabela_tipos["string!=string"] = "boolean";
    
   /* tabela_tipos["int&&int"] = "int";//Tirar dúvida com o professor
    tabela_tipos["int||int"] = "int";*/
    
    
    tabela_tipos["int=float"] = "int";
    tabela_tipos["int=char"] = "int";
    tabela_tipos["float=int"] = "float";
    tabela_tipos["char=int"] = "char";
    tabela_tipos["string=char"] = "string";
	tabela_tipos["float=int"] = "float";
   	
    
    return tabela_tipos;   
}
