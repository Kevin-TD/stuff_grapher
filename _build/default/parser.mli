
(* The type of tokens. *)

type token = 
  | THEN
  | RIGHT_SQR_BRACKET
  | RIGHT_PAREN
  | PLUS
  | NUMBER of (float)
  | NOT_EQUAL
  | NEWLINE
  | MULT
  | MINUS
  | LTE
  | LT
  | LEFT_SQR_BRACKET
  | LEFT_PAREN
  | IF
  | IDENT of (string)
  | GTE
  | GT
  | EXP
  | EQUAL
  | EOF
  | ELSE
  | DIV
  | COMPARE
  | COMMA

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val main: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Ast.prog)
