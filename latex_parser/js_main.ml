open Js_of_ocaml
open Ast

let rec split_assign (s : stmt) : (string * stmt) option =
  let lift f l = match split_assign l with
    | Some (v, e) -> Some (v, f e)
    | None -> None in
  match s with
  | Assign (Ident v, e) -> Some (v, e)
  | Plus (l, r)  -> lift (fun a -> Plus (a, r)) l
  | Minus (l, r) -> lift (fun a -> Minus (a, r)) l
  | Mul (l, r)   -> lift (fun a -> Mul (a, r)) l
  | Div (l, r)   -> lift (fun a -> Div (a, r)) l
  | _ -> None

let rec sgl_of_latex (s : stmt) : string =
  match s with
  | Ident s -> s
  | Number n -> n
  | Plus (s1, s2) -> sgl_of_latex s1 ^ " + " ^ sgl_of_latex s2
  | Minus (s1, s2) -> sgl_of_latex s1 ^ " - " ^ sgl_of_latex s2
  | Mul (s1, s2) -> sgl_of_latex s1 ^ " * " ^ sgl_of_latex s2
  | Div (s1, s2) -> sgl_of_latex s1 ^ " / " ^ sgl_of_latex s2
  | Neg s -> "-" ^ sgl_of_latex s
  | Lt (s1, s2) -> sgl_of_latex s1 ^ " < " ^ sgl_of_latex s2
  | Gt (s1, s2) -> sgl_of_latex s1 ^ " > " ^ sgl_of_latex s2
  | Lte (s1, s2) -> sgl_of_latex s1 ^ " <= " ^ sgl_of_latex s2
  | Gte (s1, s2) -> sgl_of_latex s1 ^ " >= " ^ sgl_of_latex s2
  | Ne (s1, s2) -> sgl_of_latex s1 ^ " != " ^ sgl_of_latex s2
  | If_else (cond, t, e) ->
      "if " ^ sgl_of_latex cond ^ " then " ^ sgl_of_latex t ^ " else " ^ sgl_of_latex e
  | List ss -> "[" ^ String.concat ", " (List.map sgl_of_latex ss) ^ "]"
  | NTuple ss -> "(" ^ String.concat ", " (List.map sgl_of_latex ss) ^ ")"
  | AccessAttr (s1, s2) -> sgl_of_latex s1 ^ "." ^ sgl_of_latex s2
  | UserFunctionCall (name, args) ->
      name ^ "(" ^ String.concat ", " (List.map sgl_of_latex args) ^ ")"
  | LatexFunctionCall (name, args) ->
      name ^ "(" ^ String.concat ", " (List.map sgl_of_latex args) ^ ")"
  | OperatorCall (s, stmt) -> s ^ "(" ^ sgl_of_latex stmt ^ ")"
  | Assign (s1, s2) -> sgl_of_latex s1 ^ " = " ^ sgl_of_latex s2
  | Exp (a, b) -> sgl_of_latex a ^ " ^ " ^ sgl_of_latex b
  | Index (a, i) -> sgl_of_latex a ^ "[" ^ sgl_of_latex i ^ "]"
  | ListComp (o, v, l) ->
      "[" ^ sgl_of_latex o ^ " for " ^ v ^ " = " ^ sgl_of_latex l ^ "]"
  | ListCompFilter (o, c, v, l) ->
      "[" ^ sgl_of_latex o ^ " when " ^ sgl_of_latex c ^ " for " ^ v ^ " = " ^ sgl_of_latex l ^ "]"
  | LetIn (v, a, b) -> "let " ^ v ^ " = " ^ sgl_of_latex a ^ " in " ^ sgl_of_latex b
  | Fn ([Ident p], b) -> "fun " ^ p ^ " -> " ^ sgl_of_latex b
  | Fn (ps, b) ->
      "fun (" ^ String.concat ", " (List.map sgl_of_latex ps) ^ ") -> " ^ sgl_of_latex b
  | OpCall3 (name, subscript, superscript, body) ->
      op_call3_to_sgl name subscript superscript body

and op_call3_to_sgl name subscript superscript body =
  let body_str = sgl_of_latex body in
  match name, split_assign subscript with
  | "sum", Some (var, start) ->
      "summation([" ^ body_str ^ " for " ^ var ^ " = range("
      ^ sgl_of_latex start ^ ", " ^ sgl_of_latex superscript ^ ")])"
  | "prod", Some (var, start) ->
      "product([" ^ body_str ^ " for " ^ var ^ " = range("
      ^ sgl_of_latex start ^ ", " ^ sgl_of_latex superscript ^ ")])"
  | _ -> failwith ("unsupported big operator: " ^ name)

let latex_to_sgl (input : string) : string =
  let result =
    try Ok (Interpreter.parse_input (Interpreter.String input))
    with exn -> Error (Printexc.to_string exn)
  in
  match result with
  | Ok prog ->
      (try String.concat "\n" (List.map sgl_of_latex prog)
       with Failure msg -> "Error: " ^ msg)
  | Error msg -> "Error: " ^ msg

let () =
  Js.export "LatexParser" (object%js
    method latexToSgl input = Js.string (latex_to_sgl (Js.to_string input))
  end)