(* dune build --profile release *)
(* output file _build/default/js_main.bc.js *)

open Js_of_ocaml
open Ast

let string_of_expr_frontend = function
  | Real r -> (
    if r = floor r then
      string_of_int (int_of_float r)
    else
      string_of_float r
  )
  | _ -> ""
  
let parse_string_input s =
  let (_, env) = Interpreter.parse_input (String s) false in
  let filter_env = List.filter (fun v -> v.line <> None) env in
  let obj = Js.Unsafe.obj [||] in
  List.iter (fun v ->
    match v.line with
    | Some i ->
      Js.Unsafe.set obj (string_of_int i) (Js.string (string_of_expr_frontend v.value))
    | None -> ()
  ) filter_env;
  obj

let get_new_var_names s =
  let (_, env) = Interpreter.parse_input (String s) false in
  let filter_env = List.filter 
  (fun v -> 
    not (String.starts_with ~prefix:Sgl_consts.wildcard_var_symbol v.name) && 
    v.line <> None
  ) 
  env in
  let names = List.map (fun v -> v.name) filter_env in
  Js.array (Array.of_list (List.map Js.string names))


let auto_operator_names = [
  "if"; "then"; "else"; "fun"; "when"; "for"
]

let exclude_names = ["e"; "pi"; "sqrt"]

(** list of names that do not get italicized and are emboldened--treated as functions *)
let names_to_embolden = 
  auto_operator_names @ Builtins.taken_names |>
  List.filter (fun x -> not (List.exists (fun y -> y = x) exclude_names)) |>
  String.concat " "

let () =
  Js.export "SGL" (object%js
    method parseStringInput input =
      parse_string_input (Js.to_string input)
    
    method getNewVarNames input =
      get_new_var_names (Js.to_string input)
    
    method namesToEmbolden = 
      Js.string names_to_embolden
  end)