# EP - Segunda parte - Parser

Como compilar
```bash
bison -d parser.y
flex lexer.l  
gcc -o parser parser.tab.c lex.yy.c ast.c -lm
```

Como executar os testes no windows:
```bash
Get-Content .\teste.c- | .\parser.exe 
Get-Content .\test-lexer\prg1.c- | .\parser.exe