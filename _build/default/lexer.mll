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

  | ['+' '-']? ['0'-'9']* '.'? ['0'-'9']+ as n 
    { NUMBER (float_of_string n)}

  | ['A'-'Z' 'a'-'z'] ['A'-'Z' 'a'-'z' '0'-'9']* as id
   { IDENT id }
  | eof               { EOF }
  | _                 { failwith "unexpected char" }