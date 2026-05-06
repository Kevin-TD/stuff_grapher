%{
open Ast
%}

%token <string> IDENT
%token <float> NUMBER
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
  | e1 = expr LEFT_PAREN e2 = expr_list_elems RIGHT_PAREN EQUAL e3 = expr 
    { FunctionDef(e1, e2, e3) }

expr:
  | n = NUMBER { Number n }
  | id = IDENT { Ident id }
  | e1 = expr PLUS e2 = expr { Plus(e1, e2) }
  | e1 = expr MINUS e2 = expr { Minus(e1, e2) }
  | e1 = expr MULT e2 = expr { Mult(e1, e2) }
  | e1 = expr DIV e2 = expr { Div(e1, e2) }
  | e1 = expr EXP e2 = expr { Exp(e1, e2) } 
  | MINUS e = expr %prec UMINUS { Neg e }
  | LEFT_PAREN e = expr RIGHT_PAREN { e }
  | e1 = expr COMPARE e2 = expr { Compare(e1, e2) }
  | e1 = expr LT e2 = expr { Lt(e1, e2) }
  | e1 = expr LTE e2 = expr { Lte(e1, e2) }
  | e1 = expr GT e2 = expr { Gt(e1, e2) }
  | e1 = expr GTE e2 = expr { Gte(e1, e2) }
  | IF e1 = expr THEN e2 = expr ELSE e3 = expr { If_else(e1, e2, e3) }
  | LEFT_SQR_BRACKET elems = expr_list_elems RIGHT_SQR_BRACKET { ExprList elems }
  | e1 = expr LEFT_PAREN e2 = expr_list_elems RIGHT_PAREN { FunctionCall(e1, e2) }

expr_list_elems:
  elems = rev_expr_list_elems { List.rev elems }

rev_expr_list_elems:
  | /* empty */ { [] }
  | xs = separated_list(COMMA, expr) { xs }