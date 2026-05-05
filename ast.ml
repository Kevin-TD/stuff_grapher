type stmt =
  | Number of float
  | Ident of string
  | Assign of string * stmt 

type prog = stmt list

let rec string_of_stmt = function
  | Number f -> "Number(" ^ string_of_float f ^ ")"
  | Ident x -> "Ident(" ^ x ^ ")"
  | Assign (x, s) -> "Assign(" ^ x ^ ", " ^ string_of_stmt s ^ ")"

let print_prog (p : prog) =
  List.iter (fun e -> print_endline (string_of_stmt e)) p