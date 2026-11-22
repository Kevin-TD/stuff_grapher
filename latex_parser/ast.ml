type stmt =
  | Ident of string
  | OperatorCall of string * stmt
  (* subscript, superscript, arguments in {}... *)
  | LatexFunctionCall of string * stmt list
  (* a normal function f(...). right now just the name and args, so no diff b/w def and call *)
  | UserFunctionCall of string * stmt list
  | Number of string
  | Plus of stmt * stmt
  | Minus of stmt * stmt
  | Mul of stmt * stmt
  | Div of stmt * stmt
  | Neg of stmt
  | Lt of stmt * stmt
  | Gt of stmt * stmt
  | Lte of stmt * stmt
  | Gte of stmt * stmt
  | Ne of stmt * stmt
  | NTuple of stmt list
  | List of stmt list
  | AccessAttr of stmt * stmt
  | If_else of stmt * stmt * stmt

  (* e.g., n=1 in a sum's subscript *)
  | Assign of stmt * stmt

  (* a call to a function that has a subscript, superscript,
  and body  *)
  | OpCall3 of string * stmt * stmt * stmt
  | Exp of stmt * stmt
  | Index of stmt * stmt
  | ListComp of stmt * string * stmt
  | ListCompFilter of stmt * stmt * string * stmt
  | LetIn of string * stmt * stmt
  | Fn of stmt list * stmt

(* how to differentiate compare = and assign = ... we'll see if it matters *)
(* list comp ... *)

type prog = stmt list

let rec string_of_stmt (s : stmt) = match s with
  | Ident s -> "Ident(" ^ s ^ ")"
  | OperatorCall (s, stmt) -> "OperatorName(" ^ s ^ ", " ^ string_of_stmt stmt ^ ")"
  | LatexFunctionCall (name, args) -> (
    let lst = ref [] in
    List.iter (fun s -> lst := ("{" ^ string_of_stmt s ^ "}") :: !lst) args;
    lst := List.rev !lst;
    let els = String.concat "" !lst in
    "FunctionCall(" ^ name ^ ", " ^ els ^ ")"
  )
  | UserFunctionCall (name, args) -> (
    let lst = ref [] in
    List.iter (fun s -> lst :=  string_of_stmt s :: !lst) args;
    lst := List.rev !lst;
    let els = String.concat ", " !lst in
    "FunctionCall(" ^ name ^ ", " ^ els ^ ")"
  )
  | Number n -> "Number(" ^ n ^ ")"
  | Assign (s1, s2) -> "Assign(" ^ string_of_stmt s1 ^ ", " ^ string_of_stmt s2 ^ ")"
  | Plus (s1, s2) -> 
    "Plus(" ^ string_of_stmt s1 ^ ", " ^ string_of_stmt s2 ^ ")"
  | Minus (s1, s2) -> 
    "Minus(" ^ string_of_stmt s1 ^ ", " ^ string_of_stmt s2 ^ ")"
  | Mul (s1, s2) -> 
    "Mul(" ^ string_of_stmt s1 ^ ", " ^ string_of_stmt s2 ^ ")"
  | Div (s1, s2) -> 
    "Div(" ^ string_of_stmt s1 ^ ", " ^ string_of_stmt s2 ^ ")"
  | Neg s -> "Neg(" ^ string_of_stmt s ^ ")"
  | Lt (s1, s2) -> 
    "Lt(" ^ string_of_stmt s1 ^ ", " ^ string_of_stmt s2 ^ ")"
  | Gt (s1, s2) -> 
    "Gt(" ^ string_of_stmt s1 ^ ", " ^ string_of_stmt s2 ^ ")" 
  | Lte (s1, s2) -> 
    "Lte(" ^ string_of_stmt s1 ^ ", " ^ string_of_stmt s2 ^ ")"
  | Gte (s1, s2) -> 
    "Gte(" ^ string_of_stmt s1 ^ ", " ^ string_of_stmt s2 ^ ")"
  | Ne (s1, s2) -> 
    "Ne(" ^ string_of_stmt s1 ^ ", " ^ string_of_stmt s2 ^ ")"
  | AccessAttr (s1, s2) -> 
    "AccessAttr(" ^ string_of_stmt s1 ^ ", " ^ string_of_stmt s2 ^ ")"
  | NTuple (ss) -> (
    let lst = ref [] in
    List.iter (fun s -> lst := string_of_stmt s :: !lst) ss;
    lst := List.rev !lst;
    let els = String.concat ", " !lst in
    "NTuple(" ^ els ^ ")"
  )
  | List (ss) -> (
    let lst = ref [] in
    List.iter (fun s -> lst := string_of_stmt s :: !lst) ss;
    lst := List.rev !lst;
    let els = String.concat ", " !lst in
    "List(" ^ els ^ ")"
  )
  | If_else (s1, s2, s3) -> "If_else(" ^ string_of_stmt s1 ^ ", " ^ string_of_stmt s2 ^ ", " ^ string_of_stmt s3 ^ ")"
  | OpCall3 (name, subscript, superscript, body) -> (
    "OpCall3(" ^ name ^ ", " ^ string_of_stmt subscript ^ ", " ^
    string_of_stmt superscript ^ ", " ^ string_of_stmt body ^ ")"
  )
  | Exp (s1, s2) ->
    "Exp(" ^ string_of_stmt s1 ^ ", " ^ string_of_stmt s2 ^ ")"
  | Index (s1, s2) ->
    "Index(" ^ string_of_stmt s1 ^ ", " ^ string_of_stmt s2 ^ ")"
  | ListComp (o, v, l) ->
    "ListComp(" ^ string_of_stmt o ^ ", " ^ v ^ ", " ^ string_of_stmt l ^ ")"
  | ListCompFilter (o, c, v, l) ->
    "ListCompFilter(" ^ string_of_stmt o ^ ", " ^ string_of_stmt c ^ ", " ^ v ^ ", " ^ string_of_stmt l ^ ")"
  | LetIn (v, a, b) ->
    "LetIn(" ^ v ^ ", " ^ string_of_stmt a ^ ", " ^ string_of_stmt b ^ ")"
  | Fn (ps, b) ->
    "Fn([" ^ String.concat ", " (List.map string_of_stmt ps) ^ "], " ^ string_of_stmt b ^ ")"

let print_prog (p : prog) =
  List.iter (fun e -> print_endline (string_of_stmt e)) p