{
open Parser
}

rule token = parse
  | [' ' '\t']        { token lexbuf }
  | '#' [^ '\n']*  { token lexbuf }
  | '\n'              { NEWLINE }
  | '='               { EQUAL }
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
  | "==" { COMPARE }
  | "!=" { NOT_EQUAL }
  | '<' { LT }
  | "<=" { LTE }
  | '>' { GT }
  | ">=" { GTE }
  | "if" { IF }
  | "then" { THEN }
  | "else" { ELSE }
  | "fun" { FUN }
  | "->" { ARROW }
  | ['+' '-']? ['0'-'9']* as i
    { INTEGER (int_of_string i) }
  | ['+' '-']? ['0'-'9']* '.'? ['0'-'9']+ as r
    { REAL (float_of_string r)}
  | ['A'-'Z' 'a'-'z'] ['A'-'Z' 'a'-'z' '0'-'9']* as id
   { IDENT id }
  | eof               { EOF }
  | _                 { failwith "unexpected char" }