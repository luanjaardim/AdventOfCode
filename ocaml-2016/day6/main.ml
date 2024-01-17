let entry =
  let f_chan = open_in "entry.txt" in
  let rec aux acc f =
    try
      let line = input_line f |> String.to_seq |> Array.of_seq in
      acc.(0) <- line.(0) :: acc.(0);
      acc.(1) <- line.(1) :: acc.(1);
      acc.(2) <- line.(2) :: acc.(2);
      acc.(3) <- line.(3) :: acc.(3);
      acc.(4) <- line.(4) :: acc.(4);
      acc.(5) <- line.(5) :: acc.(5);
      acc.(6) <- line.(6) :: acc.(6);
      acc.(7) <- line.(7) :: acc.(7);
      aux acc f
    with
      End_of_file -> Array.map (List.rev) acc
  in
  aux [|[]; []; []; []; []; []; []; []|] f_chan
;;

let p func init_val =
  let rec aux cur =
    match cur with (elem , reps) ->
        function
        | h :: hs -> (
            (* counts how many times h appears in the collumn *)
            let sum = List.fold_left (fun acc x -> if x = h then acc + 1 else acc) 1 hs in
            (* removes all the h from the collumn *)
            let filtered_list = List.filter (fun x -> x <> h) hs in
            (* recursion one the filtered_list, checking the remaining elements *)
            if func sum reps then aux (h, sum) filtered_list else aux cur filtered_list
          )
        | [] -> cur
  in
  (* this will return the result for each collumn as an array *)
  Array.map (aux (' ' , init_val)) entry
;;

let p1 () =
  String.of_seq @@ Array.to_seq @@ Array.map (fun (x, y) -> x) @@ p (>) 0
;;

let p2 () =
  String.of_seq @@ Array.to_seq @@ Array.map (fun (x, y) -> x) @@ p (<) 1000
;;
