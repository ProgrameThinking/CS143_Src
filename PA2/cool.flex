/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

int strl=0;
int stack=1;

%}

/*
 * Define names for regular expressions here.
 */

/*keywords*/

DARROW          =>
ASSIGN          <-
LE              <=
CLASS           [Cc][Ll][Aa][Ss][Ss]
ELSE            [Ee][Ll][Ss][Ee]
IF              [Ii][Ff]
FI              [Ff][Ii]
IN              [Ii][Nn]
INHERITS        [Ii][Nn][Hh][Ee][Rr][Ii][Tt][Ss]
LET             [Ll][Ee][Tt]
LOOP            [Ll][Oo][Oo][Pp]
POOL            [Pp][Oo][Oo][Ll]
THEN            [Tt][Hh][Ee][Nn]
WHILE           [Ww][Hh][Ii][Ll][Ee]
CASE            [Cc][Aa][Ss][Ee]
ESAC            [Ee][Ss][Aa][Cc]
OF              [Oo][Ff]
NEW             [Nn][Ee][Ww]
ISVOID          [Ii][Ss][Vv][Oo][Ii][Dd]
NOT             [Nn][Oo][Tt]
TRUE            t[rR][uU][eE]
FALSE           f[aA][lL][sS][eE]

/*Others*/

DIGIT [0-9]+
STR [0-9a-z_A-Z]*

/*Conditions*/

%x COMMENT
%x STRING

%%

"\n"           { curr_lineno++; }
[\f\r\t\v\b ]   /*eat up the white space*/

 /*
  *  Nested comments
  */

"(*" {BEGIN (COMMENT);stack=1;} /*switch comment mode*/
<COMMENT>.   /*eat up comments*/
<COMMENT>"(*" {stack++;}  /*nested*/
<COMMENT>\n { curr_lineno++; }   
<COMMENT>"*)" {   stack--;  /*unnested*/
                  if(stack==0)  BEGIN (INITIAL) ;
                } 
<COMMENT><<EOF>> {  cool_yylval.error_msg = "EOF in comment"; 
                    BEGIN(INITIAL); 
                    return (ERROR); 
                  }
"*)" {  cool_yylval.error_msg = "‘Unmatched *)" ; 
        return (ERROR) ; }

 /*
  * Single line comment
  */
"--".*         /*eat up a line commet*/

 /*
  *  The multiple-character operators.
  */
{DARROW}		{ return (DARROW); }
{ASSIGN}    { return (ASSIGN); }

 /*
  *  Boolean constants
  */
{TRUE}      { cool_yylval.boolean = 1; return (BOOL_CONST); }
{FALSE}     { cool_yylval.boolean = 0; return (BOOL_CONST); }

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */
{CLASS}     { return (CLASS); }
{ELSE}      { return (ELSE); }
{IF}        { return (IF); }
{FI}        { return (FI); }
{IN}        { return (IN); }
{INHERITS}  { return (INHERITS); }
{LET}       { return (LET); }
{LOOP}      { return (LOOP); }
{POOL}      { return (POOL); }
{THEN}      { return (THEN); }
{WHILE}     { return (WHILE); }
{CASE}      { return (CASE); }
{ESAC}      { return (ESAC); }
{OF}        { return (OF); }
{NEW}       { return (NEW); }
{ISVOID}    { return (ISVOID); }
{NOT}       { return (NOT); }

 /*
  *  The single-character operators.
  */
"."         { return ('.'); }
"@"         { return ('@'); }
"~"         { return ('~'); }
"*"         { return ('*'); }
"/"         { return ('/'); }
"+"         { return ('+'); }
"-"         { return ('-'); }
"<="        { return (LE); }
"<"         { return ('<'); }
"="         { return ('='); }

";"         { return (';'); }
"("         { return ('('); }
")"         { return (')'); }
"{"         { return ('{'); }
"}"         { return ('}'); }
","         { return (','); }
":"         { return (':'); }

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */

\" {  BEGIN (STRING);
        string_buf_ptr = string_buf;
        memset(string_buf,'\0',sizeof(string_buf));
        //readLine=0;
        strl=0;
      } /*switch comment mode*/

<STRING>\" { BEGIN (INITIAL);
              if(strlen(string_buf)!=strl){
                cool_yylval.error_msg = "String contains null character";
                return (ERROR);
              }
              if(strlen(string_buf)<MAX_STR_CONST){
                  cool_yylval.symbol=stringtable.add_string(string_buf);
                  return (STR_CONST);
              }
              cool_yylval.error_msg = "String constant too long";
              return (ERROR);
              }

<STRING><<EOF>> {  cool_yylval.error_msg = "EOF in string constant"; 
                    BEGIN(INITIAL); 
                    return (ERROR); 
                  }

<STRING>\\(\n|\r) { *string_buf_ptr++ = yytext[1];
                    strl++;
                    curr_lineno++;
                  }

<STRING>\\n  {*string_buf_ptr++ = '\n';strl++;}
<STRING>\\t  {*string_buf_ptr++ = '\t';strl++;}
<STRING>\\b  {*string_buf_ptr++ = '\b';strl++;}
<STRING>\\f  {*string_buf_ptr++ = '\f';strl++;}

<STRING>\\.  {*string_buf_ptr++ = yytext[1];strl++;}

<STRING>\n  { cool_yylval.error_msg = "Unterminated string constant";
              curr_lineno++;
              BEGIN (INITIAL);
              return (ERROR);
            }

<STRING>[^\\\n\"]+        {
        char *yptr = yytext;
        int flag=0;
        for(int i=0;i<yyleng;i++){
          *string_buf_ptr++ = *yptr++;
          strl++;
        }
      }

 /*
  * TYPEID and OBJECTID
  */

[A-Z]{STR} {  cool_yylval.symbol=idtable.add_string(yytext);
            return (TYPEID);
          }
[a-z]{STR} {  cool_yylval.symbol=idtable.add_string(yytext);
            return (OBJECTID);
          }

 /*
  *  Integer constants
  */

{DIGIT} {
  cool_yylval.symbol = inttable.add_string(yytext);
  return (INT_CONST) ;
}

 /*
  *  Unknown token
  */
. { cool_yylval.error_msg = yytext; return (ERROR); }

%%
