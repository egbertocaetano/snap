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

"int"			{ yylval.tipo = yytext; return TK_TIPO;}
"char"			{ yylval.tipo = yytext; return TK_TIPO;}
"double"		{ yylval.tipo = yytext; return TK_TIPO;}
"float"			{ yylval.tipo = yytext; return TK_TIPO;}
"string"		{ yylval.tipo = yytext; return TK_TIPO;}

"="			{return *yytext; }

[(){}[\];,]	{ return *yytext; }

[+\-*/]		{ return *yytext; }

"&&"			{ yylval.operadorLogico = yytext; return TK_OPERADOR_LOGICO; }
"||"			{ yylval.operadorLogico = yytext; return TK_OPERADOR_LOGICO; }
"<"				{ yylval.operadorLogico = yytext; return TK_OPERADOR_LOGICO; }
">"				{ yylval.operadorLogico = yytext; return TK_OPERADOR_LOGICO; }
"<="			{ yylval.operadorLogico = yytext; return TK_OPERADOR_LOGICO; }
">="			{ yylval.operadorLogico = yytext; return TK_OPERADOR_LOGICO; }
"=="			{ yylval.operadorLogico = yytext; return TK_OPERADOR_LOGICO; }
"!="			{ yylval.operadorLogico = yytext; return TK_OPERADOR_LOGICO; }


{NUM}		{ yylval.valor = yytext; return TK_NUM; }
{ID}		{ yylval.label = yytext; return TK_ID; }

("//"[^\n]*)|("/*"[^"*/"]*"*/")			{}

.			{ *yytext; }

%%
