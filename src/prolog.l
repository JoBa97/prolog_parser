%{
#include <string.h>
#include "prolog.tab.h"
#include "debug.h"
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


{IS}	       {DEBUG("flex: IS\n"); return IS;}
{MOD}        {DEBUG("flex: MOD\n"); return MOD;}

{CONST_ID}   {DEBUG("flex: CONST_ID\n");
              yylval.text = strdup(yytext);
              return CONST_ID;}
{VAR_ID}	   {DEBUG("flex: VAR_ID\n");
              yylval.text = strdup(yytext);
              return VAR_ID;}
{INT}   	   {DEBUG("flex: INT\n"); return INT;}
{FLOAT}	     {DEBUG("flex: FLOAT\n"); return FLOAT;}
{ANONYMOUS}	 {DEBUG("flex: ANONYMOUS\n"); return ANONYMOUS;}
{POPEN}	     {DEBUG("flex: POPEN\n"); return POPEN;}
{PCLOSE}	   {DEBUG("flex: PCLOSE\n"); return PCLOSE;}
{DOT}	       {DEBUG("flex: DOT\n"); return DOT;}
{DEF}	       {DEBUG("flex: DEF\n"); return DEF;}
{LOPEN}	     {DEBUG("flex: LOPEN\n"); return LOPEN;}
{LCLOSE}	   {DEBUG("flex: LCLOSE\n"); return LCLOSE;}
{COMMA}	     {DEBUG("flex: COMMA\n"); return COMMA;}
{PIPE}	     {DEBUG("flex: PIPE\n"); return PIPE;}
{ADD}	       {DEBUG("flex: ADD\n"); return ADD;}
{SUB}	       {DEBUG("flex: SUB\n"); return SUB;}
{MUL}	       {DEBUG("flex: MUL\n"); return MUL;}
{DIV}	       {DEBUG("flex: DIV\n"); return DIV;}
{EQUAL}	     {DEBUG("flex: EQUAL\n"); return EQUAL;}
{UNEQUAL}	   {DEBUG("flex: UNEQUAL\n"); return UNEQUAL;}
{SMALLER_EQ} {DEBUG("flex: SMALLER_EQ\n"); return SMALLER_EQ;}
{LARGER_EQ}	 {DEBUG("flex: LARGER_EQ\n"); return LARGER_EQ;}
{SMALLER}	   {DEBUG("flex: SMALLER\n"); return SMALLER;}
{LARGER}	   {DEBUG("flex: LARGER\n"); return LARGER;}
{EOL}	       {DEBUG("flex: EOL\n"); lines++;}
