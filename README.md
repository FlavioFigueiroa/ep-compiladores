# EP - Primeira Parte

Como compilar
```bash
flex lexer_test_version.l 
gcc lex.yy.c -o lexer -lm 
```

Como executar os testes no windows:
```bash
Get-Content .\test-lexer\prg7.c- | .\lexer.exe   