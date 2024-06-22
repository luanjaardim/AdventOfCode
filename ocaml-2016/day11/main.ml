type device = Microchip of string | Generator of string

type state = {
  mutable elevator: int;
  mutable devices:
    (device list * device list * device list * device list)
  ;
}

type dir = Up | Down

(*
(empty)
TM
TG RG RM CG CM
SG SM PG PM
*)
let initial_state = {
  elevator = 1;
  devices = (
    [Generator "S"; Microchip "S"; Generator "P"; Microchip "P"],
    [Generator "T"; Generator "R"; Microchip "R"; Generator "C"; Microchip "C"],
    [Microchip "T"],
    [])
}

let get_nth_floor n e =
  match n, e.devices with
  | 1, (f, _, _, _) -> f
  | 2, (_, f, _, _) -> f
  | 3, (_, _, f, _) -> f
  | 4, (_, _, _, f) -> f
  | _, _ -> failwith "Invalid floor"

and set_nth_floor n e f =
  { elevator = e.elevator;
    devices = (
    match n, e.devices with
    | 1, (fir, sec, thd, fou) -> f, sec, thd, fou
    | 2, (fir, sec, thd, fou) -> fir, f, thd, fou
    | 3, (fir, sec, thd, fou) -> fir, sec, f, fou
    | 4, (fir, sec, thd, fou) -> fir, sec, thd, f
    | _, _ -> failwith "Invalid floor"
  ) } 
;;


let p1 state =
  let min_moves = ref max_int in
  let get_possible_carries () =
    let cur_floor = get_nth_floor state.elevator state in
      (*This generates every possible pair from the current floor
        A pair with repeated elements is the same as carry only one device *)
      List.concat (List.map (fun x -> List.map (fun y -> (x, y)) cur_floor) cur_floor)
  in
  let check_floor floor =
    (*Check if the floor is safe*)
    List.for_all (fun x ->
      match x with
      | Generator _ -> true
      | Microchip x -> (
          (*There is a generator for the microchip*)
          List.exists (fun y -> y = Generator x) floor
          (*There is no generator for the microchip and there is generator in the floor*)
       || (not @@ List.exists (function Generator _ -> true | _ -> false) floor)
      )
    ) floor
  in
  let go_to_floor direc (fir_dev, snd_dev) =
    if (state.elevator = 1 && direc = Down) || (state.elevator = 4 && direc = Up) then
      None
    else (
      (*Check if the carring is possible*)

      (*Remove carried elements from the current floor*)
      let cur_floor_without_carried = List.filter (fun x -> x <> fir_dev && x <> snd_dev) @@ get_nth_floor state.elevator state in
      let next_floor_num = state.elevator + (match direc with Up -> 1 | Down -> -1) in
      let next_floor = get_nth_floor next_floor_num state in
      (*Adding removed elements to the next floor*)
      let new_next_floor = next_floor @
          (if fir_dev = snd_dev then [fir_dev] else [fir_dev; snd_dev]) in

      (*Check if the new state is safe*)
      if check_floor cur_floor_without_carried && check_floor new_next_floor then (
        let tmp_state = set_nth_floor state.elevator state cur_floor_without_carried in
        let new_state = set_nth_floor next_floor_num tmp_state new_next_floor in
        Some new_state
      ) else None
    )
  in
  let rec find_config e prev_e combs =
    ()
  in
  find_config state 
and p2 () =
  Printf.printf "Hello world from 2\n"
;;
p1 initial_state;
p2 ()
