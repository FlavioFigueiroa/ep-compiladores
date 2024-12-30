%option noyywrap
%{
#include <stdio.h>
#include <string.h>

int line_number = 1;

void return_token(const char *lexeme, const char *token, const char *attribute) {
    printf("Lexeme: %s, Token: %s, Atributo: %s, Linha: %d\n", lexeme, token, attribute, line_number);
}
%}

/* Definir expressões regulares */
letter          [a-zA-Z]
digit           [0-9]
identifier      {letter}+
number          {digit}+

/* Definir tokens */
%%
"if"            { return_token(yytext, "KEYWORD", "IF"); }
"else"          { return_token(yytext, "KEYWORD", "ELSE"); }
"while"         { return_token(yytext, "KEYWORD", "WHILE"); }
"return"        { return_token(yytext, "KEYWORD", "RETURN"); }
"int"           { return_token(yytext, "KEYWORD", "INT"); }
"void"          { return_token(yytext, "KEYWORD", "VOID"); }

"+"             { return_token(yytext, "ARITHOP", "PLUS"); }
"-"             { return_token(yytext, "ARITHOP", "MINUS"); }
"*"             { return_token(yytext, "ARITHOP", "MULT"); }
"/"             { return_token(yytext, "ARITHOP", "DIV"); }

"="             { return_token(yytext, "ASSIGN", "="); }
"=="            { return_token(yytext, "RELOP", "EQ"); }
"<"             { return_token(yytext, "RELOP", "LT"); }
"<="            { return_token(yytext, "RELOP", "LE"); }
">"             { return_token(yytext, "RELOP", "GT"); }
">="            { return_token(yytext, "RELOP", "GE"); }
"!="            { return_token(yytext, "RELOP", "NEQ"); }

"("             { return_token(yytext, "LPAREN", "("); }
")"             { return_token(yytext, "RPAREN", ")"); }
"{"             { return_token(yytext, "LBRACE", "{"); }
"}"             { return_token(yytext, "RBRACE", "}"); }
";"             { return_token(yytext, "SEMI", ";"); }
","             { return_token(yytext, "COMMA", ","); }
"["             { return_token(yytext, "LSBRACK", "["); }
"]"             { return_token(yytext, "RSBRACK", "]"); }


{identifier}    { 
                    return_token(yytext, "ID", "IDENTIFIER"); 
                }
{number}        { 
                    return_token(yytext, "NUMBER", "CONST"); 
                }

"//".*          { /* Ignorar o comentário de linha única */ }

"/*"            {
		    char c;

		    while (1) {
			c = input(); 
			if (c == '*') { 
			    c = input();
			    if (c == '/') break;
			} else if (c == '\n') { 
			    line_number++; 
			} else if (c == 0) { 
			    printf("Erro: comentário multi-linha não fechado na linha %d\n", line_number);
			    break; 
			}
		    };
		}

\n              { line_number++; }

[ \t]+          { /* Ignorar espaços e tabulações */ }

.               { printf("Erro: caractere inválido '%s' na linha %d\n", yytext, line_number); }

%%

int main(void) {
    yylex();  // Chama o lexer
    return 0;
}

int get_token(void) {
    int cur_token = yylex();
    return cur_token;
}
