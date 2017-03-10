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

cmds:   cmd cmds {fprintf(stderr, "\tbison: cmds:\tcmd cmds\n");}
      | cmd     {fprintf(stderr, "\tbison: cmds:\tcmd\n");}
      ;

cmd: fact {fprintf(stderr, "\tbison: cmd:\tfact\n");}
    | def {fprintf(stderr, "\tbison: cmd:\tdef\n");}
    ;

fact: pred DOT {fprintf(stderr, "\tbison: fact:\tpred DOT\n");}
      ;

def:  DEF DOT /* TODO */
      ;

pred: CONST_ID POPEN params PCLOSE {fprintf(stderr, "\tbison: pred:\tCONST_ID POPEN params PCLOSE\n");}
      | CONST_ID {fprintf(stderr, "\tbison: pred:\tfCONST_ID\n");}
      ;

params: param COMMA params {fprintf(stderr, "\tbison: params:\tparam COMMA params\n");}
        | param {fprintf(stderr, "\tbison: params:\tparam\n");}
        ;

param: CONST_ID {fprintf(stderr, "\tbison: param:\tCONST_ID\n");}
       | VAR_ID {fprintf(stderr, "\tbison: param:\tVAR_ID\n");}
       | ANONYMOUS {fprintf(stderr, "\tbison: param:\tANONYMOUS\n");}
       | number {fprintf(stderr, "\tbison: param:\tnumber\n");}
       | list {fprintf(stderr, "\tbison: param:\tlist\n");}
       ;

number: INT {fprintf(stderr, "\tbison: number:\tINT\n");}
        | FLOAT {fprintf(stderr, "\tbison: number:\tFLOAT\n");}
        | SUB number {fprintf(stderr, "\tbison: number:\tSUB number\n");}
        ;

list: LOPEN lelements LCLOSE {fprintf(stderr, "\tbison: list:\tLOPEN lelements LCLOSE\n");}
		  |	LOPEN lelements PIPE list LCLOSE {fprintf(stderr, "\tbison: list:\tLOPEN lelements PIPE list LCLOSE\n");}
		  |	LOPEN lelements PIPE VAR_ID LCLOSE {fprintf(stderr, "\tbison: list:\tLOPEN lelements PIPE VAR_ID LCLOSE\n");}
      |	LOPEN lelements PIPE ANONYMOUS LCLOSE {fprintf(stderr, "\tbison: list:\tLOPEN lelements PIPE ANONYMOUS LCLOSE\n");}
		  |	LOPEN LCLOSE {fprintf(stderr, "\tbison: list:\tLOPEN LCLOSE\n");}
		  ;

lelements: lelement COMMA lelements {fprintf(stderr, "\tbison: lelements:\tlelement COMMA lelements\n");}
			     | lelement {fprintf(stderr, "\tbison: lelements:\tlelement\n");}
			     ;

lelement: CONST_ID {fprintf(stderr, "\tbison: lelement:\tCONST_ID\n");}
          | VAR_ID {fprintf(stderr, "\tbison: lelement:\tVAR_ID\n");}
          | ANONYMOUS {fprintf(stderr, "\tbison: lelement:\tANONYMOUS\n");}
			    | number {fprintf(stderr, "\tbison: lelement:\tnumber\n");}
			    | list {fprintf(stderr, "\tbison: lelement:\tlist\n");}
			    ;

%%

int main(int, char**) {
	yyparse();
}
