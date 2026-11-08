{
open Parser
}

rule token = parse
  | [' ' '\t'] { token lexbuf }
  | '#' [^ '\n']* '\n'  { Lexing.new_line lexbuf; token lexbuf }
  | '#' [^ '\n']* eof   { token lexbuf }
  | '\n' { Lexing.new_line lexbuf; NEWLINE }
  | '=' { EQUAL }
  | '+' { PLUS }
  | '-' { MINUS }
  | '*' { MULT }
  | '/' { DIV }
  | '^' { EXP }
  | '[' { LEFT_SQR_BRACKET }
  | ']' { RIGHT_SQR_BRACKET }
  | '(' { LEFT_PAREN }
  | ')' { RIGHT_PAREN }
  | ',' { COMMA }
  | ':' { COLON }
  | "!=" { NOT_EQUAL }
  | '<' { LT }
  | "<=" { LTE }
  | '>' { GT }
  | ">=" { GTE }
  | "if" { IF }
  | "then" { THEN }
  | "else" { ELSE }
  | "fun" { FUN }
  | "when" { WHEN }
  | "for" { FOR }
  | "let" { LET }
  | "in" { IN }
  | "->" { ARROW }
  | ['0'-'9']+ as r (* i am lazy *)
    { REAL (float_of_string r) }
  | ['0'-'9']+ '.'? ['0'-'9']+ as r
    { REAL (float_of_string r)}
  | ['A'-'Z' 'a'-'z'] ['A'-'Z' 'a'-'z' '0'-'9' '_']* as id
   { IDENT id }
  | "." { ACCESS_DOT }
  | eof { EOF }
  | _ { failwith (Printf.sprintf "unexpected char at line %d"
        lexbuf.Lexing.lex_curr_p.Lexing.pos_lnum) }