open Ast

let e_const = 2.71828182846 
let pi_const = 3.14159265359 

let constants = [
    ("e", Real e_const);
    ("pi", Real pi_const);
]

let real_arity1_extern (fn : float -> float) (args : expr list)  =
    let n = List.nth args 0 in 
    match n with
    | Integer i -> Real (fn (float_of_int i))
    | Real r -> Real (fn r)
    | _ -> UndefinedError args

let modulo x y =
  let result = x mod y in
  if result >= 0 then result
  else result + y

let extern_functions = [
    ("sqrt", ExternFn (1, real_arity1_extern sqrt));
    ("sin", ExternFn (1, real_arity1_extern sin));
    ("cos", ExternFn (1, real_arity1_extern cos));
    ("tan", ExternFn (1, real_arity1_extern tan));
    ("csc", ExternFn (1, real_arity1_extern (fun f -> 1. /. sin f)));
    ("sec", ExternFn (1, real_arity1_extern (fun f -> 1. /. cos f)));
    ("cot", ExternFn (1, real_arity1_extern (fun f -> 1. /. tan f)));
    ("sinh", ExternFn (1, real_arity1_extern sinh));
    ("cosh", ExternFn (1, real_arity1_extern cosh));
    ("tanh", ExternFn (1, real_arity1_extern tanh));
    ("arcsin", ExternFn (1, real_arity1_extern asin));
    ("arccos", ExternFn (1, real_arity1_extern acos));
    ("arctan", ExternFn (1, real_arity1_extern atan));
    ("arccsc", ExternFn (1, real_arity1_extern (fun f -> asin (1. /. f))));
    ("arcsec", ExternFn (1, real_arity1_extern (fun f -> acos (1. /. f))));
    ("arccot", ExternFn (1, real_arity1_extern (fun f -> pi_const /. 2. -. atan f)));
    ("ceil", ExternFn (1, real_arity1_extern ceil));
    ("floor", ExternFn (1, real_arity1_extern floor));
    ("mod", ExternFn (2, fun args ->
        let x = List.nth args 0 in
        let y = List.nth args 1 in
        match x, y with
        | Integer x, Integer y -> Integer (modulo x y)
        | _ -> UndefinedError args
    ));
    ("Range", ExternFn (2, fun args ->
        let range_begin = List.nth args 0 in
        let range_end = List.nth args 1 in
        match range_begin, range_end with
        | Integer x, Integer y -> (
            let l = List.init (y - x + 1) (fun i -> Integer (x + i)) in
            ExprList l
        )
        | _ -> UndefinedError args
    ))
]

let env = constants @ extern_functions