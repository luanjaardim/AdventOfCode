let entry = "ojvtpuvg";;

let p1 () =
  let rec aux acc i =
    if List.length acc = 8 then
      acc
    else begin
      (* found the MD5 hash of the entry concatenated with the current i as hexa number *)
      let s = Digest.string (entry ^ (string_of_int i)) |> Digest.to_hex in
      if s.[0] = '0' && s.[1] = '0' && s.[2] = '0' && s.[3] = '0' && s.[4] = '0' then
        aux (acc @ [s.[5]]) (i+1)
      else
        aux acc (i+1)
    end
  in String.of_seq @@ List.to_seq @@ aux [] 0
;;

let p2 () =
  (* store the password to know where is not filled yet *)
  let password = Array.make 8 '#' in
  let rec aux filled_pos i =
    if filled_pos = 8 then
      ()
    else begin
      let s = Digest.string (entry ^ (string_of_int i)) |> Digest.to_hex in
      if s.[0] = '0' && s.[1] = '0' && s.[2] = '0' && s.[3] = '0' && s.[4] = '0' then begin
        let num = (int_of_char s.[5]) - 48 in
        (* if it is a valid position index and it's not filled yet *)
        if num >= 0 && num <= 7 && password.(num) = '#' then begin
            password.(num) <- s.[6];
            aux (filled_pos + 1) (i+1)
        end else
            aux filled_pos (i+1)
      end
      else
        aux filled_pos (i+1)
    end
  in aux 0 0;
  String.of_seq @@ Array.to_seq @@ password
;;
