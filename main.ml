open Printf
open Ast
open Core

let filename = "./test/general_test.d"

(* what i like about desmos is that statements can go in any order
we can have like an initial pass then another pass. *)

type environment = (string * stmt) list

let main =
  let inx = In_channel.create filename in
  let lexbuf = Lexing.from_channel inx in
  let res =
    try Parser.main Lexer.token lexbuf
    with _ -> failwith "parsing error"
  in
   print_prog res