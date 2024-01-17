let read_line f_chan_in =
  let line = try input_line f_chan_in with End_of_file -> "" in
  List.of_seq @@ String.to_seq @@ line
;;

let check_valid_IP l =
  let rec aux is_valid in_sq_bracket = function
  | a :: (( b :: c :: d :: _ ) as hs) -> (
      let l = [a; b; c; d] in
      if List.mem '[' l then aux is_valid true hs else
      if List.mem ']' l then aux is_valid false hs else
      if a = d && b = c && a <> b then begin
        (* if found inside [] then quit with false *)
        if in_sq_bracket then false else aux true in_sq_bracket hs
      end else
      aux is_valid in_sq_bracket hs
    )
  | _ -> is_valid in
  aux false false l
;;

let check_valid_SSL l =
  (* two accumulators to store every substring that has the format xyx *)
  (* putting it in one of the accumulators by checking if it is inside square brackets or not *)
  let rec aux acc_aba acc_bab in_sq_bracket = function
    | a :: ((b :: c :: _) as hs) -> (
        let l = [a; b; c] in
        if List.mem '[' l then aux acc_aba acc_bab true hs else
        if List.mem ']' l then aux acc_aba acc_bab false hs else
        if a = c && a <> b then begin
          if in_sq_bracket then
            if List.mem [b; a; b] acc_aba then
              true
            else
              aux acc_aba (l :: acc_bab) in_sq_bracket hs
          else
            if List.mem [b; a; b] acc_bab then
              true
            else
              aux (l :: acc_aba) acc_bab in_sq_bracket hs
        end else
          aux acc_aba acc_bab in_sq_bracket hs
      )
    | _ -> false
  in
  aux [] [] false l
;;

let p is_valid =
  let file_channel_in = open_in "entry.txt" in
  let rec loop acc f_chan = function
    | [] -> acc
    | l ->
        let next_line = read_line f_chan in
        if is_valid l then loop (acc + 1) f_chan next_line  else loop acc f_chan next_line
  in
  loop 0 file_channel_in @@ read_line file_channel_in
;;

let p1 = p check_valid_IP;;
let p2 = p check_valid_SSL;;
