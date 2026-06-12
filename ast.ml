type pos = { line: int; col: int }

type expr =
  | Real of float
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
  | Fn of expr list * expr (* unnamed function that just has params and body *)
  | IndexOf of expr * expr (* list type, numerical index (0 indexed) *)
  | ListCompFilter of expr * expr * string * expr
  | ListComp of expr * string * expr
  | LetIn of string * expr * expr
  (* non-typeable: the user cannot create instances of these exprs but they are nonetheless
  used internally. 
  note: a user can reference an ExternFn by its name (e.g., "sqrt") but cannot create a value of that type. *)
  | UndefinedError of expr list
  | IndexOutOfBoundsError of expr
  | FunctionCallError of (string * expr)
  | True
  | False 
  | Unresolved of expr
  | ExternFn of int * (expr list -> expr) (* arity, implementiation of "outside" (externed) 
  function. e.g., sqrt *)

and stmt =
  | Assign of string * expr * pos

type prog = stmt list

type var = {
  name: string;
  line: int option;
  value: expr
}

type environment = var list

let rec string_of_expr = function
  | Real r -> "Real(" ^ string_of_float r ^ ")"
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
    let lst = ref [] in
    List.iter (fun e -> lst := string_of_expr e :: !lst) l;
    lst := List.rev !lst;
    let els = String.concat ", " !lst in
    "List([" ^ els ^ "])"
  | FunctionCall (name, params) ->
    "FunctionCall(" ^ name ^ ", " ^ string_of_expr (ExprList params) ^ ")"
  | True -> "True"
  | False -> "False"
  | Unresolved x -> "Unresolved(" ^ string_of_expr x ^ ")"
  | Fn (params, body) -> 
    "Fn(" ^ string_of_expr (ExprList params) ^ ", " ^ string_of_expr body ^ ")"
  | IndexOf (e, idx) ->
    "IndexOf(" ^ string_of_expr e ^ ", " ^ string_of_expr idx ^ ")"
  | UndefinedError l ->
    "UndefinedError(" ^ string_of_expr (ExprList l) ^ ")"
  | IndexOutOfBoundsError e ->
    "IndexOutOfBoundsError(" ^ string_of_expr e ^ ")"
  | FunctionCallError (msg, e) -> 
    "FunctionCallError(" ^ msg ^ ", " ^ string_of_expr e ^ ")"
  | ExternFn (arity, _) -> "ExternFn(" ^ string_of_int arity ^ ", ...)"
  | ListComp (e, s, l) -> "ListComp(" ^ string_of_expr e ^ ", " ^ s ^ ", " ^ string_of_expr l ^ ")"
  | ListCompFilter (e, f, s, l) -> "ListCompFilter(" ^ string_of_expr e ^ ", " ^ string_of_expr f ^ ", " ^ s ^ ", " ^ string_of_expr l ^ ")"
  | LetIn (s, e1, e2) -> "LetIn(" ^ s ^ ", " ^ string_of_expr e1 ^ ", " ^ string_of_expr e2 ^ ")"
    
let string_of_stmt = function
  | Assign (x, s, p) -> "Assign(" ^ x ^ ", " ^ string_of_expr s ^ ", Line " ^ string_of_int p.line ^ ")" 
  
let string_of_var v = 
  let string_of_line = function
    | Some i -> string_of_int i
    | None -> "None"
  in 
  "(" ^ v.name ^ ", " ^ string_of_line v.line ^ "): " ^ string_of_expr v.value 

let print_prog (p : prog) =
  List.iter (fun e -> print_endline (string_of_stmt e)) p