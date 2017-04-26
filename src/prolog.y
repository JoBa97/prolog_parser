%{
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <string>

#include "debug.h"
#include "symbol_table.h"
#include "flow_blocks.h"

extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;
extern "C" int lines;

void yyerror(const char *s) {
  fprintf (stderr, "Parser error in line %d:\n%s", lines, s);
}

symbol_table_t symbol_table;

//TODO all variables have different ids
//TODO equals, need to be unified

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

%type<lit_info> cmd
%type<lit_info> fact
%type<lit_info> def
%type<lit_info> pred
%type<lit_info> expressions
%type<lit_info> expression
%type<lit_info> is_expr
%type<lit_info> bool_expr

%type<var_info> params
%type<var_info> param
%type<var_info> math_expr
%type<var_info> number
%type<var_info> list
%type<var_info> lelements
%type<var_info> lelement

%left EQUAL UNEQUAL SMALLER SMALLER_EQ LARGER LARGER_EQ
%left ADD SUB
%left MUL DIV
%left MOD

%right UMINUS

%union {
  char* text;
  lit_info_t* lit_info;
  var_info_t* var_info;
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
          $$ = $1;
        }
        ;

def:
          pred DEF expressions DOT
        { DEBUG("\tbison: def:\tpred DEF expressions DOT");
          // join pred, exprs
          $1->insert($3->begin(), $3->end());
          delete $3;
          $$ = $1;
        }
        ;

pred:
          CONST_ID POPEN params PCLOSE
        { DEBUG("\tbison: pred:\tCONST_ID POPEN params PCLOSE");
          std::string sym($1);
          free($1);
          DEBUG("ID: " << sym);
          lit_info_t* info = new lit_info_t;
          lit_id_t id = next_id(sym);
          var_info_t vars = *$3; //build info from params
          info->insert(std::pair<lit_id_t, var_info_t>(id, vars));
          $$ = info;
        }
        | CONST_ID
        { DEBUG("\tbison: pred:\tfCONST_ID");
          std::string sym($1);
          free($1);
          DEBUG("ID: " << sym);
          lit_info_t* info = new lit_info_t;
          lit_id_t id = next_id(sym);
          // insert empty var info
          info->insert(std::pair<lit_id_t, var_info_t>(id, var_info_t()));
          $$ = info;
        }
        ;

params:
          param COMMA params
        { DEBUG("\tbison: params:\tparam COMMA params");
          // join the two sets
          $1->first.insert($3->first.begin(), $3->first.end());
          $1->second.insert($3->second.begin(), $3->second.end());
          delete $3;
          $$ = $1;
        }
        | param
        { DEBUG("\tbison: params:\tparam");
          $$ = $1;
        }
        ;

param:
          CONST_ID
        {DEBUG("\tbison: param:\tCONST_ID");
          std::string sym($1);
          free($1);
          DEBUG("ID: " << sym);
          var_info_t* vars = new var_info_t;
          var_id_t id = next_id(sym);
          DEBUG("paramID: " << id.repr());
          vars->second.insert(id);
          $$ = vars;
        }
        | VAR_ID
        {DEBUG("\tbison: param:\tVAR_ID");
          std::string sym($1);
          free($1);
          DEBUG("ID: " << sym);
          var_info_t* vars = new var_info_t;
          var_id_t id = next_id(sym);
          DEBUG("paramID: " << id.repr());
          vars->first.insert(id);
          $$ = vars;
        }
        | ANONYMOUS
        { DEBUG("\tbison: param:\tANONYMOUS");
          //TODO think about numbers and anons and lists
          $$ = new var_info_t();
        }
        | number
        { DEBUG("\tbison: param:\tnumber");
          $$ = $1;
        }
        | SUB number
        { DEBUG("\tbison: param:\tSUB number");
          $$ = $2;
        }
        | list
        { DEBUG("\tbison: param:\tlist");
          $$ = $1;
        }
        ;

number:
          INT
        { DEBUG("\tbison: number:\tINT");
          //numbers are constants
          //TODO get value maybe
          var_info_t* vars = new var_info_t;
          var_id_t id = next_id("number");
          vars->second.insert(id);
          $$ = vars;
        }
        | FLOAT
        { DEBUG("\tbison: number:\tFLOAT");
          var_info_t* vars = new var_info_t;
          var_id_t id = next_id("number");
          vars->second.insert(id);
          $$ = vars;
        }
        ;

list:
          LOPEN lelements LCLOSE
        { DEBUG("\tbison: list:\tLOPEN lelements LCLOSE");
          $$ = $2;
        }
  		  |	LOPEN lelements PIPE list LCLOSE
        { DEBUG("\tbison: list:\tLOPEN lelements PIPE list LCLOSE");
          //join list into lelements sets
          $2->first.insert($4->first.begin(), $4->first.end());
          $2->second.insert($4->second.begin(), $4->second.end());
          delete $4;
          $$ = $2;
        }
  		  |	LOPEN lelements PIPE VAR_ID LCLOSE
        { DEBUG("\tbison: list:\tLOPEN lelements PIPE VAR_ID LCLOSE");
          std::string sym($4);
          free($4);
          std::cerr << "ID: " << sym << std::endl;
          //add one var to lelements set
          //TODO how to handle lists correctly
          $2->first.insert(next_id(sym));
          $$ = $2;
        }
        |	LOPEN lelements PIPE ANONYMOUS LCLOSE
        { DEBUG("\tbison: list:\tLOPEN lelements PIPE ANONYMOUS LCLOSE");
          //TODO handle anon
          $$ = $2;
        }
  		  |	LOPEN LCLOSE
        { DEBUG("\tbison: list:\tLOPEN LCLOSE");
          //empty list: constant
          var_info_t* info = new var_info_t();
          info->second.insert(next_id(std::string("EMPTY_LIST")));
          $$ = info;
        }
  		  ;

lelements:
          lelement COMMA lelements
        { DEBUG("\tbison: lelements:\tlelement COMMA lelements");
          // join sets
          $1->first.insert($3->first.begin(), $3->first.end());
          $1->second.insert($3->second.begin(), $3->second.end());
          delete $3;
          $$ = $1;
        }
        | lelement
        { DEBUG("\tbison: lelements:\tlelement");
          $$ = $1;
        }
        ;

lelement:
          CONST_ID
        { DEBUG("\tbison: lelement:\tCONST_ID");
          std::string sym($1);
          free($1);
          DEBUG("ID: " << sym);
          var_info_t* info = new var_info_t();
          info->second.insert(next_id(sym));
          $$ = info;
        }
        | VAR_ID
        { DEBUG("\tbison: lelement:\tVAR_ID");
          std::string sym($1);
          free($1);
          DEBUG("ID: " << sym);
          var_info_t* info = new var_info_t();
          info->first.insert(next_id(sym));
          $$ = info;
        }
        | ANONYMOUS
        { DEBUG("\tbison: lelement:\tANONYMOUS");
          //TODO handle anon
          $$ = new var_info_t();
        }
		    | number
        { DEBUG("\tbison: lelement:\tnumber");
          $$ = $1;
        }
        | SUB number
        { DEBUG("\tbison: lelement:\tnumber");
          $$ = $2;
        }
		    | list
        { DEBUG("\tbison: lelement:\tlist");
          $$ = $1;
        }
		    ;

expressions:
          expression COMMA expressions
        { DEBUG("\tbison: expression:\texpression COMMA expressions");
          //join sets
          $1->insert($3->begin(), $3->end());
          delete $3;
          $$ = $1;
        }
        | expression
        { DEBUG("\tbison: expression:\texpression");
          $$ = $1;
        }
        ;

expression:
          pred
        { DEBUG("\tbison: expression:\tpred");
          $$ = $1;
        }
        | is_expr
        { DEBUG("\tbison: expression:\tis_expr");
          $$ = $1;
        }
        | bool_expr
        { DEBUG("\tbison: expression:\tbool_expr");
          $$ = $1;
        }
        ;

comp_operator:
          EQUAL
        { DEBUG("\tbison: comp_operator:\tEQUAL");}
	      | UNEQUAL
        { DEBUG("\tbison: comp_operator:\tUNEQUAL");}
	      | SMALLER_EQ
        { DEBUG("\tbison: comp_operator:\tSMALLER_EQ");}
	      | LARGER_EQ
        { DEBUG("\tbison: comp_operator:\tLARGER_EQ");}
	      | SMALLER
        { DEBUG("\tbison: comp_operator:\tSMALLER");}
	      | LARGER
        { DEBUG("\tbison: comp_operator:\tLARGER");}
	      ;

bool_expr:
          math_expr comp_operator math_expr
        { DEBUG("\tbison: bool_expr:\tmath_expr comp_operator math_expr");
          lit_info_t* info = new lit_info_t;
          lit_id_t id = next_id(std::string("COMPEARE"));
          $1->first.insert($3->first.begin(), $3->first.end());
          $1->second.insert($3->second.begin(), $3->second.end());
          var_info_t vars = *$1;
          delete $3;
          info->insert(std::pair<lit_id_t, var_info_t>(id, vars));
          $$ = info;
        }
        ;

math_expr:
  			  number
        { DEBUG("\tbison: math_expr:\tnumber");
          $$ = $1;
        }
  			| VAR_ID
        { DEBUG("\tbison: math_expr:\tVAR_ID");
          std::string sym($1);
          free($1);
          DEBUG("ID: " << sym);
          var_info_t* info = new var_info_t();
          info->first.insert(next_id(sym));
          $$ = info;
        }
  			| math_expr math_operator math_expr %prec ADD
        { DEBUG("\tbison: math_expr:\tmath_expr math_operator math_expr");
          // join the two sets
          $1->first.insert($3->first.begin(), $3->first.end());
          $1->second.insert($3->second.begin(), $3->second.end());
          delete $3;
          $$ = $1;
        }
  			| POPEN math_expr PCLOSE
        { DEBUG("\tbison: math_expr:\tPOPEN math_expr PCLOSE");
          $$ = $2;
        }
  			| SUB math_expr %prec UMINUS
        { DEBUG("\tbison: math_expr:\tSUB math_expr");
          $$ = $2;
        }
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
        { DEBUG("\tbison: is_expr:\tVAR_ID IS math_expr");
          std::string sym($1);
          free($1);
          DEBUG("ID: " << sym);
          lit_info_t* info = new lit_info_t;
          lit_id_t id = next_id(std::string("IS")); //"IS" is the literal
          var_info_t vars = *$3;
          vars.first.insert(next_id(sym));
          info->insert(std::pair<lit_id_t, var_info_t>(id, vars));
          $$ = info;
        }
        ;

%%

int main(int, char**) {
	yyparse();

  //it was reduced bottom to top
  std::reverse(symbol_table.begin(), symbol_table.end());

  print_symbol_table(symbol_table);

}
