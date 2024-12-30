%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

void yyerror(const char *s);
int yylex();
extern int yyparse();
extern ASTNode *root;
%}

/* Definição de tokens */
%token INT VOID IF ELSE WHILE RETURN ID NUM
%token PLUS MINUS MULT DIV ASSIGN
%token EQ LT LE GT GE NEQ
%token LPAREN RPAREN LBRACE RBRACE SEMI COMMA
%token LSBRACK RSBRACK ERROR

%define parse.error verbose

%left PLUS MINUS
%left MULT DIV
%left LT GT LE GE

/* Tipos de dados para a AST */
%union {
    struct ASTNode *node;
    char *string;
    int number;
}

/* Associe os tipos dos símbolos aos campos no %union */
%type <node> params program decl_list decl stmt_list stmt expr cond loop block
%type <string> type_specifier ID
%type <number> NUM

%%
/* Gramática */
program:
    decl_list {
        root = createNode("program", $1, NULL);
    }
;

decl_list:
    decl_list decl {
        $$ = appendNode($1, $2);
    }
    | decl {
        $$ = $1;
    }
    | /* vazio */ {
        $$ = NULL;
    }
;

decl:
    type_specifier ID SEMI {
        $$ = createNode("decl", createLeaf("type", $1), createLeaf("id", $2));
    }
    | type_specifier ID LPAREN RPAREN block {
        $$ = createNode("function", createLeaf("id", $2), $5);
    }
    | type_specifier ID LPAREN params RPAREN block {
        $$ = createNode("function", createLeaf("id", $2), $6);
    }
;

params:
    VOID {
        $$ = NULL;  // Lista de parâmetros vazia
    }
    | /* vazio */ {
        $$ = NULL;  // Nenhum parâmetro
    }
;

type_specifier:
    INT { $$ = "int"; }
    | VOID { $$ = "void"; }
;

stmt_list:
    stmt_list stmt {
        $$ = appendNode($1, $2);
    }
    | stmt {
        $$ = $1;
    }
;

stmt:
    expr SEMI {
        $$ = $1;
    }
    | RETURN expr SEMI {
        $$ = createNode("return", $2, NULL);
    }
    | cond
    | loop
    | block
;

cond:
    IF LPAREN expr RPAREN stmt {
        $$ = createNode("if", $3, $5);
    }
    | IF LPAREN expr RPAREN stmt ELSE stmt {
        $$ = createNode("if-else", createNode("if", $3, $5), $7);
    }
;

loop:
    WHILE LPAREN expr RPAREN stmt {
        $$ = createNode("while", $3, $5);
    }
;

block:
    LBRACE stmt_list RBRACE {
        $$ = createNode("block", $2, NULL);
    }
    | LBRACE RBRACE {
        $$ = createNode("block", NULL, NULL);  // Bloco vazio
    }
;

expr:
    ID ASSIGN expr {
        $$ = createNode("assign", createLeaf("id", $1), $3);
    }
    | expr PLUS expr {
        $$ = createNode("add", $1, $3);
    }
    | expr MINUS expr {
        $$ = createNode("sub", $1, $3);
    }
    | expr MULT expr {
        $$ = createNode("mul", $1, $3);
    }
    | expr DIV expr {
        $$ = createNode("div", $1, $3);
    }
    | expr LT expr {
        $$ = createNode("lt", $1, $3);
    }
    | expr GT expr {
        $$ = createNode("gt", $1, $3);
    }
    | NUM {
        char buffer[20];
        snprintf(buffer, sizeof(buffer), "%d", $1);
        $$ = createLeaf("num", strdup(buffer));
    }
    | ID {
        $$ = createLeaf("id", $1);
    }
    | LPAREN expr RPAREN {
        $$ = $2;  // Ignorar parênteses
    }
;
%%
/* Tratamento de erros */
void yyerror(const char *s) {
    extern char *yytext;  // Token atual
    extern int line_number;  // Número da linha
    fprintf(stderr, "Erro: %s próximo a '%s' na linha %d\n", s, yytext, line_number);
}

ASTNode *root = NULL;  // Raiz da ASA

int main() {
    if (yyparse() == 0) {  // Retorna 0 se a análise for bem-sucedida
        printf("Árvore de Sintaxe Abstrata (ASA):\n");
        printAST(root);  // Imprime a ASA gerada
        printf("\n");
    } else {
        printf("Erro durante a análise sintática.\n");
    }
    return 0;
}