%{
  open Ast
%}

%token <string> IDENT
%token <string> FUNCTION
%token <string> NUMBER
%token OPERATOR_NAME
%token EQUAL
%token NEWLINE
%token EOF
%token PLUS
%token MINUS
%token MUL DIV
%token LEFT_CURLY_BRACE
%token RIGHT_CURLY_BRACE
%token LEFT_SQUARE_BRACKET
%token RIGHT_SQUARE_BRACKET
%token LEFT_PAREN
%token RIGHT_PAREN
%token SUBSCRIPT
%token SUPERSCRIPT
%token <string> SUPERSCRIPT_ONE
%token ACCESS_DOT
%token RIGHT_ARROW
%token LEFT_ARROW
%token LT GT LTE GTE NE
%token COLON
%token COMMA
%token IF THEN ELSE
%token FOR WHEN LET IN FUN

%nonassoc IN ELSE RIGHT_ARROW
%nonassoc EQUAL
%left LT GT LTE GTE NE
%left PLUS MINUS
%left MUL DIV
%right UMINUS
%right SUPERSCRIPT SUPERSCRIPT_ONE
%right ACCESS_DOT

%start main
%type <prog> main
%%

main:
  | s = stmts EOF {s}

stmts:
  | /* empty */ { [] }
  | s = stmt newlines rest = stmts { s :: rest }
  | s = stmt EOF { [s] }

newlines:
  | NEWLINE           { }
  | newlines NEWLINE  { }

stmt:
  | n = NUMBER { Number n }
  | id = IDENT { Ident id }
  | s1 = stmt EQUAL s2 = stmt { Assign(s1, s2) }
  | s1 = stmt PLUS s2 = stmt { Plus(s1, s2) }
  | s1 = stmt MINUS s2 = stmt { Minus(s1, s2) }
  | s1 = stmt MUL s2 = stmt { Mul(s1, s2) }
  | s1 = stmt DIV s2 = stmt { Div(s1, s2) }
  | MINUS s = stmt %prec UMINUS { Neg s }
  | s1 = stmt LT s2 = stmt { Lt(s1, s2) }
  | s1 = stmt GT s2 = stmt { Gt(s1, s2) }
  | s1 = stmt LTE s2 = stmt { Lte(s1, s2) }
  | s1 = stmt GTE s2 = stmt { Gte(s1, s2) }
  | s1 = stmt NE s2 = stmt { Ne(s1, s2) }
  | OPERATOR_NAME LEFT_CURLY_BRACE s =  IDENT RIGHT_CURLY_BRACE
  { Ident s }
  | OPERATOR_NAME LEFT_CURLY_BRACE s = IDENT RIGHT_CURLY_BRACE LEFT_PAREN xs = stmt_list RIGHT_PAREN
  { UserFunctionCall(s, xs) }
  | IF s1 = stmt THEN s2 = stmt ELSE s3 = stmt
  { If_else(s1, s2, s3) }
  | id = IDENT LEFT_PAREN xs = stmt_list RIGHT_PAREN { UserFunctionCall(id, xs) }
  | f = FUNCTION args = arg_list { LatexFunctionCall(f, args) }
  | f = FUNCTION LEFT_PAREN xs = stmt_list RIGHT_PAREN { LatexFunctionCall(f, xs) }
  | f = FUNCTION SUBSCRIPT subscript = braced_stmt superscript = SUPERSCRIPT_ONE body = stmt
  { OpCall3 (f, subscript, Ident superscript, body) }
  | f = FUNCTION SUBSCRIPT subscript = braced_stmt SUPERSCRIPT s = braced_stmt body = stmt
  { OpCall3 (f, subscript, s, body) }
  | s1 = stmt SUPERSCRIPT s2 = braced_stmt { Exp(s1, s2) }
  | s1 = stmt n = SUPERSCRIPT_ONE { Exp(s1, Number n) }
  | s = stmt LEFT_SQUARE_BRACKET i = stmt RIGHT_SQUARE_BRACKET { Index(s, i) }
  | LEFT_SQUARE_BRACKET o = stmt FOR id = IDENT EQUAL l = stmt RIGHT_SQUARE_BRACKET
  { ListComp(o, id, l) }
  | LEFT_SQUARE_BRACKET o = stmt WHEN c = stmt FOR id = IDENT EQUAL l = stmt RIGHT_SQUARE_BRACKET
  { ListCompFilter(o, c, id, l) }
  | LET id = IDENT EQUAL e1 = stmt IN e2 = stmt { LetIn(id, e1, e2) }
  | FUN id = IDENT RIGHT_ARROW b = stmt { Fn([Ident id], b) }
  | FUN LEFT_PAREN ps = stmt_list RIGHT_PAREN RIGHT_ARROW b = stmt { Fn(ps, b) }
  | LEFT_PAREN stmts = stmt_list RIGHT_PAREN { NTuple (stmts) }
  | LEFT_SQUARE_BRACKET stmts = stmt_list RIGHT_SQUARE_BRACKET { List (stmts) }
  | s = stmt ACCESS_DOT attr = stmt { AccessAttr(s, attr) }

stmt_list:
  | xs = separated_list(COMMA, stmt) { xs }

braced_stmt:
  | LEFT_CURLY_BRACE s = stmt RIGHT_CURLY_BRACE { s }

arg_list:
  | xs = nonempty_list(braced_stmt) { xs }