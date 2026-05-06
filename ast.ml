type stmt =
  | Number of float
  | Ident of string
  | Assign of string * stmt 
  | Plus of stmt * stmt
  | Minus of stmt * stmt
  | Neg of stmt
  | Mult of stmt * stmt
  | Div of stmt * stmt
  | Exp of stmt * stmt
  | Compare of stmt * stmt
  | Gt of stmt * stmt
  | Gte of stmt * stmt
  | Lt of stmt * stmt
  | Lte of stmt * stmt
  | If_else of stmt * stmt * stmt
  | StmtList of stmt list
  | FunctionDef of stmt * stmt list * stmt (* name, params, body *)
  | FunctionCall of stmt * stmt list (* name, params *)

type prog = stmt list

let rec string_of_stmt = function
  | Number f -> "Number(" ^ string_of_float f ^ ")"
  | Ident x -> "Ident(" ^ x ^ ")"
  | Assign (x, s) -> "Assign(" ^ x ^ ", " ^ string_of_stmt s ^ ")"
  | Plus (e1, e2) -> "Plus(" ^ string_of_stmt e1 ^ ", " ^ string_of_stmt e2 ^ ")"
  | Minus (e1, e2) -> "Minus(" ^ string_of_stmt e1 ^ ", " ^ string_of_stmt e2 ^ ")"
  | Neg e -> "Neg(" ^ string_of_stmt e ^ ")"
  | Mult (e1, e2) -> "Mult(" ^ string_of_stmt e1 ^ ", " ^ string_of_stmt e2 ^ ")"
  | Div (e1, e2) -> "Div(" ^ string_of_stmt e1 ^ ", " ^ string_of_stmt e2 ^ ")"
  | Exp (e1, e2) -> "Exp(" ^ string_of_stmt e1 ^ ", " ^ string_of_stmt e2 ^ ")"
  | Compare (e1, e2) -> "Compare(" ^ string_of_stmt e1 ^ ", " ^ string_of_stmt e2 ^ ")"
  | Lt (e1, e2) -> "Lt(" ^ string_of_stmt e1 ^ ", " ^ string_of_stmt e2 ^ ")"
  | Lte (e1, e2) -> "Lte(" ^ string_of_stmt e1 ^ ", " ^ string_of_stmt e2 ^ ")"
  | Gt (e1, e2) -> "Gt(" ^ string_of_stmt e1 ^ ", " ^ string_of_stmt e2 ^ ")"
  | Gte (e1, e2) -> "Gte(" ^ string_of_stmt e1 ^ ", " ^ string_of_stmt e2 ^ ")"
  | If_else (e1, e2, e3) -> "If_else(" ^ string_of_stmt e1 ^ ", " ^ string_of_stmt e2 ^ ", " ^ string_of_stmt e3 ^ ")"
  | StmtList l -> 
      "List([" ^ 
      List.fold_left (fun acc e -> (string_of_stmt e) ^ ", " ^ acc ) "" l ^
      "])"
  | FunctionDef (e1, e2, e3) -> 
    "FunctionDef(" ^ string_of_stmt e1 ^ ", " ^ string_of_stmt (StmtList e2) ^ ", " ^ string_of_stmt e3 ^ ")"
  | FunctionCall (e1, e2) ->
    "FunctionCall(" ^ string_of_stmt e1 ^ ", " ^ string_of_stmt (StmtList e2) ^ ")"
  
let print_prog (p : prog) =
  List.iter (fun e -> print_endline (string_of_stmt e)) p