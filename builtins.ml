open Ast

let e_const = 2.71828182846
let pi_const = 3.14159265359 

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

let constants = [
    {name = "e"; line = None; value = Real e_const};
    {name = "pi"; line = None; value = Real pi_const};
]

let extern_functions = [
    {name = "sqrt"; line = None; value = ExternFn (1, real_arity1_extern sqrt)};
    {name = "sin"; line = None; value = ExternFn (1, real_arity1_extern sin)};
    {name = "cos"; line = None; value = ExternFn (1, real_arity1_extern cos)};
    {name = "tan"; line = None; value = ExternFn (1, real_arity1_extern tan)};
    {name = "csc"; line = None; value = ExternFn (1, real_arity1_extern (fun f -> 1. /. sin f))};
    {name = "sec"; line = None; value = ExternFn (1, real_arity1_extern (fun f -> 1. /. cos f))};
    {name = "cot"; line = None; value = ExternFn (1, real_arity1_extern (fun f -> 1. /. tan f))};
    {name = "sinh"; line = None; value = ExternFn (1, real_arity1_extern sinh)};
    {name = "cosh"; line = None; value = ExternFn (1, real_arity1_extern cosh)};
    {name = "tanh"; line = None; value = ExternFn (1, real_arity1_extern tanh)};
    {name = "arcsin"; line = None; value = ExternFn (1, real_arity1_extern asin)};
    {name = "arccos"; line = None; value = ExternFn (1, real_arity1_extern acos)};
    {name = "arctan"; line = None; value = ExternFn (1, real_arity1_extern atan)};
    {name = "arccsc"; line = None; value = ExternFn (1, real_arity1_extern (fun f -> asin (1. /. f)))};
    {name = "arcsec"; line = None; value = ExternFn (1, real_arity1_extern (fun f -> acos (1. /. f)))};
    {name = "arccot"; line = None; value = ExternFn (1, real_arity1_extern (fun f -> pi_const /. 2. -. atan f))};
    {name = "ceil"; line = None; value = ExternFn (1, real_arity1_extern ceil)};
    {name = "floor"; line = None; value = ExternFn (1, real_arity1_extern floor)};
    {name = "mod"; line = None; value = ExternFn (2, fun args ->
        let x = List.nth args 0 in
        let y = List.nth args 1 in
        match x, y with
        | Integer x, Integer y -> Integer (modulo x y)
        | _ -> UndefinedError args
    )};
    {name = "range"; line = None; value = ExternFn (2, fun args ->
        let range_begin = List.nth args 0 in
        let range_end = List.nth args 1 in
        match range_begin, range_end with
        | Integer x, Integer y -> (
            let l = List.init (y - x + 1) (fun i -> Integer (x + i)) in
            ExprList l
        )
        | _ -> UndefinedError args
    )};
    {name = "randint"; line = None; value = ExternFn (2, fun args ->
        let min_int_arg = List.nth args 0 in
        let max_int_arg = List.nth args 1 in
        Random.self_init ();
        match min_int_arg, max_int_arg with
        | Integer x, Integer y -> (
            if x > y then
                UndefinedError args
            else
                Integer (Random.int_in_range ~min:x ~max:y)
        )
        | _ -> UndefinedError args
    )};
    {name = "rand"; line = None; value = ExternFn (2, fun args ->
        let min_int_arg = List.nth args 0 in
        let max_int_arg = List.nth args 1 in
        Random.self_init ();
        let rand_range x y = 
            if x > y then
                UndefinedError args
            else
                Real (x +. (y -. x) *. Random.float 1.) 
        in
        match min_int_arg, max_int_arg with
        | Integer x, Integer y -> (
            let x = float_of_int x in
            let y = float_of_int y in
            rand_range x y
        )
        | Integer x, Real y -> (
            let x = float_of_int x in
            rand_range x y
        )
        | Real x, Integer y -> (
            let y = float_of_int y in
            rand_range x y
        )
        | Real x, Real y -> (
            rand_range x y
        )
        | _ -> UndefinedError args
    )};
]

let env = constants @ extern_functions
let taken_names = List.map (fun v -> v.name) env
let name_is_taken s = 
    List.exists (fun x -> x = s) taken_names