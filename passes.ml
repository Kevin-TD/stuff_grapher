open Ast

(** runs analyses/passes to enforce rules *)

type test_status =
    | Pass
    | Fail

type pass_test = {
    name: string;
    env_check: environment -> (test_status * string)
}

let no_var_redef_test : pass_test = {
    name = "no_var_redef_test";
    env_check = fun env -> (
        let result = ref Pass in
        let if_error = ref [] in
        let var_counts : ((string * int ref) list) ref = ref [] in
        List.iter 
        (fun (var_name, _) ->
            match List.find_opt (fun (v, _) -> v = var_name) !var_counts with
            | Some (_, c) -> c := !c + 1
            | None -> var_counts := (var_name, ref 1) :: !var_counts 
        ) env;
        List.iter 
        (fun (var_name, count) ->
            if !count > 1 then (
                if_error := (var_name ^ " defined in " ^ string_of_int (!count) ^ " places") :: !if_error;
                result := Fail;
            )
        ) !var_counts;
        let final_err_output = String.concat "\n" !if_error in
        (!result, final_err_output)
    )
}

let no_unresolved_test : pass_test = {
    name = "no_unresolved_test";
    env_check = fun env -> (
        let unresolved_vars = ref [] in
        let if_error = ref [] in
        List.iter
        (fun (x, e) -> match e with
        | Unresolved _ -> unresolved_vars := x :: !unresolved_vars
        | _ -> ())
        env;
        List.iter
        (fun x -> 
            if_error := (x ^ " is Unresolved") :: !if_error
        )
        !unresolved_vars;
        let final_err_output = String.concat "\n" !if_error in
        if List.length (!unresolved_vars) > 0 then 
            (Fail, final_err_output) 
        else
            (Pass, final_err_output)
    )
}

let run_pass_test (env : environment) (t : pass_test) =
    let (status, if_error) = t.env_check env in
    if status = Fail then
        print_endline ("Pass " ^ t.name ^ " FAILED.\nError Output: " ^ if_error)

let run_passes (env : environment) =
    let tests = [
        no_var_redef_test;
        no_unresolved_test;
    ] in
    List.iter (run_pass_test env) tests