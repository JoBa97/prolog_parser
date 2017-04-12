%{
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <string>
#include <vector>

#include "debug.h"
#include "symbol_table.h"

extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;
extern "C" int lines;

void yyerror(const char *s) {
  fprintf (stderr, "Parser error in line %d:\n%s\n", lines, s);
}

symbol_table_t symbol_table;

std::vector<std::string> preds;
std::vector<std::string> vars;

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

%type <statement> cmd

%left EQUAL UNEQUAL SMALLER SMALLER_EQ LARGER LARGER_EQ
%left ADD SUB
%left MUL DIV
%left MOD

%right UMINUS

%union {
  char* text;
  statement_t* statement;
}

%%

start:
          cmds
        {DEBUG("\tbison: start:\tcmds\n");}
        ;

cmds:
          cmd cmds
        { DEBUG("\tbison: cmds:\tcmd cmds\n");
          symbol_table.push_back(*$1);
        }
        | cmd
        { DEBUG("\tbison: cmds:\tcmd\n");
          symbol_table.push_back(*$1);
        }
        ;

cmd:
          fact
        { DEBUG("\tbison: cmd:\tfact\n");
          $$ = new statement_t;
        }
        | def
        { DEBUG("\tbison: cmd:\tdef\n");
          $$ = new statement_t;
        }
        ;

fact:
          pred DOT
        {DEBUG("\tbison: fact:\tpred DOT\n");}
        ;

def:
          pred DEF expressions DOT
        {DEBUG("\tbison: def:\tpred DEF expressions DOT\n");}
        ;

pred:
          CONST_ID POPEN params PCLOSE
        { DEBUG("\tbison: pred:\tCONST_ID POPEN params PCLOSE\n");
          std::string sym($1);
          free($1);
          std::cerr << "ID: " << sym << std::endl;
          preds.push_back(sym);
        }
        | CONST_ID
        { DEBUG("\tbison: pred:\tfCONST_ID\n");
          std::string sym($1);
          free($1);
          std::cerr << "ID: " << sym << std::endl;
          preds.push_back(sym);
        }
        ;

params:
          param COMMA params
        {DEBUG("\tbison: params:\tparam COMMA params\n");}
        | param
        {DEBUG("\tbison: params:\tparam\n");}
        ;

param:
          CONST_ID
        {DEBUG("\tbison: param:\tCONST_ID\n");
          std::string sym($1);
          free($1);
          std::cerr << "ID: " << sym << std::endl;
        }
        | VAR_ID
        {DEBUG("\tbison: param:\tVAR_ID\n");
          std::string sym($1);
          free($1);
          std::cerr << "ID: " << sym << std::endl;
        }
        | ANONYMOUS
        {DEBUG("\tbison: param:\tANONYMOUS\n");}
        | number
        {DEBUG("\tbison: param:\tnumber\n");}
        | SUB number
        {DEBUG("\tbison: param:\tSUB number\n");}
        | list
        {DEBUG("\tbison: param:\tlist\n");}
        ;

number:
          INT
        {DEBUG("\tbison: number:\tINT\n");}
        | FLOAT
        {DEBUG("\tbison: number:\tFLOAT\n");}
        ;

list:
          LOPEN lelements LCLOSE
        {DEBUG("\tbison: list:\tLOPEN lelements LCLOSE\n");}
  		  |	LOPEN lelements PIPE list LCLOSE
        {DEBUG("\tbison: list:\tLOPEN lelements PIPE list LCLOSE\n");}
  		  |	LOPEN lelements PIPE VAR_ID LCLOSE
        { DEBUG("\tbison: list:\tLOPEN lelements PIPE VAR_ID LCLOSE\n");
          std::string sym($4);
          free($4);
          std::cerr << "ID: " << sym << std::endl;
        }
        |	LOPEN lelements PIPE ANONYMOUS LCLOSE
        {DEBUG("\tbison: list:\tLOPEN lelements PIPE ANONYMOUS LCLOSE\n");}
  		  |	LOPEN LCLOSE
        {DEBUG("\tbison: list:\tLOPEN LCLOSE\n");}
  		  ;

lelements:
          lelement COMMA lelements
        {DEBUG("\tbison: lelements:\tlelement COMMA lelements\n");}
        | lelement
        {DEBUG("\tbison: lelements:\tlelement\n");}
        ;

lelement:
          CONST_ID
        {DEBUG("\tbison: lelement:\tCONST_ID\n");
          std::string sym($1);
          free($1);
          std::cerr << "ID: " << sym << std::endl;
        }
        | VAR_ID
        {DEBUG("\tbison: lelement:\tVAR_ID\n");
          std::string sym($1);
          free($1);
          std::cerr << "ID: " << sym << std::endl;
        }
        | ANONYMOUS
        {DEBUG("\tbison: lelement:\tANONYMOUS\n");}
		    | number
        {DEBUG("\tbison: lelement:\tnumber\n");}
        | SUB number
        {DEBUG("\tbison: lelement:\tnumber\n");}
		    | list
        {DEBUG("\tbison: lelement:\tlist\n");}
		    ;



expressions:
          expression COMMA expressions
        {DEBUG("\tbison: expression:\texpression COMMA expressions\n");}
        | expression
        {DEBUG("\tbison: expression:\texpression\n");}
        ;

expression:
          pred
        {DEBUG("\tbison: expression:\tpred\n");}
        | is_expr
        {DEBUG("\tbison: expression:\tis_expr\n");}
        | bool_expr
        {DEBUG("\tbison: expression:\tbool_expr\n");}
        ;

comp_operator:
          EQUAL
        {DEBUG("\tbison: comp_operator:\tEQUAL\n");}
	      | UNEQUAL
        {DEBUG("\tbison: comp_operator:\tUNEQUAL\n");}
	      | SMALLER_EQ
        {DEBUG("\tbison: comp_operator:\tSMALLER_EQ\n");}
	      | LARGER_EQ
        {DEBUG("\tbison: comp_operator:\tLARGER_EQ\n");}
	      | SMALLER
        {DEBUG("\tbison: comp_operator:\tSMALLER\n");}
	      | LARGER
        {DEBUG("\tbison: comp_operator:\tLARGER\n");}
	      ;

bool_expr:
          math_expr comp_operator math_expr
        {DEBUG("\tbison: bool_expr:\tmath_expr comp_operator math_expr\n");}
        ;

math_expr:
  			  number
        {DEBUG("\tbison: math_expr:\tnumber\n");}
  			| VAR_ID
        {DEBUG("\tbison: math_expr:\tVAR_ID\n");
          std::string sym($1);
          free($1);
          std::cerr << "ID: " << sym << std::endl;
        }
  			| math_expr math_operator math_expr %prec ADD
        {DEBUG("\tbison: math_expr:\tmath_expr math_operator math_expr\n");}
  			| POPEN math_expr PCLOSE
        {DEBUG("\tbison: math_expr:\tPOPEN math_expr PCLOSE\n");}
  			| SUB math_expr %prec UMINUS
        {DEBUG("\tbison: math_expr:\tSUB math_expr\n");}
  			;

math_operator:
          ADD
        {DEBUG("\tbison: math_operator:\tADD\n");}
				| SUB
        {DEBUG("\tbison: math_operator:\tSUB\n");}
				| DIV
        {DEBUG("\tbison: math_operator:\tDIV\n");}
				| MUL
        {DEBUG("\tbison: math_operator:\tMUL\n");}
        | MOD
        {DEBUG("\tbison: math_operator:\tMOD\n");}
				;

is_expr:
          VAR_ID IS math_expr
        {DEBUG("\tbison: is_expr:\tVAR_ID IS math_expr\n");
          std::string sym($1);
          free($1);
          std::cerr << "ID: " << sym << std::endl;
        }
        ;

%%

int main(int, char**) {
	yyparse();
  DEBUG("symbol table size: " << symbol_table.size());
  //std::cout << "pred list:" << std::endl;
  //for (std::vector<std::string>::iterator it = preds.begin(); it < preds.end(); it++) {
  //  std::cout << *it << std::endl;
  //}
}
