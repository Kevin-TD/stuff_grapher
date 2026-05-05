{
open Parser
}

rule token = parse
  | [' ' '\t']        { token lexbuf }
  | '\n'              { NEWLINE }
  | '='               { EQUAL }
  | ['+' '-']? ['0'-'9']* '.'? ['0'-'9']+ as n 
    { NUMBER (float_of_string n)}

  (* | ['0'-'9']+ '.' ['0'-'9']+ as f
                      { NUMBER (float_of_string f) }
  | ['0'-'9']+ as i   { NUMBER (float_of_string i) } *)
  | ['a'-'z' 'A'-'Z']+ as id
                      { IDENT id }
  | eof               { EOF }
  | _                 { failwith "unexpected char" }