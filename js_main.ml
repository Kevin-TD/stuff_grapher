(* dune build --profile release *)
(* output file _build/default/js_main.bc.js *)

open Js_of_ocaml
open Ast

let parse_string_input s =
  let (_, env) = Interpreter.parse_input (String s) false in
  let filter_env = List.filter (fun v -> v.line <> None) env in
  let obj = Js.Unsafe.obj [||] in
  List.iter (fun v ->
    match v.line with
    | Some i ->
      Js.Unsafe.set obj (string_of_int i) (Js.string (string_of_expr v.value))
    | None -> ()
  ) filter_env;
  obj

let () =
  Js.export "SGL" (object%js
    method parseStringInput input =
      parse_string_input (Js.to_string input)
  end)