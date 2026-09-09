type expr =
  | Ident of string
  | OperatorName of string
  | Number of float
  | Plus of expr * expr
  | Minus of expr * expr
  | Mul of expr * expr
  | Div of expr * expr
  | Exp of expr * expr
  | Neg of expr

  (* e.g., n=1 in a sum's subscript *)
  | VarAssign of string * expr

  (* a call to a function that has a subscript, superscript,
  and body  *)
  | OpCall3 of expr * expr * expr