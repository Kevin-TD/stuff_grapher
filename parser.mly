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
  | n = NUMBER { Number n }
  | id = IDENT { Ident id }
  | id = IDENT EQUAL x = stmt
      { Assign (id, x) }
  | e1 = stmt PLUS e2 = stmt { Plus(e1, e2) }
  | e1 = stmt MINUS e2 = stmt { Minus(e1, e2) }
  | e1 = stmt MULT e2 = stmt { Mult(e1, e2) }
  | e1 = stmt DIV e2 = stmt { Div(e1, e2) }
  | e1 = stmt EXP e2 = stmt { Exp(e1, e2) } 
  | MINUS e = stmt %prec UMINUS { Neg e }
  | LEFT_PAREN e = stmt RIGHT_PAREN { e }
  | e1 = stmt COMPARE e2 = stmt { Compare(e1, e2) }
  | e1 = stmt LT e2 = stmt { Lt(e1, e2) }
  | e1 = stmt LTE e2 = stmt { Lte(e1, e2) }
  | e1 = stmt GT e2 = stmt { Gt(e1, e2) }
  | e1 = stmt GTE e2 = stmt { Gte(e1, e2) }
  | IF e1 = stmt THEN e2 = stmt ELSE e3 = stmt { If_else(e1, e2, e3) }
  | LEFT_SQR_BRACKET elems = list_elems RIGHT_SQR_BRACKET { StmtList (List.rev elems) }
  | e1 = stmt LEFT_PAREN e2 = list_elems RIGHT_PAREN EQUAL e3 = stmt { FunctionDef(e1, List.rev e2, e3) }
  | e1 = stmt LEFT_PAREN e2 = list_elems RIGHT_PAREN { FunctionCall(e1, List.rev e2) }

list_elems:
  elems = rev_list_elems { List.rev elems }

rev_list_elems:
  | /* empty */ { [] }
  | xs = separated_list(COMMA, stmt) { xs }