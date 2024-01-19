let entry = open_in "entry.txt" |> input_line |> String.trim |> String.to_seq |> List.of_seq ;;

(* readtill and readn return the list to continue the reading, as the second element of a tupple *)
let readTill c l =
  let rec aux acc = function
    | h :: hs -> (
        if h = c then (List.rev acc, hs)
        else aux (h:: acc) hs
      )
    | [] -> (List.rev acc, [])
  in aux [] l
;;

let readNChars n l =
  let rec aux acc n = function
    | (h :: hs) as remaining -> (
      if n = 0 then (List.rev acc, remaining)
      else aux (h :: acc) (n - 1) hs
     )
    | [] -> (List.rev acc, [])
  in aux [] n l
;;

let listToString l =
  List.to_seq l |> String.of_seq

(* pass 1 as argument for the first solution and 2 for the second solution *)
let p p1_or_p2 =
  let rec loop acc = function
    | (h  :: hs) as l -> (
        (* ls is always what's left of the entry to be read *)
          let beforeOpenParen, ls = readTill '(' l in
          let beforeX, ls = readTill 'x' ls in
          if beforeX = [] then
            acc + List.length beforeOpenParen (* beforeOppenParen read all the entry *)
          else begin
            let beforeCloseParen, ls = readTill ')' ls in
            let nChars, ls = readNChars (listToString beforeX |> int_of_string) ls in
            let nCharsSize = if p1_or_p2 = 1 then List.length nChars else loop 0 nChars in
            let fullSliceSize = List.length beforeOpenParen + ((listToString beforeCloseParen |> int_of_string) * nCharsSize) in
            loop (acc + fullSliceSize) ls
          end
        )
    | [] -> acc
  in loop 0 entry
;;
