open Printf
open Ast
open Core

let filename = "./testfile.txt"

let main =
  let inx = In_channel.create filename in
  let lexbuf = Lexing.from_channel inx in
  let res =
    try Parser.main Lexer.token lexbuf
    with _ -> failwith "idc"
  in
   print_prog res