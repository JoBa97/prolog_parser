%{
#include <string.h>
#include "prolog.tab.h"
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


{IS}	       {fprintf(stderr, "flex: IS\n"); return IS;}
{MOD}        {fprintf(stderr, "flex: MOD\n"); return MOD;}

{CONST_ID}   {fprintf(stderr, "flex: CONST_ID\n");
              yylval.text = strdup(yytext);
              return CONST_ID;}
{VAR_ID}	   {fprintf(stderr, "flex: VAR_ID\n");
              yylval.text = strdup(yytext);
              return VAR_ID;}
{INT}   	   {fprintf(stderr, "flex: INT\n"); return INT;}
{FLOAT}	     {fprintf(stderr, "flex: FLOAT\n"); return FLOAT;}
{ANONYMOUS}	 {fprintf(stderr, "flex: ANONYMOUS\n"); return ANONYMOUS;}
{POPEN}	     {fprintf(stderr, "flex: POPEN\n"); return POPEN;}
{PCLOSE}	   {fprintf(stderr, "flex: PCLOSE\n"); return PCLOSE;}
{DOT}	       {fprintf(stderr, "flex: DOT\n"); return DOT;}
{DEF}	       {fprintf(stderr, "flex: DEF\n"); return DEF;}
{LOPEN}	     {fprintf(stderr, "flex: LOPEN\n"); return LOPEN;}
{LCLOSE}	   {fprintf(stderr, "flex: LCLOSE\n"); return LCLOSE;}
{COMMA}	     {fprintf(stderr, "flex: COMMA\n"); return COMMA;}
{PIPE}	     {fprintf(stderr, "flex: PIPE\n"); return PIPE;}
{ADD}	       {fprintf(stderr, "flex: ADD\n"); return ADD;}
{SUB}	       {fprintf(stderr, "flex: SUB\n"); return SUB;}
{MUL}	       {fprintf(stderr, "flex: MUL\n"); return MUL;}
{DIV}	       {fprintf(stderr, "flex: DIV\n"); return DIV;}
{EQUAL}	     {fprintf(stderr, "flex: EQUAL\n"); return EQUAL;}
{UNEQUAL}	   {fprintf(stderr, "flex: UNEQUAL\n"); return UNEQUAL;}
{SMALLER_EQ} {fprintf(stderr, "flex: SMALLER_EQ\n"); return SMALLER_EQ;}
{LARGER_EQ}	 {fprintf(stderr, "flex: LARGER_EQ\n"); return LARGER_EQ;}
{SMALLER}	   {fprintf(stderr, "flex: SMALLER\n"); return SMALLER;}
{LARGER}	   {fprintf(stderr, "flex: LARGER\n"); return LARGER;}
{EOL}	       {fprintf(stderr, "flex: EOL\n"); lines++;}
