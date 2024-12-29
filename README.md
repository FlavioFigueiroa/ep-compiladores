# ep-compiladores

Como compilar o projeto:

```bash
flex lexer.l  
bison -d parser.y  
gcc -o parser parser.tab.c lex.yy.c ast.c globals.c -lm   
```

Como executar os testes no windows:
```bash
Get-Content ..\tests\prg1.c- | .\parser.exe    