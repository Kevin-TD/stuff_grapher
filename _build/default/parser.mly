%{
open Ast
%}

%token <string> IDENT
%token <float> NUMBER
%token EQUAL
%token NEWLINE
%token EOF

%start main
%type <prog> main

%%

main:
  | s = stmts EOF { s }

stmts:
  | /* empty */ { [] }
  | s = stmt NEWLINE rest = stmts { s :: rest }
  | s = stmt EOF { [s] }

stmt:
  | id = IDENT EQUAL n = NUMBER
      { Assign (id, Number n) }