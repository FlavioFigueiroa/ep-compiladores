#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

ASTNode *createNode(char *type, ASTNode *left, ASTNode *right) {
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = strdup(type);
    node->value = NULL;
    node->left = left;
    node->right = right;
    return node;
}

ASTNode *createLeaf(char *type, char *value) {
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = strdup(type);
    node->value = strdup(value);
    node->left = NULL;
    node->right = NULL;
    return node;
}

ASTNode *appendNode(ASTNode *list, ASTNode *node) {
    if (!list) return node;
    ASTNode *temp = list;
    while (temp->right) temp = temp->right;
    temp->right = node;
    return list;
}

void printASTHelper(ASTNode *root, int depth) {
    if (!root) return;

    // Imprime os recuos para indicar a profundidade
    for (int i = 0; i < depth; i++) {
        printf("  ");
    }

    // Imprime o tipo do nó
    printf("(%s", root->type);

    // Imprime o valor, se existir
    if (root->value) {
        printf(": %s", root->value);
    }
    printf(")\n");

    // Chama recursivamente para os filhos
    if (root->left) {
        printASTHelper(root->left, depth + 1);
    }
    if (root->right) {
        printASTHelper(root->right, depth);
    }
}

void printAST(ASTNode *root) {
    printASTHelper(root, 0);
}
