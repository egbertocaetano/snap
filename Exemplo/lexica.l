%{
#include <string>
int linha;
int coluna;
%}

ESPACO [ \t]
DIGITO [0-9]
LETRA [A-Za-z_]

DELIM {ESPACO}+
NUM {DIGITO}+
REAL {NUM}+("."{NUM}+)?
CHAR \'({LETRA}|{NUM})\'
ID {LETRA}({LETRA}|{NUM})*

%%

"\n"		{}

{DELIM} 	{}

"main"		{return TK_MAIN;}

"int"			{ yylval.tipo = yytext; return TK_TIPO_INT;}
"char"			{ yylval.tipo = yytext; return TK_TIPO_CHAR;}
"float"			{ yylval.tipo = yytext; return TK_TIPO_FLOAT;}
"string"		{ yylval.tipo = yytext; return TK_TIPO_STRING;}
"boolean"		{ yylval.tipo = yytext; return TK_TIPO_BOOLEAN;}

"="			{return *yytext; }

[(){}[\];,]	{ return *yytext; }

[+\-*/]		{ yylval.operador = yytext; return TK_OPERADOR_MATEMATICO; }

"&&"			{ yylval.operador = yytext; return TK_OPERADOR_RELACIONAL; }
"||"			{ yylval.operador = yytext; return TK_OPERADOR_RELACIONAL; }
"<"				{ yylval.operador = yytext; return TK_OPERADOR_LOGICO; }
">"				{ yylval.operador = yytext; return TK_OPERADOR_LOGICO; }
"<="			{ yylval.operador = yytext; return TK_OPERADOR_LOGICO; }
">="			{ yylval.operador = yytext; return TK_OPERADOR_LOGICO; }
"=="			{ yylval.operador = yytext; return TK_OPERADOR_LOGICO; }
"!="			{ yylval.operador = yytext; return TK_OPERADOR_LOGICO; }


{NUM}		{ yylval.valor = yytext; yylval.tipo = "int"; return TK_NUM; }
{REAL}		{ yylval.valor = yytext; yylval.tipo = "float"; return TK_REAL; }
{CHAR}		{ yylval.valor = yytext; yylval.tipo = "char"; return TK_CHAR; }
"TRUE"		{ yylval.valor = yytext; yylval.tipo = "boolean"; return TK_VALOR_LOGICO; }
"FALSE"		{ yylval.valor = yytext; yylval.tipo = "boolean"; return TK_VALOR_LOGICO; }
{ID}		{ yylval.label = yytext; return TK_ID; }

("//"[^\n]*)|("/*"[^"*/"]*"*/")			{}

.			{ *yytext; }

%%
