#ifndef AST_H
#define AST_H

typedef struct ASTNode {
    char *type;
    char *value;
    struct ASTNode *left;
    struct ASTNode *right;
} ASTNode;

/* Funções para manipular a AST */
ASTNode *createNode(char *type, ASTNode *left, ASTNode *right);
ASTNode *createLeaf(char *type, char *value);
ASTNode *appendNode(ASTNode *list, ASTNode *node);
void printAST(ASTNode *root);

#endif
