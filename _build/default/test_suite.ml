open Interpreter
open Ast
open Debug_config

(* im lowkey good on testing rn lol *)

type test_example = {
    name: string;
    expected_env: environment
}

let test_dirname = "test/"

let basic_add_test : test_example = {
    name = "basic_add";
    expected_env = [
        ("x", Integer 1);
        ("y", Integer 5);
        ("z", Integer 6)
    ]
}


let do_test (t : test_example) =
    let (_, result_env) = parse_file (test_dirname ^ t.name ^ ".d") false in
    List.iter 
    (fun (x, expected_expr) -> match lookup x result_env with
        | Some result_expr -> 
            if result_expr = expected_expr then ()
            else print_endline 
            ("FAIL: test " ^ t.name ^ " failed: value " ^ x ^ " expected " ^ string_of_expr expected_expr ^ ", recevied " ^ string_of_expr result_expr)
        | None -> print_endline ("FAIL: test " ^ t.name ^ " failed: " ^ x ^ " not found")
    ) 
    t.expected_env

let run_tests () =
    do_test basic_add_test;