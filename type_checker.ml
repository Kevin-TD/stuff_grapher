open Ast

type expr_type =
  | Num
  | Bool
  | List of expr_type
  | Void
  | Fn of expr_type list * expr_type (* param types, return type*)
