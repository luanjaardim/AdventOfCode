use std::{collections::HashMap, default, error::Error};
use num_enum::FromPrimitive;

use Position::*;
#[derive(Debug, Clone, Copy, FromPrimitive)]
#[repr(u8)]
enum Position {
    #[default]
    A,
    N0, N1, N2, N3, N4, N5, N6, N7, N8, N9,
    DL, DR, DD, DU
}
use Dir::*;
#[derive(Debug, PartialEq, Eq)]
enum Dir {
    Left, Right, Down, Up
}

//      +---+---+---+
//      | 7 | 8 | 9 |
//      +---+---+---+
//      | 4 | 5 | 6 |
//      +---+---+---+
//      | 1 | 2 | 3 |
//      +---+---+---+
//          | 0 | A |
//          +---+---+
struct NumKeypad {
    cur: Position,
}
impl KeypadMove for NumKeypad {
    fn get_cur_position(&self) -> Position { self.cur }
    fn set_cur_position(&mut self, p: Position) { self.cur = p; }
    fn is_dir_keypad(&self) -> bool { false }
    fn get_real_position(&self, p: Position) -> (i8, i8) {
        match p {
            A => (0, 0), N0 => (-1, 0), N1 => (-2, 1), N2 => (-1, 1), N3 => (0, 1),
            N4 => (-2, 2), N5 => (-1, 2), N6 => (0, 2), N7 => (-2, 3), N8 => (-1, 3), N9 => (0, 3),
            _ => unreachable!("go to the hell bro"),
        }
    }
}

//          +---+---+
//          | ^ | A |
//      +---+---+---+
//      | < | v | > |
//      +---+---+---+
struct DirKeypad {
    cur: Position,
}
impl KeypadMove for DirKeypad {
    fn get_cur_position(&self) -> Position { self.cur }
    fn set_cur_position(&mut self, p: Position) { self.cur = p; }
    fn is_dir_keypad(&self) -> bool { true }
    fn get_real_position(&self, p: Position) -> (i8, i8) {
        match p {
            A => (0, 0), DU => (-1, 0), DD => (-1, -1), DR => (0, -1), DL => (-2, -1), _ => unreachable!(),
        }
    }
}

trait KeypadMove {
    fn get_cur_position(&self) -> Position;
    fn set_cur_position(&mut self, p: Position);
    fn get_real_position(&self, p: Position) -> (i8, i8);
    fn is_dir_keypad(&self) -> bool;
    fn go_to_from(&self, beg: (i8, i8), end: (i8, i8)) -> ((Dir, u8), (Dir, u8)) {
        (if beg.0 < end.0 {
            (Right, (end.0-beg.0).abs() as u8)
        } else {
            (Left, (end.0-beg.0).abs() as u8)
        },
        if beg.1 < end.1 {
            (Up, (end.1-beg.1).abs() as u8)
        } else {
            (Down, (end.1-beg.1).abs() as u8)
        })
    }
}

fn get_char_representation(p: Position) -> char {
    match p {
        A => 'A',
        DD => 'v', DU => '^', DL => '<', DR => '>',
        _ => (b'0' - 1 + p as u8) as char,
    }
}

fn move_to(keypad: &mut dyn KeypadMove, moves: Vec<Position>) -> Vec<Position> {
    if moves.is_empty() {
        return vec![]
    }
    let mut next_moves = vec![];
    for m in moves {
        let (cur_p, end_p) = (keypad.get_real_position(keypad.get_cur_position()), keypad.get_real_position(m));
        let ((d1, c1), (d2, c2)) = keypad.go_to_from(cur_p, end_p);
        let (k1, k2) = (if d1 == Left { DL } else { DR }, if d2 == Down { DD } else { DU });
        if end_p.0 == -2 && cur_p.0 != -2 {
            next_moves.extend((0..c2).map(|_| k2));
            next_moves.extend((0..c1).map(|_| k1));
        } else {
            next_moves.extend((0..c1).map(|_| k1));
            next_moves.extend((0..c2).map(|_| k2));
        }
        next_moves.push(A);
        keypad.set_cur_position(m);
    }
    next_moves
}

fn main() -> Result<(), Box<dyn Error>> {

    let s: Vec<String> = std::fs::read_to_string("src/entry2.txt")?.lines().map(|s| s.trim().to_string()).collect();

    let mut acc = 0;
    for code in s {
        let mut moves = vec![];
        println!("{code}");
        let mut beg = A;
        for c in code.bytes() {
            let p: Position = match c {
                b'A' => A, b'0'..=b'9' => Position::from_primitive(c-b'0'+1), _ => unreachable!("fuck it."),
            };

            moves.extend(move_to(&mut NumKeypad { cur: beg }, vec![p]));
            beg = p;
        }

        for _ in 0..2 {
            let string = moves.iter().map(|&e| get_char_representation(e)).collect::<String>();
            println!("{} with {}", string, string.len());
            moves = move_to(&mut DirKeypad { cur: A }, moves);
        }
            let string = moves.iter().map(|&e| get_char_representation(e)).collect::<String>();
            println!("{} with {}", string, string.len());

        acc += moves.len() * code[0..3].parse::<usize>().unwrap();
    }
    println!("{acc}");

    Ok(())
}
