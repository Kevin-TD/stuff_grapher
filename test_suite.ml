open Interpreter
open Ast

let is_unresolved = function
    | Unresolved _ -> true
    | _ -> false

let is_resolved e = not (is_unresolved e)

(** var [v : string] in an environemnt must satsify some specification [s : expr -> bool]. [if_err : string] is emitted if it is not satisfied, so   
[env_to_satisfy : (v * if_err * s) list] *)
type test_example = {
    name: string;
    env_to_satisfy: (string * string * (expr -> bool)) list
}

(** checks if real nums [r] and [v] are equal by seeing if their difference [ |r - v| ] is no more than [ 10e-3 ]  *)
let real_eq (r : float) (v : float) =
    let epsilon = 10e-3 in
    let diff = r -. v in
    -1. *. epsilon <= diff && diff <= epsilon

let add_test : test_example = {
    name = "add";
    env_to_satisfy = [
        ("x", "x not equal to int 1", fun e -> e = Integer 1);
        ("y", "y not equal to int 5", fun e -> e = Integer 5);
        ("z", "z not equal to int 6", fun e -> e = Integer 6);
    ]
}

let swap_order_test : test_example = {
    name = "swap_order";
    env_to_satisfy = [
        ("w1", "w1 not (roughly) equal to real num 9.209", fun e -> match e with
        | Real r -> real_eq r 9.209
        | _ -> false);
        ("w", "w != Int 7", fun e -> e = Integer 7);
        ("z", "z != Int 4", fun e -> e = Integer 4);
        ("y", "y != Int 3", fun e -> e = Integer 3);
        ("x", "x != Int 1", fun e -> e = Integer 1);
        ("h", "h != Int 1", fun e -> e = Integer 1);
    ]
}

let fun_call_test : test_example = {
    name = "fun_call";
    env_to_satisfy = [
        ("j1", "j1 != Int 11", fun e -> e = Integer 11);
        ("j2", "j2 != Int 47", fun e -> e = Integer 47)
    ]
}

let bools_and_conds_test : test_example = {
    name = "bools_and_conds";
    env_to_satisfy = [
        ("z3", "z3 != False", fun e -> e = False);
        ("z2", "z2 != True", fun e -> e = True);
        ("x", "x != True", fun e -> e = True);
        ("y", "y != Int 1", fun e -> e = Integer 1);
        ("z1", "z1 != True", fun e -> e = True);
        ("e2", "e2 != Int 1", fun e -> e = Integer 1);
        ("h", "h != False", fun e -> e = False);
        ("i1", "i1 != Int 6", fun e -> e = Integer 6);
        ("i2", "i2 != Int 5", fun e -> e = Integer 5);
        ("k1", "k1 != Int 2", fun e -> e = Integer 2);
        ("k2", "k2 != Int 3", fun e -> e = Integer 3);
        ("k3", "k3 != Int 4", fun e -> e = Integer 4);
        ("k4", "k4 != Int 5", fun e -> e = Integer 5)
    ]
}

let list_and_indexing_test : test_example = {
    name = "list_and_indexing";
    env_to_satisfy = [
        ("a", "a != [5, 6, 3]", 
            fun e -> e = ExprList ([Integer 5; Integer 6; Integer 3]);
        );
        ("b1", "b1 != 5", fun e -> e = Integer 5);
        ("b2", "b2 != 6", fun e -> e = Integer 6);
        ("b3", "b3 != 3", fun e -> e = Integer 3);
        ("b4", "b4 != 6", fun e -> e = Integer 6)
    ]
}

let factorial_test : test_example = {
    name = "factorial";
    env_to_satisfy = [
        ("x", "x != Int 120", fun e -> e = Integer 120)
    ]
}

let fun_param_test : test_example = {
    name = "fun_param";
    env_to_satisfy = [
        ("r", "r != Int 5", fun e -> e = Integer 5)
    ]
}

let anon_funcs_test : test_example = {
    name = "anon_funcs";
    env_to_satisfy = [
        ("x1", "x1 != Int 8", fun e -> e = Integer 8);
        ("b1", "b1 != Int 3", fun e -> e = Integer 3);
        ("k1", "k1 != Int 3", fun e -> e = Integer 3);
        ("kk1", "kk1 != Int 2", fun e -> e = Integer 2)
    ]
}

let partial_app_test : test_example = {
    name = "partial_app";
    env_to_satisfy = [
        ("h1", "h1 != -9.4", fun e -> match e with
        | Real r -> real_eq r (-9.4)
        | _ -> false)
    ]
}

let neg_swap_test : test_example = {
    name = "neg_swap";
    env_to_satisfy = [
        ("h", "h != -5", fun e -> e = Integer (-5))
    ]
}

let do_test (t : test_example) =
    let (_, result_env) = parse_file (Config.env_test_dirname ^ t.name ^ Config.file_ext) Config.emit_test_eval_output in
    List.iter 
    (fun (x, if_err, cond_to_satsify) -> match lookup x result_env with
        | Some result_expr -> 
            if cond_to_satsify result_expr then ()
            else print_endline 
            ("FAIL: test " ^ t.name ^ ". var " ^ x ^ " received value " ^ string_of_expr result_expr ^ ", but unsatisfied due to: " ^ if_err)
        | None -> print_endline ("FAIL: test " ^ t.name ^ " failed. " ^ x ^ " not found")
    ) 
    t.env_to_satisfy
    
let run_tests () =
    let tests = [
        add_test;
        swap_order_test;
        fun_call_test;
        bools_and_conds_test;
        list_and_indexing_test;
        factorial_test;
        fun_param_test;
        anon_funcs_test;
        partial_app_test;
        neg_swap_test;
    ] in
    List.iter do_test tests