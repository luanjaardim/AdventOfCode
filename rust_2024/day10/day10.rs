use std::{collections::HashSet, error::Error};

const is_first_question: bool = false;

fn is_inside(m: &Vec<Vec<u8>>, pos: (isize, isize)) -> bool {
    pos.0 >= 0 && pos.1 >= 0 && (pos.0 as usize) < m.len() && (pos.1 as usize) < m[0].len()
}

fn rec(m: &mut Vec<Vec<u8>>, visited: &mut HashSet<(isize, isize)>, cur_pos: (isize, isize), cnt: &mut usize) {
    let cur_num = m[cur_pos.0 as usize][cur_pos.1 as usize];
    if cur_num == 9 {
        if is_first_question {
            if !visited.contains(&cur_pos) {
                visited.insert(cur_pos);
                *cnt += 1;
            } else { return }
        } else {
            *cnt += 1;
        }
        return
    }
    for &pos in &[(cur_pos.0+1, cur_pos.1), (cur_pos.0, cur_pos.1+1), (cur_pos.0-1, cur_pos.1), (cur_pos.0, cur_pos.1-1)] {
        if is_inside(m, pos) && m[pos.0 as usize][pos.1 as usize] == cur_num + 1 { rec(m, visited, pos, cnt) }
    }
}

fn main() -> Result<(), Box<dyn Error>> {

    let mut m: Vec<Vec<u8>> = std::fs::read_to_string("src/entry.txt").unwrap()
        .lines()
        .map(|l| l.trim().chars().map(|digit| digit as u8 - '0' as u8).collect())
        .collect();

    let mut cnt = 0;
    let mut set = HashSet::new();
    for l in 0..m.len() {
        for c in 0..m[l].len() {
            // print!("{}", m[l][c]);
            if m[l][c] == 0 {
                set.clear();
                rec(&mut m, &mut set, (l as isize, c as isize), &mut cnt);
            }
        }
    }
    println!("{cnt}");

    Ok(())
}
