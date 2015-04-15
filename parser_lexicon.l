%{
#define D	300
#define O	301
#define H	302
#define F	303
#define B	304
#define X	399

%}
DIGITO [0-9]
LETRA [A-Za-z]
ESPACO [\t]



%%
{DIGITO}+\.{DIGITO}+			{return printf("Encontrei um flutuador\n");} 
\'({LETRA}|{DIGITO})\'			{return printf("Encontrei um CARACTERE\n");}
0[0-7]+							{return printf("Encontrei um OCTAL\n");}
[1-9]{DIGITO}*					{return printf("Encontrei um DECIMAL\n");}
0[x | X][0-9A-Fa-f]+			{return printf("Encontrei um HEXADECIMAL\n");}

"pare"			{ return printf("Encontrei um pare\n");; }
"caso"			{ return printf("Encontrei caso\n");}
"constante"		{ return printf("Encontrei constante\n");}
"continue"		{ return printf("Encontrei continue\n"); }
"padrao"		{ return printf("Encontrei padrao\n");}
"faca"			{ return printf("Encontrei faca\n");}
"se"			{ return printf("Encontrei se\n");}
"!se"			{ return printf("Encontrei !se\n");}
"para"			{ return printf("Encontrei para\n");}
"vaipara"		{ return printf("Encontrei vaipara\n"); }
"registrador"	{ return printf("Encontrei registrador\n"); }
"retorna"		{ return printf("Encontrei retorna\n");}
"tamanhode"		{ return printf("Encontrei tamanhode\n");}
"estatico"		{ return printf("Encontrei estatico\n");}
"estrtura"		{ return printf("Encontrei estrutura\n");}
"alterne"		{ return printf("Encontrei alterne\n");}
"tipodef"		{ return printf("Encontrei tipodef\n"); }
"vazio"			{ return printf("Encontrei vazio\n");}
"enquanto"		{ return printf("Encontrei enquanto\n");}
"char"			{ return printf("Encontrei char\n");}
"double"		{ return printf("Encontrei double\n");}
"float"			{ return printf("Encontrei float\n");}
"int"			{ return printf("Encontrei int\n");}
"long"			{ return printf("Encontrei long\n");}
"signed"		{ return printf("Encontrei signed\n");}
"short"			{ return printf("Encontrei short\n");}
"unsigned"		{ return printf("Encontrei unsigned\n"); }

"..."			{ return printf("Encontrei ...\n"); }
">>="			{ return printf("Encontrei >>=\n"); }
"<<="			{ return printf("Encontrei <<=\n"); }
"+="			{ return printf("Encontrei +=\n"); }
"-="			{ return printf("Encontrei -=\n"); }
"*="			{ return printf("Encontrei *=\n");}
"/="			{ return printf("Encontrei /=\n"); }
"%="			{ return printf("Encontrei %=\n"); }
"&="			{ return printf("Encontrei &=\n"); }
"^="			{ return printf("Encontrei ^=\n"); }
"|="			{ return printf("Encontrei |=\n"); }
">>"			{ return printf("Encontrei >>\n"); }
"<<"			{ return printf("Encontrei <<\n"); }
"++"			{ return printf("Encontrei ++\n"); }
"--"			{ return printf("Encontrei --\n"); }
"->"			{ return printf("Encontrei ->\n"); }
"&&"			{ return printf("Encontrei &&\n"); }
"||"			{ return printf("Encontrei ||\n"); }
"<="			{ return printf("Encontrei <=\n"); }
">="			{ return printf("Encontrei >=\n"); }
"=="			{ return printf("Encontrei ==\n"); }
"!="			{ return printf("Encontrei !=\n"); }
";"				{ return printf("Encontrei ;\n"); }
"{"				{ return printf("Encontrei {\n"); }
"}"				{ return printf("Encontrei }\n"); }
"<%"			{ return printf("Encontrei <%\n"); }
"%>"			{ return printf("Encontrei %>\n"); }
","				{ return printf("Encontrei ,\n"); }
":"				{ return printf("Encontrei :\n"); }
"="				{ return printf("Encontrei =\n"); }
"("				{ return printf("Encontrei (\n");}
")"				{ return printf("Encontrei )\n"); }
"["				{ return printf("Encontrei [\n"); }	
"]"				{ return printf("Encontrei ]\n"); }
"<:"			{ return printf("Encontrei <:\n"); }
":>"			{ return printf("Encontrei :>\n"); }
"."				{ return printf("Encontrei .\n"); }
"&"				{ return printf("Encontrei &\n"); }
"!"				{ return printf("Encontrei !\n"); }
"~"				{ return printf("Encontrei ~\n"); }
"-"				{ return printf("Encontrei -\n"); }
"+"				{ return printf("Encontrei +\n"); }
"*"				{ return printf("Encontrei *\n"); }
"/"				{ return printf("Encontrei /\n"); }
"%"				{ return printf("Encontrei %\n"); }
"<"				{ return printf("Encontrei <\n"); }
">"				{ return printf("Encontrei >\n"); }
"^"				{ return printf("Encontrei ^:\n"); }
"|"				{ return printf("Encontrei |\n"); }
"?"				{ return printf("Encontrei ?\n"); }

[ \t\v\n\f]		{ return printf("Encontrei %s\n", yytext); }
.				{ return printf("%s", yytext); }
<<EOF>>			{ return X; }

%%

int main(int argc, char *argv[])
{
	FILE *f_in;
	int tipoToken;
	int totalDec = 0,
		totalOct = 0,
		totalHex = 0,
		totalFlt = 0;

	if(argc == 2)
	{
		if(f_in == fopen(argv[1], "r"))
		{
			yyin = f_in;
		}
		else
		{
			perror(argv[0]);
		}
	}
	else
	{
		yyin = stdin;
	}

	while((tipoToken = yylex()) != X)
	{
		
	}

}
