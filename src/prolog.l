%{
#include <string.h>

#include "debug.h"
#include "symbol_table.h"

#include "prolog.tab.h" /* must be the last include because why not */

#define YY_DECL extern "C" int yylex()
int lines = 1;
%}

ID			([A-Za-z0-9]*)
CONST_ID 	([a-z]{ID})
VAR_ID 		([A-Z]{ID})
FLOAT		({INT}\.[0-9]+)
INT			([1-9][0-9]*|0)
IS			(is)
ANONYMOUS	(_{ID})
POPEN 		(\()
PCLOSE		(\))
DOT			(\.)
DEF			(:-)
LOPEN		(\[)
LCLOSE		(\])
COMMA		(,)
PIPE		(\|)
ADD			(\+)
SUB			(-)
MUL			(\*)
DIV			(\/)
MOD     (mod)
EQUAL		(=:=)
UNEQUAL		(=\\=)
SMALLER_EQ	(=<|<=)
LARGER_EQ	(>=|=>)
SMALLER		(<)
LARGER		(>)
EOL			(\n)
BLANK       (\s+)



%%


{IS}	       {DEBUG("flex: IS"); return IS;}
{MOD}        {DEBUG("flex: MOD"); return MOD;}

{CONST_ID}   {DEBUG("flex: CONST_ID");
              yylval.text = strdup(yytext);
              return CONST_ID;}
{VAR_ID}	   {DEBUG("flex: VAR_ID");
              yylval.text = strdup(yytext);
              return VAR_ID;}
{INT}   	   {DEBUG("flex: INT"); return INT;}
{FLOAT}	     {DEBUG("flex: FLOAT"); return FLOAT;}
{ANONYMOUS}	 {DEBUG("flex: ANONYMOUS"); return ANONYMOUS;}
{POPEN}	     {DEBUG("flex: POPEN"); return POPEN;}
{PCLOSE}	   {DEBUG("flex: PCLOSE"); return PCLOSE;}
{DOT}	       {DEBUG("flex: DOT"); return DOT;}
{DEF}	       {DEBUG("flex: DEF"); return DEF;}
{LOPEN}	     {DEBUG("flex: LOPEN"); return LOPEN;}
{LCLOSE}	   {DEBUG("flex: LCLOSE"); return LCLOSE;}
{COMMA}	     {DEBUG("flex: COMMA"); return COMMA;}
{PIPE}	     {DEBUG("flex: PIPE"); return PIPE;}
{ADD}	       {DEBUG("flex: ADD"); return ADD;}
{SUB}	       {DEBUG("flex: SUB"); return SUB;}
{MUL}	       {DEBUG("flex: MUL"); return MUL;}
{DIV}	       {DEBUG("flex: DIV"); return DIV;}
{EQUAL}	     {DEBUG("flex: EQUAL"); return EQUAL;}
{UNEQUAL}	   {DEBUG("flex: UNEQUAL"); return UNEQUAL;}
{SMALLER_EQ} {DEBUG("flex: SMALLER_EQ"); return SMALLER_EQ;}
{LARGER_EQ}	 {DEBUG("flex: LARGER_EQ"); return LARGER_EQ;}
{SMALLER}	   {DEBUG("flex: SMALLER"); return SMALLER;}
{LARGER}	   {DEBUG("flex: LARGER"); return LARGER;}
{EOL}	       {DEBUG("flex: EOL"); lines++;}
