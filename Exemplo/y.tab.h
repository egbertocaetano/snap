/* A Bison parser, made by GNU Bison 2.5.  */

/* Bison interface for Yacc-like parsers in C
   
      Copyright (C) 1984, 1989-1990, 2000-2011 Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     TK_NUM = 258,
     TK_REAL = 259,
     TK_VALOR_LOGICO = 260,
     TK_CHAR = 261,
     TK_MAIN = 262,
     TK_ID = 263,
     TK_IF = 264,
     TK_FIM = 265,
     TK_ERROR = 266,
     TK_OPERADOR_LOGICO = 267,
     TK_OPERADOR_RELACIONAL = 268,
     TK_OPERADOR_MATEMATICO = 269,
     TK_ATRIBUICAO = 270,
     TK_TIPO_INT = 271,
     TK_TIPO_CHAR = 272,
     TK_TIPO_FLOAT = 273,
     TK_TIPO_STRING = 274,
     TK_TIPO_BOOLEAN = 275
   };
#endif
/* Tokens.  */
#define TK_NUM 258
#define TK_REAL 259
#define TK_VALOR_LOGICO 260
#define TK_CHAR 261
#define TK_MAIN 262
#define TK_ID 263
#define TK_IF 264
#define TK_FIM 265
#define TK_ERROR 266
#define TK_OPERADOR_LOGICO 267
#define TK_OPERADOR_RELACIONAL 268
#define TK_OPERADOR_MATEMATICO 269
#define TK_ATRIBUICAO 270
#define TK_TIPO_INT 271
#define TK_TIPO_CHAR 272
#define TK_TIPO_FLOAT 273
#define TK_TIPO_STRING 274
#define TK_TIPO_BOOLEAN 275




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;

