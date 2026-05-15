type expr =
  | Integer 
  | Number of float
  | Ident of string
  | Plus of expr * expr
  | Minus of expr * expr
  | Mult of expr * expr
  | Div of expr * expr
  | Exp of expr * expr
  | Neg of expr
  | Compare of expr * expr
  | NotEqual of expr * expr
  | Gt of expr * expr
  | Gte of expr * expr
  | Lt of expr * expr
  | Lte of expr * expr
  | If_else of expr * expr * expr
  | ExprList of expr list
  | FunctionCall of string * expr list (* name, args *)
  | IndexOf of expr * expr (* list type, numerical index (0 indexed) *)
  (* non-typeable *)
  | True
  | False 
  | Unresolved of expr
  | Fn of expr list * expr (* unnamed function that just has params and body *)

and stmt =
  | FunctionDef of string * expr list * expr (* name, params, body *)
  | Assign of string * expr 

type prog = stmt list

let rec string_of_expr = function
  | Number f -> "Number(" ^ string_of_float f ^ ")"
  | Ident x -> "Ident(" ^ x ^ ")"
  | Plus (e1, e2) -> "Plus(" ^ string_of_expr e1 ^ ", " ^ string_of_expr e2 ^ ")"
  | Minus (e1, e2) -> "Minus(" ^ string_of_expr e1 ^ ", " ^ string_of_expr e2 ^ ")"
  | Neg e -> "Neg(" ^ string_of_expr e ^ ")"
  | Mult (e1, e2) -> "Mult(" ^ string_of_expr e1 ^ ", " ^ string_of_expr e2 ^ ")"
  | Div (e1, e2) -> "Div(" ^ string_of_expr e1 ^ ", " ^ string_of_expr e2 ^ ")"
  | Exp (e1, e2) -> "Exp(" ^ string_of_expr e1 ^ ", " ^ string_of_expr e2 ^ ")"
  | Compare (e1, e2) -> "Compare(" ^ string_of_expr e1 ^ ", " ^ string_of_expr e2 ^ ")"
  | NotEqual (e1, e2) -> "NotEqual(" ^ string_of_expr e1 ^ ", " ^ string_of_expr e2 ^ ")"
  | Lt (e1, e2) -> "Lt(" ^ string_of_expr e1 ^ ", " ^ string_of_expr e2 ^ ")"
  | Lte (e1, e2) -> "Lte(" ^ string_of_expr e1 ^ ", " ^ string_of_expr e2 ^ ")"
  | Gt (e1, e2) -> "Gt(" ^ string_of_expr e1 ^ ", " ^ string_of_expr e2 ^ ")"
  | Gte (e1, e2) -> "Gte(" ^ string_of_expr e1 ^ ", " ^ string_of_expr e2 ^ ")"
  | If_else (e1, e2, e3) -> "If_else(" ^ string_of_expr e1 ^ ", " ^ string_of_expr e2 ^ ", " ^ string_of_expr e3 ^ ")"
  | ExprList l -> 
      "List([" ^ 
      List.fold_left (fun acc e -> (string_of_expr e) ^ ", " ^ acc ) "" l ^
      "])"
  | FunctionCall (name, params) ->
    "FunctionCall(" ^ name ^ ", " ^ string_of_expr (ExprList params) ^ ")"
  | True -> "True"
  | False -> "False"
  | Unresolved x -> "Unresolved(" ^ string_of_expr x ^ ")"
  | Fn (params, body) -> 
    "Fn(" ^ string_of_expr (ExprList params) ^ ", " ^ string_of_expr body ^ ")"
  | IndexOf (e, idx) ->
    "IndexOf(" ^ string_of_expr e ^ ", " ^ string_of_expr idx ^ ")"
let rec string_of_stmt = function
    | Assign (x, s) -> "Assign(" ^ x ^ ", " ^ string_of_expr s ^ ")"
    | FunctionDef (x, e1, e2) -> 
    "FunctionDef(" ^ x ^ ", " ^ string_of_expr (ExprList e1) ^ ", " ^ string_of_expr e2 ^ ")"
  
let print_prog (p : prog) =
  List.iter (fun e -> print_endline (string_of_stmt e)) p