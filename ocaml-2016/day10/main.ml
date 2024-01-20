(* parents is a list of tuples that holds a min or max function and a index *)
(* to a possible father that it can take one of it's inputs *)
type parents = ((int -> int -> int) * int) list;;

type robot = {
  (* a list with a maximum of two elements *)
  input : int list;
  from : parents;
};;

type output = {
  (* the value after been calculated *)
  out : int;
  (* from what robot it's going to get it's value *)
  from : parents;
}

let default_robot = {
  input = [];
  from = [];
};;

let default_output = {
  out = -1;
  from = [];
};;

(* this will turn the input into an array that has all the known inputs of each chip *)
(* and from where we can take them, an input that comes as output of another robot *)
let entry_rob, entry_out =
    let robots = Array.make 210 default_robot in
    let output = Array.make 21 default_output in
    let f_chan_in = open_in "entry.txt" in
    let read_line f =
      try input_line f |> String.trim |> String.split_on_char ' '
      with End_of_file -> [] in
    let rec loop f = function
      | "bot" :: parent :: "gives" :: "low" :: "to" :: low_dest
        :: low_child :: "and" :: "high" :: "to" :: high_dest :: high_child :: [] ->
        (
          let parent_id = int_of_string parent in
          let low_child_id = int_of_string low_child in
          let high_child_id = int_of_string high_child in
          if low_dest = "bot" then
            robots.(low_child_id) <- { from = (min, parent_id) :: robots.(low_child_id).from;
                                       input = robots.(low_child_id).input }
          else
            output.(low_child_id) <- { from = (min, parent_id) :: output.(low_child_id).from;
                                       out = output.(low_child_id).out };

          if high_dest = "bot" then
            robots.(high_child_id) <- { from  = (max, parent_id) :: robots.(high_child_id).from;
                                        input = robots.(high_child_id).input }
          else
            output.(high_child_id) <- { from = (max, parent_id) :: output.(high_child_id).from;
                                        out = output.(high_child_id).out };

          loop f @@ read_line f
        )
      | "value" :: in_value :: "goes" :: "to" :: "bot" :: id :: [] ->
        (
          let id = int_of_string id in
          robots.(id) <- { input = (int_of_string in_value) :: robots.(id).input;
                                  from = robots.(id).from };
          loop f @@ read_line f
        )
      | [] -> ()
      | t -> List.iter print_endline t
    in
    loop f_chan_in @@ read_line f_chan_in;
    (robots, output)
;;

(* if both input are known, we can calculate the output with the function *)
(* else we will search from the needed input comes and solve it first *)
let rec get_robot_value f id =
  if List.length entry_rob.(id).input = 2 then
    match entry_rob.(id).input with [x; y] -> f x y | _ -> failwith "error"
  else
    let new_input = match entry_rob.(id).from with
      | [(f1, p1); (f2, p2)] -> [get_robot_value f1 p1; get_robot_value f2 p2]
      | [(f1, p1)] -> (get_robot_value f1 p1) :: entry_rob.(id).input
      | _ -> failwith "error"
    in
    entry_rob.(id) <- { input = new_input; from = [] };
    get_robot_value f id
;;

(* the output calculation works the same way, it will search from where it's value comes *)
let get_output_value id =
  if entry_out.(id).out = -1 then
    match entry_out.(id).from with
    | [(f, p)] -> (
        let value = get_robot_value f p in
        entry_out.(id) <- {out = value; from = []};
        entry_out.(id).out
      )
    | _ -> failwith "error"
  else
    entry_out.(id).out
;;

let p1 () =
  (* walking through all chips to find the one that has the 11 and 61 input values *)
  for i = 0 to 209 do
    print_endline @@ string_of_int @@ i;
    if get_robot_value min i = 17 && get_robot_value max i = 61 then
      print_endline @@ string_of_int i ^ " is the robot that compares 17 and 61"
  done
;;

(* multiply output 0, 1 and 2 values *)
let p2 () =
  let a = get_output_value 0 in
  let b = get_output_value 1 in
  let c = get_output_value 2 in
  print_endline @@ string_of_int @@ a * b * c
;;
