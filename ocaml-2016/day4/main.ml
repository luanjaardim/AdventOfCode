let read_line f_chan = try Some (input_line f_chan) with End_of_file -> None;;

let take l n =
  let rec aux acc i = function
    | [] -> List.rev acc
    | h :: hs -> if i = n then List.rev acc else aux (h :: acc) (i+1) hs
  in aux [] 0 l
;;

let format_line f_in =
  let splitted = String.split_on_char '-' (
      match read_line f_in with
      | Some line -> line
      | None -> ""
    ) in
  (* the last element of splitted is : (number)[(letters)] *)
  let rev_splitted = List.rev splitted in
  match List.hd @@ rev_splitted |> String.split_on_char '[' with
      | [checksum; letters] ->
          Some (List.tl rev_splitted |> List.rev |> String.concat "",
                String.to_seq letters |> List.of_seq,
                int_of_string checksum)
      | _ -> None
;;

let process_input text =
  let sort_tupples x y = (* sort tupples to ascending order of repetitions *)
      match x, y with (a, b), (c, d) -> if b = d then begin
        if a < c then -1 else 1
      end
      else if b > d then -1 else 1
  in
  let rec aux = function
    | h :: hs ->
    let count = ref 1 in
        (h, !count) :: ( (* this will remove elements that are equal to h and count how many times h repeats *)
        List.filter (fun x -> if x = h then begin count := !count + 1; false end else true) hs
            |> aux (* continue with the recursion on the text without the h *)
        )
    | [] -> []
  in take (List.sort sort_tupples @@ aux text) 5 (* the five most repeated *)
;;

let rec is_real_room processed_input prev_rep =
  let rec find_in_processed_input elem = function
    | (letter, rep) :: hs -> if letter = elem then rep else find_in_processed_input elem hs
    | _ -> 10000 (* this is not one of the most repeated *)
  in function
  | ']' :: hs -> true
  |  h  :: hs -> (
      let cur_rep = find_in_processed_input h processed_input in
      if cur_rep <= prev_rep then
        is_real_room processed_input cur_rep hs
      else
        false
    )
  | _ -> failwith "unreachable"
;;

let all_real_rooms f_chan_in =
  let rec aux acc =
    match format_line f_chan_in with
        | Some (text, checksum, id) -> (
            if is_real_room (process_input @@ List.of_seq @@ String.to_seq text) 1000 checksum then
                aux ((text, id) :: acc)
            else
                aux acc
        )
        | None -> List.rev acc
  in aux []
;;

let p1 f_chan = List.fold_left (fun x (_, id) -> x + id) 0 @@ all_real_rooms f_chan;;

let p2 f_chan =
  (* check if the room constains the substring north *)
  let is_north_sub s =
    let rec aux i =
        if i + 5 = String.length s then false else if "north" = String.sub s i 5 then true else aux (i+1)
    in aux 0
  in
  (* decoding the room_name using the id *)
  let shift_name room_name id =
    let rec aux = function
      | '-' :: hs -> ' ' :: aux hs
      | h :: hs -> (char_of_int @@ ((int_of_char h) - (int_of_char 'a') + id) mod 26 + int_of_char 'a') :: aux hs
      | [] -> []
    in String.of_seq @@ List.to_seq @@ aux @@ List.of_seq @@ String.to_seq room_name
  in
  let rooms_with_id = all_real_rooms f_chan in
  (* storing every room that has the "north" substring, the result has only one correspondent *)
  let rec aux acc = function
    | (room, id) as t :: hs -> if is_north_sub @@ shift_name room id then
        aux (t :: acc) hs
          else
        aux acc hs
    | [] -> List.rev acc
  in aux [] rooms_with_id
;;

let main p =
  let file_name = "entry.txt" in
  let f_chan_in = open_in file_name in
  p f_chan_in
;;
