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
STRING [\"].*[\"]|[\'].*[\']

%%

"\n"		{}

{DELIM} 	{}

"main"		{return TK_MAIN;}

"int"			{ yylval.tipo = yytext; return TK_TIPO_INT;}
"char"			{ yylval.tipo = yytext; return TK_TIPO_CHAR;}
"float"			{ yylval.tipo = yytext; return TK_TIPO_FLOAT;}
"string"		{ yylval.tipo = yytext; return TK_TIPO_STRING;}
"boolean"		{ yylval.tipo = yytext; return TK_TIPO_BOOLEAN;}
"if"			{ return TK_IF;}
"else"			{ return TK_ELSE;}
"elif"			{ return TK_ELIF;}
"for"			{ return TK_FOR;}
"while"			{ return TK_WHILE;}
"do"            { return TK_DO;}
"break"			{ return TK_BREAK;}
"continue"		{ return TK_CONTINUE;}
"switch"		{ return TK_SWITCH;}
"case"			{ return TK_CASE;}
"default"		{ return TK_DEFAULT;}
"write"			{ return TK_WRITE;}
"read"			{ return TK_READ;}

"="			{yylval.operador = yytext; return TK_ATRIBUICAO;}

[(){}[\];,]	{ return *yytext; }

[+\-*/]			{yylval.operador = yytext; return TK_OPERADOR_MATEMATICO; }

"&&"			{ yylval.operador = yytext; return TK_OPERADOR_RELACIONAL; }
"||"			{ yylval.operador = yytext; return TK_OPERADOR_RELACIONAL; }
"<"			{ yylval.operador = yytext; return TK_OPERADOR_LOGICO; }
">"			{ yylval.operador = yytext; return TK_OPERADOR_LOGICO; }
"<="			{ yylval.operador = yytext; return TK_OPERADOR_LOGICO; }
">="			{ yylval.operador = yytext; return TK_OPERADOR_LOGICO; }
"=="			{ yylval.operador = yytext; return TK_OPERADOR_LOGICO; }
"!="			{ yylval.operador = yytext; return TK_OPERADOR_LOGICO; }
"++"            { yylval.operador = yytext; return TK_OPERADOR_CREMENTO; }
"--"            { yylval.operador = yytext; return TK_OPERADOR_CREMENTO; }

{NUM}		{ yylval.valor = yytext; yylval.tipo = "int"; return TK_NUM; }
{REAL}		{ yylval.valor = yytext; yylval.tipo = "float"; return TK_REAL; }
{CHAR}		{ yylval.valor = yytext; yylval.tipo = "char"; return TK_CHAR; }
{STRING}	{ yylval.valor = yytext; yylval.tipo = "string"; return TK_STRING; }
"TRUE"		{ yylval.valor = yytext; yylval.tipo = "boolean"; return TK_VALOR_LOGICO; }
"FALSE"		{ yylval.valor = yytext; yylval.tipo = "boolean"; return TK_VALOR_LOGICO; }
{ID}		{ yylval.label = yytext; return TK_ID; }

("//"[^\n]*)|("/*"[^"*/"]*"*/")			{}

.			{ *yytext; }

%%
