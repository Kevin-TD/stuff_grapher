%{
open Ast

let mkpos (startpos : Lexing.position) = 
  { line = startpos.pos_lnum; col = startpos.pos_cnum - startpos.pos_bol }

%}

%token <string> IDENT
%token <float> REAL
%token <int> INTEGER
%token EQUAL
%token NEWLINE
%token EOF
%token PLUS
%token MINUS
%token MULT
%token DIV
%token EXP
%token LEFT_SQR_BRACKET
%token RIGHT_SQR_BRACKET
%token COMMA
%token LEFT_PAREN 
%token RIGHT_PAREN
%token IF THEN ELSE
%token LT LTE GT GTE
%token NOT_EQUAL
%token FUN ARROW
%token PIPE COLON
%token WHEN FOR
%token LET IN

%left PLUS MINUS
%left MULT DIV
%right UMINUS
%right EXP

%start main
%type <prog> main

%%

main:
  | s = stmts EOF { s }

stmts:
  | /* empty */ { [] }
  | s = stmt newlines rest = stmts { s :: rest }
  | s = stmt EOF { [s] }

// allows for empty lines
newlines: 
  | NEWLINE           { }
  | newlines NEWLINE  { } 

stmt:
  | id = IDENT EQUAL e = expr
    { Assign (id, e, mkpos $startpos) }
  | name = IDENT LEFT_PAREN params = expr_list_elems RIGHT_PAREN EQUAL body = expr 
    { Assign (name, Fn (params, body), mkpos $startpos) }
  | e = expr { Assign ("_" ^ (string_of_int (mkpos $startpos).line), e, mkpos $startpos) }

expr:
  | i = INTEGER { Integer i }
  | r = REAL { Real r }
  | id = IDENT { Ident id }
  | e1 = expr PLUS e2 = expr { Plus(e1, e2) }
  | e1 = expr MINUS e2 = expr { Minus(e1, e2) }
  | e1 = expr MULT e2 = expr { Mult(e1, e2) }
  | e1 = expr DIV e2 = expr { Div(e1, e2) }
  | e1 = expr EXP e2 = expr { Exp(e1, e2) } 
  | MINUS e = expr %prec UMINUS { Neg e }
  | LEFT_PAREN e = expr RIGHT_PAREN { e }
  | e1 = expr EQUAL e2 = expr { Compare(e1, e2) }
  | e1 = expr NOT_EQUAL e2 = expr { NotEqual(e1, e2) }
  | e1 = expr LT e2 = expr { Lt(e1, e2) }
  | e1 = expr LTE e2 = expr { Lte(e1, e2) }
  | e1 = expr GT e2 = expr { Gt(e1, e2) }
  | e1 = expr GTE e2 = expr { Gte(e1, e2) }
  | IF e1 = expr THEN e2 = expr ELSE e3 = expr { If_else(e1, e2, e3) }
  | LEFT_SQR_BRACKET l = expr_list_elems RIGHT_SQR_BRACKET { ExprList l }
  | name = IDENT LEFT_PAREN e2 = expr_list_elems RIGHT_PAREN { FunctionCall(name, e2) }
  | FUN param = expr ARROW body = expr { Fn ([param], body) }
  | FUN LEFT_PAREN params = expr_list_elems RIGHT_PAREN ARROW body = expr
    { Fn (params, body) }
  | e = expr LEFT_SQR_BRACKET idx = expr RIGHT_SQR_BRACKET { IndexOf(e, idx)}
  | LEFT_SQR_BRACKET output = expr FOR id = IDENT EQUAL l = expr RIGHT_SQR_BRACKET
  { ListComp (output, id, l) }
  | LEFT_SQR_BRACKET output = expr WHEN cond = expr FOR id = IDENT EQUAL l = expr RIGHT_SQR_BRACKET
  { ListCompFilter (output, cond, id, l) }
  | LET id = IDENT EQUAL e1 = expr IN e2 = expr 
  { LetIn (id, e1, e2) }

expr_list_elems:
  | /* empty */ { [] }
  | xs = separated_list(COMMA, expr) { xs }