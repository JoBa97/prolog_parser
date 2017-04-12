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
  fprintf (stderr, "Parser error in line %d:\n%s", lines, s);
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

%type<statement> cmd
%type<statement> fact
%type<statement> def

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
        {DEBUG("\tbison: start:\tcmds");}
        ;

cmds:
          cmd cmds
        { DEBUG("\tbison: cmds:\tcmd cmds");
          symbol_table.push_back(*$1);
        }
        | cmd
        { DEBUG("\tbison: cmds:\tcmd");
          symbol_table.push_back(*$1);
        }
        ;

cmd:
          fact
        { DEBUG("\tbison: cmd:\tfact");
          $$ = $1;
        }
        | def
        { DEBUG("\tbison: cmd:\tdef");
          $$ = $1;
        }
        ;

fact:
          pred DOT
        { DEBUG("\tbison: fact:\tpred DOT");
          $$ = new statement_t;
        }
        ;

def:
          pred DEF expressions DOT
        { DEBUG("\tbison: def:\tpred DEF expressions DOT");
          $$ = new statement_t;
        }
        ;

pred:
          CONST_ID POPEN params PCLOSE
        { DEBUG("\tbison: pred:\tCONST_ID POPEN params PCLOSE");
          std::string sym($1);
          free($1);
          std::cerr << "ID: " << sym << std::endl;
          preds.push_back(sym);
        }
        | CONST_ID
        { DEBUG("\tbison: pred:\tfCONST_ID");
          std::string sym($1);
          free($1);
          std::cerr << "ID: " << sym << std::endl;
          preds.push_back(sym);
        }
        ;

params:
          param COMMA params
        {DEBUG("\tbison: params:\tparam COMMA params");}
        | param
        {DEBUG("\tbison: params:\tparam");}
        ;

param:
          CONST_ID
        {DEBUG("\tbison: param:\tCONST_ID");
          std::string sym($1);
          free($1);
          std::cerr << "ID: " << sym << std::endl;
        }
        | VAR_ID
        {DEBUG("\tbison: param:\tVAR_ID");
          std::string sym($1);
          free($1);
          std::cerr << "ID: " << sym << std::endl;
        }
        | ANONYMOUS
        {DEBUG("\tbison: param:\tANONYMOUS");}
        | number
        {DEBUG("\tbison: param:\tnumber");}
        | SUB number
        {DEBUG("\tbison: param:\tSUB number");}
        | list
        {DEBUG("\tbison: param:\tlist");}
        ;

number:
          INT
        {DEBUG("\tbison: number:\tINT");}
        | FLOAT
        {DEBUG("\tbison: number:\tFLOAT");}
        ;

list:
          LOPEN lelements LCLOSE
        {DEBUG("\tbison: list:\tLOPEN lelements LCLOSE");}
  		  |	LOPEN lelements PIPE list LCLOSE
        {DEBUG("\tbison: list:\tLOPEN lelements PIPE list LCLOSE");}
  		  |	LOPEN lelements PIPE VAR_ID LCLOSE
        { DEBUG("\tbison: list:\tLOPEN lelements PIPE VAR_ID LCLOSE");
          std::string sym($4);
          free($4);
          std::cerr << "ID: " << sym << std::endl;
        }
        |	LOPEN lelements PIPE ANONYMOUS LCLOSE
        {DEBUG("\tbison: list:\tLOPEN lelements PIPE ANONYMOUS LCLOSE");}
  		  |	LOPEN LCLOSE
        {DEBUG("\tbison: list:\tLOPEN LCLOSE");}
  		  ;

lelements:
          lelement COMMA lelements
        {DEBUG("\tbison: lelements:\tlelement COMMA lelements");}
        | lelement
        {DEBUG("\tbison: lelements:\tlelement");}
        ;

lelement:
          CONST_ID
        {DEBUG("\tbison: lelement:\tCONST_ID");
          std::string sym($1);
          free($1);
          std::cerr << "ID: " << sym << std::endl;
        }
        | VAR_ID
        {DEBUG("\tbison: lelement:\tVAR_ID");
          std::string sym($1);
          free($1);
          std::cerr << "ID: " << sym << std::endl;
        }
        | ANONYMOUS
        {DEBUG("\tbison: lelement:\tANONYMOUS");}
		    | number
        {DEBUG("\tbison: lelement:\tnumber");}
        | SUB number
        {DEBUG("\tbison: lelement:\tnumber");}
		    | list
        {DEBUG("\tbison: lelement:\tlist");}
		    ;



expressions:
          expression COMMA expressions
        {DEBUG("\tbison: expression:\texpression COMMA expressions");}
        | expression
        {DEBUG("\tbison: expression:\texpression");}
        ;

expression:
          pred
        {DEBUG("\tbison: expression:\tpred");}
        | is_expr
        {DEBUG("\tbison: expression:\tis_expr");}
        | bool_expr
        {DEBUG("\tbison: expression:\tbool_expr");}
        ;

comp_operator:
          EQUAL
        {DEBUG("\tbison: comp_operator:\tEQUAL");}
	      | UNEQUAL
        {DEBUG("\tbison: comp_operator:\tUNEQUAL");}
	      | SMALLER_EQ
        {DEBUG("\tbison: comp_operator:\tSMALLER_EQ");}
	      | LARGER_EQ
        {DEBUG("\tbison: comp_operator:\tLARGER_EQ");}
	      | SMALLER
        {DEBUG("\tbison: comp_operator:\tSMALLER");}
	      | LARGER
        {DEBUG("\tbison: comp_operator:\tLARGER");}
	      ;

bool_expr:
          math_expr comp_operator math_expr
        {DEBUG("\tbison: bool_expr:\tmath_expr comp_operator math_expr");}
        ;

math_expr:
  			  number
        {DEBUG("\tbison: math_expr:\tnumber");}
  			| VAR_ID
        {DEBUG("\tbison: math_expr:\tVAR_ID");
          std::string sym($1);
          free($1);
          std::cerr << "ID: " << sym << std::endl;
        }
  			| math_expr math_operator math_expr %prec ADD
        {DEBUG("\tbison: math_expr:\tmath_expr math_operator math_expr");}
  			| POPEN math_expr PCLOSE
        {DEBUG("\tbison: math_expr:\tPOPEN math_expr PCLOSE");}
  			| SUB math_expr %prec UMINUS
        {DEBUG("\tbison: math_expr:\tSUB math_expr");}
  			;

math_operator:
          ADD
        {DEBUG("\tbison: math_operator:\tADD");}
				| SUB
        {DEBUG("\tbison: math_operator:\tSUB");}
				| DIV
        {DEBUG("\tbison: math_operator:\tDIV");}
				| MUL
        {DEBUG("\tbison: math_operator:\tMUL");}
        | MOD
        {DEBUG("\tbison: math_operator:\tMOD");}
				;

is_expr:
          VAR_ID IS math_expr
        {DEBUG("\tbison: is_expr:\tVAR_ID IS math_expr");
          std::string sym($1);
          free($1);
          std::cerr << "ID: " << sym << std::endl;
        }
        ;

%%

int main(int, char**) {
	yyparse();
  DEBUG("symbol table size: " << symbol_table.size());
  NamedId nid = next_id(std::string("hallo"));
  DEBUG("1 test nid: [" << nid.id << ", " << nid.name << "]");
  nid = next_id(std::string("nope"));
  DEBUG("2 test nid: [" << nid.id << ", " << nid.name << "]");

  DEBUG("symbol table:");
  for(auto& elem: symbol_table) {
    DEBUG("table entry size: " << elem.size());
  }

  //std::cout << "pred list:" << std::endl;
  //for (std::vector<std::string>::iterator it = preds.begin(); it < preds.end(); it++) {
  //  std::cout << *it << std::endl;
  //}
}
