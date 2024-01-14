let toString l = String.of_seq @@ List.to_seq l;;
let toListChar s = List.of_seq @@ String.to_seq s;;

(* returns a list of chars list, *)
(* each one with the first char being the direction the other the number to walk *)
let entry = open_in "entry.txt"
            |> input_line
            |> String.split_on_char ','
            |> List.map (fun x -> toListChar @@ String.trim x);; (* tail to remove the space, the first one did not had this *)

type dir = N | S | E | O;;
type move = Left of int | Right of int;;
let rec movements acc = function
  | ('R' :: num) :: ls ->  movements (Right (int_of_string @@ toString num) :: acc) ls
  | ('L' :: num) :: ls ->  movements (Left (int_of_string @@ toString num) :: acc) ls
  | _ -> List.rev acc;;

(* change the direction pointing to and the current position *)
(* as we are mutating references this function returns the unit *)
let changeDir turnTo x y frontDirection =
  match turnTo with
  | Left toWalk -> (match !frontDirection with
    | N -> x := !x - toWalk; frontDirection := O
    | S -> x := !x + toWalk; frontDirection := E
    | O -> y := !y - toWalk; frontDirection := S
    | E -> y := !y + toWalk; frontDirection := N
    )
  | Right toWalk -> match !frontDirection with
    | N -> x := !x + toWalk; frontDirection := E
    | S -> x := !x - toWalk; frontDirection := O
    | O -> y := !y + toWalk; frontDirection := N
    | E -> y := !y - toWalk; frontDirection := S
;;

let moves = movements [] entry;;
let p1 =
  let tmpx = ref 0 in
  let tmpy = ref 0 in
  let frontDir = ref N in
  (* as changeDir returns the unit we can iterate every element of moves with List.iter *)
  List.iter (fun x -> changeDir x tmpx tmpy frontDir) moves; (abs !tmpx) + (abs !tmpy);;

(* part 2 *)
(* a line is a tuple of 4 ints, the first two are the origin and the last two the end *)
(* in this problem the lines are only horizontal and vertical *)
type line_type = Vertical | Horizontal | Diagonal;;

(* a point is visited twice if the current line to walk intersec with *)
(* any of the previous lines, if not, we add the new line to the path already done *)
let findIntersec moves_list =
  let x = ref 0 in
  let y = ref 0 in
  let frontDir = ref N in
  (* update the variables of position(x and y) and the direction that *)
  (* the next move will be made *)
  let newLine move =
    let curX = !x in
    let curY = !y in
    changeDir move x y frontDir ; (curX, curY, !x, !y) in
  let lineType = function (x1, y1, x2, y2) -> if x1 = x2 then Vertical else if y1 = y2 then Horizontal else Diagonal in
  (* check if the two lines intersec, if they do, return the distance *)
  (* from the origin to the intersec point *)
  let checkIntersec line1 line2 =
    match line1, line2 with
    | (x1, y1, x2, y2), (x3, y3, x4, y4) ->
      (* f for first, l fort last, x for horizontal, y for vertical, 1 for line1, 2 for line2 *)
      (* an example: lx1 = last x for line 1, the greater value of x1 and x2 *)
      let (fx1, lx1, fy1, ly1, fx2, lx2, fy2, ly2) =
        (min x1 x2, max x1 x2, min y1 y2, max y1 y2, min x3 x4, max x3 x4, min y3 y4, max y3 y4) in
      match lineType line1, lineType line2 with
      | Vertical, Horizontal -> (
          if fx2 <= x1 && lx2 >= x1 && fy1 <= y3 && ly1 >= y3 then
            Some ((abs y3) + (abs x1))
          else None
        )
      | Horizontal, Vertical -> (
          if fy2 <= y1 && ly2 >= y1 && fx1 <= x3 && lx1 >= x3 then
            Some ((abs x3) + (abs y1))
          else None
        )
      | Vertical, Vertical -> (
          if x1 = x3 && max fy1 fy2 <= min ly1 ly2 then
            Some ((abs x3) + (abs (if ly1 <= y3 && fy1 >= y3 then y3 else begin
                if y3 - y1 < y3 - y2 then y1 else y2
            end)))
          else None
        )
      | Horizontal, Horizontal -> (
          if y1 = y3 && max fx1 fx2 <= min lx1 lx2 then
            Some ((abs y3) + (abs (if lx1 <= x3 && fx1 >= x3 then x3 else begin
                if x3 - x1 < x3 - x2 then x1 else x2
            end)))
          else None
        )
      | _, _ -> failwith "diagonal lines are not considered" in

  let rec aux acc =

    (* walks inside the current acc to see if there is a point visited twice *)
    let rec inner_loop line = function
      | h_acc :: (h2_acc :: _ as hs_acc) -> (
          match checkIntersec h_acc line with
        | None -> inner_loop line hs_acc
        | x -> x (* returned a Some *)
      )
      | _ -> None
    in
    function
    | h :: hs -> (
        let new_line = newLine h in
        match inner_loop new_line acc with
        | None -> aux (acc @ [new_line]) hs
        | x -> x (* found the result *)
      )
    | [] -> None (* did not found the result *)
  in aux [] moves_list;;

let p2 = match findIntersec moves with Some x -> print_int x; print_newline (); x
                                     | None -> failwith "there is not a point visited twice";;
