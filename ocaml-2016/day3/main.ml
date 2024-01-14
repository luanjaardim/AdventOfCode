let format_line l = List.filter (fun x -> 0 < String.length x) (List.map String.trim (String.split_on_char ' ' l));;

(* if the sum of two sides is lower or equal to the remaining side, it cannot be a triangle *)
let is_triangule l =
  match l with
    | [x; y; z] -> if x + y > z then true else false
    | [] -> false
    | _ -> failwith "unreachable"

let p1 read_line_f f_chan count_ref =
  let to_list_of_triple l = List.sort (-) @@ List.map int_of_string (format_line l) in
  let rec aux = function
    | Some line -> (
      if is_triangule @@ to_list_of_triple line then
        count_ref := !count_ref + 1
      else
        ();
      aux @@ read_line_f f_chan
      )
    | None -> !count_ref
  in
  aux @@ read_line_f f_chan
;;

let p2 read_line_f f_chan count_ref =
  (* reading three lines and getting three triangules simultaneously *)
  let read_formated_array_lines chan_in =
    let unwrap_line f =
      format_line @@ match read_line_f f with
          | Some l -> l
          | None -> ""
    in
    let get_line f = List.map int_of_string @@ unwrap_line f in
    let sort = List.sort (-) in
  match get_line chan_in, get_line chan_in, get_line chan_in with
    | [x1; x2; x3], [y1; y2; y3], [z1; z2; z3] ->
      (sort [x1; y1; z1], sort [x2; y2; z2], sort [x3; y3; z3])
    | [], [], [] -> ([], [], [])
    | _ -> failwith "unreachable"
  in
  let rec aux f_chan_in = function
    | ((_ :: _) as t1), ((_ :: _) as t2), ((_ :: _) as t3) -> (
        (* check which one is a triangule *)
        if is_triangule t1 then count_ref := !count_ref + 1 else ();
        if is_triangule t2 then count_ref := !count_ref + 1 else ();
        if is_triangule t3 then count_ref := !count_ref + 1 else ();
        aux f_chan_in @@ read_formated_array_lines f_chan
      )
    | [], [], [] -> !count_ref (* end of the file *)
    | _ -> failwith "unreachable"
  in aux f_chan @@ read_formated_array_lines f_chan
;;

let main p =
  let file_chan = open_in "entry.txt" in
  let read_line f =
    try Some( input_line f ) with End_of_file -> close_in f; None | Sys_error _ -> None
  in
  let count = ref 0 in
  p read_line file_chan count
;;

main p1;;
main p2;;
