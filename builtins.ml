open Ast

let constants = [
    ("e", Real (2.71828182846));
    ("pi", Real (3.14159265359));
]

let extern_functions = [
    ("sqrt", ExternFn (1, 
    fun args -> 
        let n = List.nth args 0 in 
        match n with
        | Integer i -> Real (sqrt (float_of_int i))
        | Real r -> Real (sqrt r)
        | _ -> UndefinedError [n]
    ));
    ("sin", ExternFn (1,
    fun args ->
        let n = List.nth args 0 in
        match n with
        | Integer i -> Real (sin (float_of_int i))
        | Real r -> Real (sin r)
        | _ -> UndefinedError [n]
    ));
]

let env = constants @ extern_functions