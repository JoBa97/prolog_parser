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

def:  VAR_ID /* TODO */
      ;

pred: CONST_ID POPEN params PCLOSE {fprintf(stderr, "\tbison: pred:\tfCONST_ID POPEN params PCLOSE\n");}
      | CONST_ID {fprintf(stderr, "\tbison: pred:\tfCONST_ID\n");}
      ;

params: param COMMA params {}
        | param {}
        ;

param: CONST_ID {}
       | VAR_ID {}
       | ANONYMOUS {}
       | number {}
       | list {}
       ;

number: VAR_ID  {}
        | INT   {}
        | FLOAT {}
        | SUB number {}
        ;

list: LOPEN lelements LCLOSE {}
		  |	LOPEN lelements PIPE list {}
		  |	LOPEN lelements PIPE id {}
		  |	LOPEN LCLOSE {}
		  ;

lelements: lelement COMMA {}
			     | lelement {}
			     ;

id_const: id {}
	       | CONST_ID {}
	       ;

id: VAR_ID {}
	  | ANONYMOUS {}
	  ;

lelement:	id_const {}
			    | number {}
			    | list {}
			    ;

%%

int main(int, char**) {
	yyparse();
}
