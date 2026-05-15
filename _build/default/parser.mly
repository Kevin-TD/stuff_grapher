%{
open Ast
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
%token COMPARE
%token LT LTE GT GTE
%token NOT_EQUAL
%token FUN ARROW

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
  | s = stmt NEWLINE rest = stmts { s :: rest }
  | s = stmt EOF { [s] }

stmt:
  | id = IDENT EQUAL e = expr
    { Assign (id, e) }
  | name = IDENT LEFT_PAREN e2 = expr_list_elems RIGHT_PAREN EQUAL e3 = expr 
    { FunctionDef(name, e2, e3) }

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
  | e1 = expr COMPARE e2 = expr { Compare(e1, e2) }
  | e1 = expr NOT_EQUAL e2 = expr { NotEqual(e1, e2) }
  | e1 = expr LT e2 = expr { Lt(e1, e2) }
  | e1 = expr LTE e2 = expr { Lte(e1, e2) }
  | e1 = expr GT e2 = expr { Gt(e1, e2) }
  | e1 = expr GTE e2 = expr { Gte(e1, e2) }
  | IF e1 = expr THEN e2 = expr ELSE e3 = expr { If_else(e1, e2, e3) }
  | LEFT_SQR_BRACKET elems = expr_list_elems RIGHT_SQR_BRACKET { ExprList elems }
  | name = IDENT LEFT_PAREN e2 = expr_list_elems RIGHT_PAREN { FunctionCall(name, e2) }
  | FUN param = expr ARROW body = expr { Fn ([param], body) }
  | FUN LEFT_PAREN params = expr_list_elems RIGHT_PAREN ARROW body = expr
    { Fn (params, body) }

  // r1 = x(fun x -> x + 1, 3)
// r2 = x1(fun (x, y) -> x + y)

  | e = expr LEFT_SQR_BRACKET idx = expr RIGHT_SQR_BRACKET { IndexOf(e, idx)}
expr_list_elems:
  elems = rev_expr_list_elems { List.rev elems }

rev_expr_list_elems:
  | /* empty */ { [] }
  | xs = separated_list(COMMA, expr) { xs }