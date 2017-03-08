%{
#include <stdlib.h>
#include <stdio.h>

extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;
extern "C" int lines;
extern "C" char* yytext;

void yyerror(const char *s) {
  fprintf (stderr, "Parser error in line %d:\n%s\n", lines, s);
}

%}

%token IS
%token CONST_ID
%token VAR_ID
%token FLOAT
%token INT
%token ANONYMOUS
%token POPEN
%token PCLOSE
%token DOT
%token DEF
%token LOPEN
%token LCLOSE
%token COMMA
%token PIPE
%token ADD
%token SUB
%token MUL
%token DIV
%token EQUALS
%token UNEQUAL
%token SMALLER_EQ
%token LARGER_EQ
%token SMALLER
%token LARGER

%%

start: cmds {fprintf(stderr, "\tbison: start:\tcmds\n");}
       ;

cmds:   cmd DOT cmds {fprintf(stderr, "\tbison: cmds:\tcmd cmds\n");}
      | cmd DOT     {fprintf(stderr, "\tbison: cmds:\tcmd\n");}
      ;

cmd: VAR_ID {}
    | CONST_ID {}
    ;

%%

int main(int, char**) {
	yyparse();
}
