(** runs tests in [test_suite.ml] *)
let run_tests = true

(** prints to console parsing/eval results of all test files *)
let emit_test_eval_output = false

(** prints to console the results of parsing the assign statements and evaluating them *)
let emit_output = true

(** prints explicitly the builtin constants and functions (e.g., constant e and function sqrt) *)
let emit_builtins_in_env = false

(** path to the folder of test files *)
let env_test_dirname = "./test/env/"

(** extension for SGL (Stuff Grapher Language) files that are expected for test files and input files *)
let file_ext = ".sgl"