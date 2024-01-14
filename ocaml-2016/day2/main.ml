let read_line file =
  try
    Some (input_line file |> String.to_seq |> List.of_seq)
  with
    End_of_file -> close_in file; None;;

let p1 () =
  let file = open_in "entry.txt" in
  let x = ref 1 in
  let y = ref 1 in
  let rec process = function
    | h :: (_ as hs) -> 
        (match h with
            | 'U' -> y := max (!y - 1) 0
            | 'D' -> y := min (!y + 1) 2
            | 'L' -> x := max (!x - 1) 0
            | 'R' -> x := min (!x + 1) 2
            | _ -> failwith "unreachable");
        process hs
    | [] -> (!x, !y)
  in
  let rec loop acc = function
    | Some line -> loop (process line :: acc) @@ read_line file
    | None -> List.rev acc
  in
  let out = loop [] @@ read_line file in
  let convertPair = function (x, y) -> y*3 + x + 1 in
  List.map convertPair out;;

let p2 () =
  (* making a matrix with the padding values, any # is an area that cannot be visited *)
  let m = Array.make_matrix 7 7 '#' in
    m.(1).(3) <- '1';
    m.(2).(2) <- '2';
    m.(2).(3) <- '3';
    m.(2).(4) <- '4';
    m.(3).(1) <- '5';
    m.(3).(2) <- '6';
    m.(3).(3) <- '7';
    m.(3).(4) <- '8';
    m.(3).(5) <- '9';
    m.(4).(2) <- 'A';
    m.(4).(3) <- 'B';
    m.(4).(4) <- 'C';
    m.(5).(3) <- 'D';
    (* Array.iter (fun x -> print_endline @@ String.of_seq @@ Array.to_seq x) m *)
  let file = open_in "entry.txt" in
  let x = ref 1 in
  let y = ref 3 in
  let rec process = function
    | h :: (_ as hs) ->
        (match h with
            (* if found a #, just ignore the command *)
            | 'U' -> if m.(!y - 1).(!x) == '#' then () else y := !y - 1
            | 'D' -> if m.(!y + 1).(!x) == '#' then () else y := !y + 1
            | 'L' -> if m.(!y).(!x - 1) == '#' then () else x := !x - 1
            | 'R' -> if m.(!y).(!x + 1) == '#' then () else x := !x + 1
            | _ -> failwith "unreachable");
        process hs
    | [] -> m.(!y).(!x) (* return the element at the position *)
  in
  let rec loop acc = function
    | Some line -> loop (process line :: acc) @@ read_line file
    | None -> List.rev acc
  in loop [] @@ read_line file
;;
