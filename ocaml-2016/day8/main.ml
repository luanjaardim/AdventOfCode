type inst = Rect of int * int | RotateRow of int * int | RotateCol of int * int

let entry =
  let f_chan_in = open_in "entry.txt" in
  let read_line f = try input_line f with End_of_file -> "" in
  let split_n_read_line f = List.filter (fun x -> String.length x > 0) @@ String.split_on_char ' ' @@ read_line f in
  let rec aux f acc = function
    | "rect" :: s :: [] -> (
        let [rows; cols] = List.map (int_of_string) @@ String.split_on_char 'x' s in
        aux f (Rect (rows, cols) :: acc) @@ split_n_read_line f
      )
    | "rotate" :: "row" :: x :: _ :: y :: [] -> (
        let row = int_of_string @@ String.sub x 2 ((String.length x) - 2) in
        aux f (RotateRow (row, int_of_string y) :: acc) @@ split_n_read_line f
      )
    | "rotate" :: "column" :: x :: _ :: y :: [] -> (
        let col = int_of_string @@ String.sub x 2 ((String.length x) - 2) in
        aux f (RotateCol (col, int_of_string y) :: acc) @@ split_n_read_line f
      )
    | [] -> List.rev acc
    | _ -> failwith "unreachable"
  in aux f_chan_in [] @@ split_n_read_line f_chan_in
;;

let p1 () =
  let lenx = 6  in
  let leny = 50 in
  let s = Array.make_matrix lenx leny '.' in
  let rec loop = function
    | Rect (x, y) :: hs -> (
        (* fill rectangle *)
        for i = 0 to y - 1 do
            for j = 0 to x - 1 do
                s.(i).(j) <- '#'
            done
        done;
        loop hs
      )
    | RotateRow (axis, reps) :: hs -> (
        for rep = 1 to reps do
            let prev_pos = ref s.(axis).(leny-1) in
            for i = 0 to leny - 1 do
                let tmp = !prev_pos in
                prev_pos := s.(axis).(i);
                s.(axis).(i) <- tmp;
            done
        done;
        loop hs
      )
    | RotateCol (axis, reps) :: hs -> (
        for rep = 1 to reps do
            let prev_pos = ref s.(lenx - 1).(axis) in
            for i = 0 to lenx - 1 do
                let tmp = !prev_pos in
                prev_pos := s.(i).(axis);
                s.(i).(axis) <- tmp;
            done
        done;
        loop hs
      )
    | [] -> ()
    in loop entry;
    let count = ref 0 in
    (* iterate over every element of the matrix and counts '#' *)
    Array.iter (Array.iter (fun x -> if x = '#' then count := !count + 1 else ())) s;
    for j = 0 to 5 do
        for i = 0 to 49 do
          if s.(j).(i) = '#' then print_char '#' else print_char ' ';
        done;
      print_char '\n';
    done;
    !count
;;
