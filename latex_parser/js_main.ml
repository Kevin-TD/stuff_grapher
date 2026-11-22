open Js_of_ocaml
open Ast
open Printexc

let rec to_sgl (s : stmt) : string =
  match s with
  | Ident s -> s
  | Number n -> n
  | Plus (s1, s2) -> to_sgl s1 ^ " + " ^ to_sgl s2
  | Minus (s1, s2) -> to_sgl s1 ^ " - " ^ to_sgl s2
  | Mul (s1, s2) -> to_sgl s1 ^ " * " ^ to_sgl s2
  | Lt (s1, s2) -> to_sgl s1 ^ " < " ^ to_sgl s2
  | Gt (s1, s2) -> to_sgl s1 ^ " > " ^ to_sgl s2
  | Lte (s1, s2) -> to_sgl s1 ^ " <= " ^ to_sgl s2
  | Gte (s1, s2) -> to_sgl s1 ^ " >= " ^ to_sgl s2
  | Ne (s1, s2) -> to_sgl s1 ^ " != " ^ to_sgl s2
  | If_else (cond, then_branch, else_branch) ->
      "if " ^ to_sgl cond ^ " then " ^ to_sgl then_branch ^ " else " ^ to_sgl else_branch
  | List (ss) -> "[" ^ String.concat ", " (List.map to_sgl ss) ^ "]"
  | NTuple (ss) -> "(" ^ String.concat ", " (List.map to_sgl ss) ^ ")"
  | AccessAttr (s1, s2) -> to_sgl s1 ^ "." ^ to_sgl s2
  | UserFunctionCall (name, args) ->
      name ^ "(" ^ String.concat ", " (List.map to_sgl args) ^ ")"
  | LatexFunctionCall (name, args) ->
      name ^ "(" ^ String.concat ", " (List.map to_sgl args) ^ ")"
  | OperatorCall (s, stmt) -> s ^ "(" ^ to_sgl stmt ^ ")"
  | Assign (s1, s2) ->
      (match s1 with
       | Ident x -> x ^ " = " ^ to_sgl s2
       | UserFunctionCall (name, args) ->
           name ^ "(" ^ String.concat ", " (List.map to_sgl args) ^ ") = " ^ to_sgl s2
       | _ -> to_sgl s1 ^ " = " ^ to_sgl s2)
  | OpCall3 (name, subscript, superscript, body) -> op_call3_to_sgl name subscript superscript body

and op_call3_to_sgl name subscript superscript body =
  let subscript_str = to_sgl subscript in
  let superscript_str = to_sgl superscript in
  let body_str = to_sgl body in
  (match name, subscript with
   | "sum", Assign (Ident var, Number start) ->
       (match superscript with
        | Number end_ ->
            "summation([" ^ body_str ^ " for " ^ var ^ " = range(" ^ start ^ ", " ^ end_ ^ ")])"
        | _ ->
            "summation([" ^ body_str ^ " for " ^ var ^ " = range(" ^ start ^ ", " ^ superscript_str ^ ")])")
   | "sum", _ ->
       "summation([" ^ body_str ^ " for _ = range(1, " ^ superscript_str ^ ")])"
   | _ -> name ^ "_{" ^ subscript_str ^ "}^{" ^ superscript_str ^ "}")

let latex_to_sgl (input : string) : string =
  let result =
    try
      Ok (Interpreter.parse_input (Interpreter.String input))
    with exn -> Error (to_string exn)
  in
  match result with
  | Ok prog -> String.concat "\n" (List.map to_sgl prog)
  | Error msg -> "Error: " ^ msg

let () =
  Js.export "LatexParser" (object%js
    method latexToSgl input = Js.string (latex_to_sgl (Js.to_string input))
  end)
