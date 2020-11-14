
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "tokens.h"

#define   YYCTYPE     char
#define   YYCURSOR    s->cur
#define   YYMARKER    s->ptr

typedef struct Scanner {
  char *top, *cur, *ptr, *pos;
  int line;  
} Scanner;

int scan(Scanner* s, char *buff_end) {
  
regular:
  if (s->cur >= buff_end) {
    return END_TOKEN;
  }
  s->top = s->cur;

/*!re2c
  re2c:yyfill:enable = 0;
 
  ALPHANUMS = [a-zA-Z0-9]+;
  whitespace = [ \t\v\f]+;
  dig = [0-9];
  let = [a-zA-Z_];
  hex = [a-fA-F0-9];
  int_des = [uUlL]*;
  any = [\000-\377];
*/

/*!re2c
  "/*"            { goto comment; }
  "="             { return EQUAL; }
  '('             { return LPAREN; }
  ")"             { return RPAREN; }
  "{"             { return LBRACE; }
  "}"             { return RBRACE; }
  ";"             { return SEMICOLON; }
  "int"           { return INT_TYPE; }
  "return"        { return RETURN; }
  ["]([^"]+)["]   { return STRING_LITERAL; }
  let (let|dig)*  { return NAME; }
  whitespace      { goto regular; }

	("0" [xX] hex+ int_des?) | ("0" dig+ int_des?) | (dig+ int_des?)
  { return(INT_LITERAL); }

  "\r\n"|"\n"
  {
    s->pos = s->cur;
    s->line++;
    goto regular;
  }

  any
  {
    printf("unexpected character: %c\n", *s->cur);
    goto regular;
  }
*/

comment:
/*!re2c
  "*/"          { goto regular; }
  "\n"          { s->line++; goto comment; }
  any           { goto comment; }
*/
}

