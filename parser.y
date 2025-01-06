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
%token INT VOID IF ELSE WHILE RETURN ID NUM FOR
%token PLUS MINUS MULT DIV ASSIGN DECREMENT INCREMENT
%token EQ LT LE GT GE NEQ
%token LPAREN RPAREN LBRACE RBRACE SEMI COMMA
%token LSBRACK RSBRACK ERROR

%define parse.error verbose

%right MINUS PLUS
%left MULT DIV
%left LT GT LE GE


/* Tipos de dados para a AST */
%union {
    struct ASTNode *node;
    char *string;
    int number;
}

/* Associe os tipos dos símbolos aos campos no %union */
%type <node> param param_list params program decl_list decl stmt_list stmt expr cond loop block array_access var_list var update_expr arg_list
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
    type_specifier var_list SEMI {
        $$ = createNode("var-decl", createLeaf("type", $1), $2);
    }
    | type_specifier ID LPAREN RPAREN block {
        $$ = createNode("function", createLeaf("id", $2), $5);
    }
    | type_specifier ID LPAREN params RPAREN block {
        $$ = createNode("function", createLeaf("id", $2), $6);
    }
;

var:
    ID {
        $$ = createLeaf("id", $1);
    }
    | ID ASSIGN expr {
        $$ = createNode("var-init", createLeaf("id", $1), $3);
    }
    | ID LSBRACK expr RSBRACK {
        $$ = createNode("array-access", createLeaf("id", $1), $3);
    }
;

var_list:
    var_list COMMA var {
        $$ = appendNode($1, $3);
    }
    | var {
        $$ = $1;
    }
;

params:
    VOID {
        $$ = NULL;  // Lista de parâmetros vazia
    }
    | /* vazio */ {
        $$ = NULL;  // Nenhum parâmetro
    }
    | param_list {
        $$ = $1;  // Lista de parâmetros fornecida
    }
;

param_list:
    param_list COMMA param {
        $$ = appendNode($1, $3);
    }
    | param {
        $$ = $1;
    }
;

param:
    type_specifier ID {
        $$ = createNode("param", createLeaf("type", $1), createLeaf("id", $2));
    }
    | type_specifier ID LSBRACK RSBRACK {
        $$ = createNode("param-array", createLeaf("type", $1), createLeaf("id", $2));
    }
    | type_specifier LSBRACK RSBRACK ID {
        $$ = createNode("param-array", createLeaf("type", $1), createLeaf("id", $4));
    }
;

arg_list:
    arg_list COMMA expr {
        $$ = appendNode($1, $3);
    }
    | expr {
        $$ = $1;
    }
    | /* vazio */ {
        $$ = NULL;  // Nenhum argumento
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
    | decl {
        $$ = $1;  // Aceitar declarações no contexto de stmt_list
    }
    | /* vazio */ {
        $$ = NULL;
    }
;

stmt:
    var ASSIGN expr SEMI {
        $$ = createNode("assign", $1, $3);
    }
    | var INCREMENT SEMI {
        $$ = createNode("post-increment", $1, NULL);
    }
    | var DECREMENT SEMI {
        $$ = createNode("post-decrement", $1, NULL);
    }
    | decl {
        $$ = $1;  // Aceita declarações dentro de blocos
    }
    | expr SEMI {
        $$ = $1;
    }
    | RETURN expr SEMI {
        $$ = createNode("return", $2, NULL);
    }
    | RETURN SEMI {
        $$ = createNode("return", NULL, NULL);
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

update_expr:
    INCREMENT var {
        $$ = createNode("increment", $2, NULL);
    }
    | DECREMENT var {
        $$ = createNode("decrement", $2, NULL);
    }
    | expr {
        $$ = $1;
    }
;


loop:
    WHILE LPAREN expr RPAREN stmt {
        $$ = createNode("while", $3, $5);
    }
    | FOR LPAREN expr SEMI expr SEMI update_expr RPAREN stmt {
        ASTNode *initNode = createNode("init", $3, NULL);
        ASTNode *condNode = createNode("condition", $5, NULL);
        $$ = createNode("for", initNode, createNode("for-body", condNode, createNode("update", $7, $9)));
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

/* Nova regra para acessos a arrays */
array_access:
    ID LSBRACK expr RSBRACK {
        $$ = createNode("array-access", createLeaf("id", $1), $3);
    }
;

expr:
    MINUS expr %prec MINUS {
        $$ = createNode("neg", $2, NULL);
    }
    | ID ASSIGN expr {
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
    | expr LE expr {
        $$ = createNode("le", $1, $3);
    }
    | expr GE expr {
        $$ = createNode("ge", $1, $3);
    }
    | expr EQ expr {
        $$ = createNode("eq", $1, $3);
    }
    | expr NEQ expr {
        $$ = createNode("neq", $1, $3);
    }
    | ID LSBRACK expr RSBRACK {
        $$ = createNode("array-access", createLeaf("id", $1), $3);
    }
    | array_access ASSIGN expr {
        $$ = createNode("assign", $1, $3);
    }
    | NUM {
        char buffer[20];
        snprintf(buffer, sizeof(buffer), "%d", $1);
        $$ = createLeaf("num", strdup(buffer));
    }
    | ID {
        $$ = createLeaf("id", $1);
    }
    | ID LPAREN arg_list RPAREN {
        $$ = createNode("func-call", createLeaf("id", $1), $3);
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
    if (yyparse() == 0) {
        printf("Análise concluída com sucesso.\n");
        FILE *outputFile = fopen("output.asm", "w");
        if (outputFile) {
            printAST(root);
            generateMIPS(root, outputFile);
            fclose(outputFile);
            printf("Código Assembly MIPS gerado em 'output.asm'.\n");
        } else {
            fprintf(stderr, "Erro ao abrir o arquivo para saída.\n");
        }
    } else {
        printf("Erro durante a análise sintática.\n");
    }
    return 0;
}