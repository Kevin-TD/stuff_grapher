
(* The type of tokens. *)

type token = 
  | NUMBER of (float)
  | NEWLINE
  | IDENT of (string)
  | EQUAL
  | EOF

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val main: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Ast.prog)
