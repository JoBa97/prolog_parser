%{
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <string>
#include <vector>

extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;
extern "C" int lines;

void yyerror(const char *s) {
  fprintf (stderr, "Parser error in line %d:\n%s\n", lines, s);
}

std::vector<std::string> preds;


%}


%token IS
%token<text> CONST_ID
%token<text> VAR_ID
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
%token MOD
%token EQUAL
%token UNEQUAL
%token SMALLER_EQ
%token LARGER_EQ
%token SMALLER
%token LARGER

%left EQUAL UNEQUAL SMALLER SMALLER_EQ LARGER LARGER_EQ
%left ADD SUB
%left MUL DIV
%left MOD

%right UMINUS

%union {
  char* text;
}

%%

start:
          cmds
        {fprintf(stderr, "\tbison: start:\tcmds\n");}
        ;

cmds:
          cmd cmds
        {fprintf(stderr, "\tbison: cmds:\tcmd cmds\n");}
        | cmd
        {fprintf(stderr, "\tbison: cmds:\tcmd\n");}
        ;

cmd:
          fact
        {fprintf(stderr, "\tbison: cmd:\tfact\n");}
        | def
        {fprintf(stderr, "\tbison: cmd:\tdef\n");}
        ;

fact:
          pred DOT
        {fprintf(stderr, "\tbison: fact:\tpred DOT\n");}
        ;

pred:
          CONST_ID POPEN params PCLOSE
        { fprintf(stderr, "\tbison: pred:\tCONST_ID POPEN params PCLOSE\n");
          std::string sym($1);
          free($1);
          std::cerr << "ID: " << sym << std::endl;
          preds.push_back(sym);
        }
        | CONST_ID
        { fprintf(stderr, "\tbison: pred:\tfCONST_ID\n");
          std::string sym($1);
          free($1);
          std::cerr << "ID: " << sym << std::endl;
          preds.push_back(sym);
        }
        ;

params:
          param COMMA params
        {fprintf(stderr, "\tbison: params:\tparam COMMA params\n");}
        | param
        {fprintf(stderr, "\tbison: params:\tparam\n");}
        ;

param:
          CONST_ID
        {fprintf(stderr, "\tbison: param:\tCONST_ID\n");
          std::string sym($1);
          free($1);
          std::cerr << "ID: " << sym << std::endl;
        }
        | VAR_ID
        {fprintf(stderr, "\tbison: param:\tVAR_ID\n");
          std::string sym($1);
          free($1);
          std::cerr << "ID: " << sym << std::endl;
        }
        | ANONYMOUS
        {fprintf(stderr, "\tbison: param:\tANONYMOUS\n");}
        | number
        {fprintf(stderr, "\tbison: param:\tnumber\n");}
        | SUB number
        {fprintf(stderr, "\tbison: param:\tSUB number\n");}
        | list
        {fprintf(stderr, "\tbison: param:\tlist\n");}
        ;

number:
          INT
        {fprintf(stderr, "\tbison: number:\tINT\n");}
        | FLOAT
        {fprintf(stderr, "\tbison: number:\tFLOAT\n");}
        ;

list:
          LOPEN lelements LCLOSE
        {fprintf(stderr, "\tbison: list:\tLOPEN lelements LCLOSE\n");}
  		  |	LOPEN lelements PIPE list LCLOSE
        {fprintf(stderr, "\tbison: list:\tLOPEN lelements PIPE list LCLOSE\n");}
  		  |	LOPEN lelements PIPE VAR_ID LCLOSE
        { fprintf(stderr, "\tbison: list:\tLOPEN lelements PIPE VAR_ID LCLOSE\n");
          std::string sym($4);
          free($4);
          std::cerr << "ID: " << sym << std::endl;
        }
        |	LOPEN lelements PIPE ANONYMOUS LCLOSE
        {fprintf(stderr, "\tbison: list:\tLOPEN lelements PIPE ANONYMOUS LCLOSE\n");}
  		  |	LOPEN LCLOSE
        {fprintf(stderr, "\tbison: list:\tLOPEN LCLOSE\n");}
  		  ;

lelements:
          lelement COMMA lelements
        {fprintf(stderr, "\tbison: lelements:\tlelement COMMA lelements\n");}
        | lelement
        {fprintf(stderr, "\tbison: lelements:\tlelement\n");}
        ;

lelement:
          CONST_ID
        {fprintf(stderr, "\tbison: lelement:\tCONST_ID\n");
          std::string sym($1);
          free($1);
          std::cerr << "ID: " << sym << std::endl;
        }
        | VAR_ID
        {fprintf(stderr, "\tbison: lelement:\tVAR_ID\n");
          std::string sym($1);
          free($1);
          std::cerr << "ID: " << sym << std::endl;
        }
        | ANONYMOUS
        {fprintf(stderr, "\tbison: lelement:\tANONYMOUS\n");}
		    | number
        {fprintf(stderr, "\tbison: lelement:\tnumber\n");}
        | SUB number
        {fprintf(stderr, "\tbison: lelement:\tnumber\n");}
		    | list
        {fprintf(stderr, "\tbison: lelement:\tlist\n");}
		    ;

def:
          pred DEF expressions DOT
        {fprintf(stderr, "\tbison: def:\tpred DEF expressions DOT\n");}
        ;

expressions:
          expression COMMA expressions
        {fprintf(stderr, "\tbison: expression:\texpression COMMA expressions\n");}
        | expression
        {fprintf(stderr, "\tbison: expression:\texpression\n");}
        ;

expression:
          pred
        {fprintf(stderr, "\tbison: expression:\tpred\n");}
        | is_expr
        {fprintf(stderr, "\tbison: expression:\tis_expr\n");}
        | bool_expr
        {fprintf(stderr, "\tbison: expression:\tbool_expr\n");}
        ;

comp_operator:
          EQUAL
        {fprintf(stderr, "\tbison: comp_operator:\tEQUAL\n");}
	      | UNEQUAL
        {fprintf(stderr, "\tbison: comp_operator:\tUNEQUAL\n");}
	      | SMALLER_EQ
        {fprintf(stderr, "\tbison: comp_operator:\tSMALLER_EQ\n");}
	      | LARGER_EQ
        {fprintf(stderr, "\tbison: comp_operator:\tLARGER_EQ\n");}
	      | SMALLER
        {fprintf(stderr, "\tbison: comp_operator:\tSMALLER\n");}
	      | LARGER
        {fprintf(stderr, "\tbison: comp_operator:\tLARGER\n");}
	      ;

bool_expr:
          math_expr comp_operator math_expr
        {fprintf(stderr, "\tbison: bool_expr:\tmath_expr comp_operator math_expr\n");}
        ;

math_expr:
  			  number
        {fprintf(stderr, "\tbison: math_expr:\tnumber\n");}
  			| VAR_ID
        {fprintf(stderr, "\tbison: math_expr:\tVAR_ID\n");
          std::string sym($1);
          free($1);
          std::cerr << "ID: " << sym << std::endl;
        }
  			| math_expr math_operator math_expr %prec ADD
        {fprintf(stderr, "\tbison: math_expr:\tmath_expr math_operator math_expr\n");}
  			| POPEN math_expr PCLOSE
        {fprintf(stderr, "\tbison: math_expr:\tPOPEN math_expr PCLOSE\n");}
  			| SUB math_expr %prec UMINUS
        {fprintf(stderr, "\tbison: math_expr:\tSUB math_expr\n");}
  			;

math_operator:
          ADD
        {fprintf(stderr, "\tbison: math_operator:\tADD\n");}
				| SUB
        {fprintf(stderr, "\tbison: math_operator:\tSUB\n");}
				| DIV
        {fprintf(stderr, "\tbison: math_operator:\tDIV\n");}
				| MUL
        {fprintf(stderr, "\tbison: math_operator:\tMUL\n");}
        | MOD
        {fprintf(stderr, "\tbison: math_operator:\tMOD\n");}
				;

is_expr:
          VAR_ID IS math_expr
        {fprintf(stderr, "\tbison: is_expr:\tVAR_ID IS math_expr\n");
          std::string sym($1);
          free($1);
          std::cerr << "ID: " << sym << std::endl;
        }
        ;

%%

int main(int, char**) {
	yyparse();
  std::cout << "pred list:" << std::endl;
  for (std::vector<std::string>::iterator it = preds.begin(); it < preds.end(); it++) {
    std::cout << *it << std::endl;
  }
}
