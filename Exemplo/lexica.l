%{
#include <string>

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

[+\-*/]		{ return *yytext; }

"&&"			{ yylval.operadorLogico = yytext; return TK_OPERADOR_RELACIONAL; }
"||"			{ yylval.operadorLogico = yytext; return TK_OPERADOR_RELACIONAL; }
"<"				{ yylval.operadorLogico = yytext; return TK_OPERADOR_LOGICO; }
">"				{ yylval.operadorLogico = yytext; return TK_OPERADOR_LOGICO; }
"<="			{ yylval.operadorLogico = yytext; return TK_OPERADOR_LOGICO; }
">="			{ yylval.operadorLogico = yytext; return TK_OPERADOR_LOGICO; }
"=="			{ yylval.operadorLogico = yytext; return TK_OPERADOR_LOGICO; }
"!="			{ yylval.operadorLogico = yytext; return TK_OPERADOR_LOGICO; }


{NUM}		{ yylval.valor = yytext; return TK_NUM; }
{REAL}		{ yylval.valor = yytext; return TK_REAL; }
{CHAR}		{ yylval.valor = yytext; return TK_CHAR; }
"true"		{ yylval.valor = yytext; return TK_VALOR_LOGICO; }
"false"		{ yylval.valor = yytext; return TK_VALOR_LOGICO; }
{ID}		{ yylval.label = yytext; return TK_ID; }

("//"[^\n]*)|("/*"[^"*/"]*"*/")			{}

.			{ *yytext; }

%%
