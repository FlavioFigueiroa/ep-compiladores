%option noyywrap
%{
#include <stdio.h>
#include <string.h>
#include "parser.tab.h"

int line_number = 1;

%}

/* Definir expressões regulares */
letter          [a-zA-Z]
digit           [0-9]
identifier      {letter}+
number          {digit}+

/* Definir tokens */
%%
"if"            { return IF; }
"else"          { return ELSE; }
"while"         { return WHILE; }
"for"			{ return FOR; }
"return"        { return RETURN; }
"int"           { return INT; }
"void"          { return VOID; }

"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return MULT; }
"/"             { return DIV; }
"--"			{ return DECREMENT; }
"++"			{ return INCREMENT; }

"="             { return ASSIGN; }
"=="            { return EQ; }
"<"             { return LT; }
"<="            { return LE; }
">"             { return GT; }
">="            { return GE; }
"!="            { return NEQ; }

"("             { return LPAREN; }
")"             { return RPAREN; }
"{"             { return LBRACE; }
"}"             { return RBRACE; }
";"             { return SEMI; }
","             { return COMMA; }
"["             { return LSBRACK; }
"]"             { return RSBRACK; }

{identifier} { yylval.string = strdup(yytext); return ID; }
{number} { yylval.number = atoi(yytext); return NUM; }

"//".*          { /* Ignorar o comentário de linha única */ }

"/*"            {
		    char c;
		    while (1) {
			    c = input();
			    if (c == '*') { 
			        c = input();
			        if (c == '/') break; // Fechar o comentário
			    } else if (c == '\n') {
			        line_number++;
			    } else if (c == 0) { // EOF dentro do comentário
			        return ERROR;  // Retorna um token de erro para o parser
			    }
		    }
		}

\n              { line_number++; }


[ \t]+          { /* Ignorar espaços e tabulações */ }

. { fprintf(stderr, "Erro léxico: caractere inválido '%s' na linha %d\n", yytext, line_number); return ERROR; }

%%

int get_token(void) {
    return yylex();  // Função auxiliar para retornar tokens ao parser
}

