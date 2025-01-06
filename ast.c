#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

// Gerenciamento de Tabela de Símbolos e Estado Global
typedef struct {
    char *name;
    int offset;
} Variable;

typedef struct {
    char *name;  // Nome da variável ou operação
    int offset;  // Deslocamento na pilha
} State;

// Variáveis globais
Variable symbolTable[100];
int currentOffset = 0;

State globalState[200];
int globalStateCount = 0;

// Declarações de funções auxiliares
void addVariable(char *name);
int getVariableOffset(char *name);
void printSymbolTable();
int findInState(char *name);
void addToState(char *name, int offset);

// Estrutura de um nó da AST
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

// Função auxiliar para imprimir a AST
void printASTHelper(ASTNode *root, int depth) {
    if (!root) return;

    for (int i = 0; i < depth; i++) {
        printf("  ");
    }

    printf("(%s", root->type);

    if (root->value) {
        printf(": %s", root->value);
    }
    printf(")\n");

    if (root->left) {
        printASTHelper(root->left, depth + 1);
    }
    if (root->right) {
        printASTHelper(root->right, depth);
    }
}

char *generateLabel() {
    char *label = (char *)malloc(20 * sizeof(char));
    sprintf(label, "L%d", currentOffset++);
    return label;
}

// Função para geração de código MIPS
void generateMIPS(ASTNode *root, FILE *outputFile) {
    if (!root) return;

    if (strcmp(root->type, "program") == 0) {
        fprintf(outputFile, ".text\n.globl main\nmain:\n");
        generateMIPS(root->left, outputFile);
        fprintf(outputFile, "li $v0, 10\nsyscall\n");
    } else if (strcmp(root->type, "function") == 0) {
        fprintf(outputFile, "# Função: %s\n", root->left->value);
        generateMIPS(root->right, outputFile);
    } else if (strcmp(root->type, "block") == 0) {
        ASTNode *current = root->left;
        while (current) {
            generateMIPS(current, outputFile);
            current = current->right;
        }
    } else if (strcmp(root->type, "var-init") == 0) {
        int offset = getVariableOffset(root->left->value);
        if (offset == -1) {
            addVariable(root->left->value);
            offset = getVariableOffset(root->left->value);
        }
        if (findInState(root->left->value) == -1) { // Inicializa apenas se necessário
            generateMIPS(root->right, outputFile);
            fprintf(outputFile, "sw $t0, -%d($sp)\n", offset);
            addToState(root->left->value, offset);
        }
    } else if (strcmp(root->type, "add") == 0) {
        char expression[100];
        sprintf(expression, "add(%s,%s)", root->left->value, root->right->value);

        int cachedOffset = findInState(expression);
        if (cachedOffset != -1) { // Reutiliza o resultado da operação
            fprintf(outputFile, "lw $t0, -%d($sp)\n", cachedOffset);
        } else {
            generateMIPS(root->left, outputFile);  // Calcula lado esquerdo
            fprintf(outputFile, "move $t1, $t0\n"); // Move para $t1
            generateMIPS(root->right, outputFile); // Calcula lado direito
            fprintf(outputFile, "add $t0, $t1, $t0\n");

            int tempOffset = currentOffset; // Armazena o resultado
            fprintf(outputFile, "sw $t0, -%d($sp)\n", tempOffset);
            currentOffset += 4;
            addToState(expression, tempOffset); // Marca como armazenado
        }
    } else if (strcmp(root->type, "return") == 0) {
        generateMIPS(root->left, outputFile);
        fprintf(outputFile, "move $v0, $t0\n");
    } else if (strcmp(root->type, "num") == 0) {
        if (findInState(root->value) == -1) {
            fprintf(outputFile, "li $t0, %s\n", root->value);
            addToState(root->value, currentOffset);
        }
    } else if (strcmp(root->type, "id") == 0) {
        int offset = getVariableOffset(root->value);
        if (offset == -1) {
            fprintf(stderr, "Erro: variável '%s' não encontrada.\n", root->value);
            exit(1);
        }
        if (findInState(root->value) == -1) { // Carrega apenas se necessário
            fprintf(outputFile, "lw $t0, -%d($sp)\n", offset);
            addToState(root->value, offset);
        }
    }
}

// Gerenciamento de Tabela de Símbolos
void addVariable(char *name) {
    if (getVariableOffset(name) != -1) return;
    symbolTable[currentOffset / 4].name = strdup(name);
    symbolTable[currentOffset / 4].offset = currentOffset;
    currentOffset += 4;
}

int getVariableOffset(char *name) {
    for (int i = 0; i < currentOffset / 4; i++) {
        if (strcmp(symbolTable[i].name, name) == 0) {
            return symbolTable[i].offset;
        }
    }
    return -1;
}

void printSymbolTable() {
    printf("Tabela de Símbolos:\n");
    for (int i = 0; i < currentOffset / 4; i++) {
        printf("Nome: %s, Offset: %d\n", symbolTable[i].name, symbolTable[i].offset);
    }
}

// Controle de Estado Global
int findInState(char *name) {
    for (int i = 0; i < globalStateCount; i++) {
        if (strcmp(globalState[i].name, name) == 0) {
            return globalState[i].offset;
        }
    }
    return -1;
}

void addToState(char *name, int offset) {
    globalState[globalStateCount].name = strdup(name);
    globalState[globalStateCount].offset = offset;
    globalStateCount++;
}

// Imprime a AST
void printAST(ASTNode *root) {
    printASTHelper(root, 0);
}
