use std::{collections::VecDeque, error::Error};

use Dir::*;
#[derive(Debug, PartialEq, Eq, Clone, Copy)]
enum Dir {
    Right, Left, Up, Down
}
impl Dir {
    fn neighbour<T>(m: &Vec<Vec<T>>, dir: Dir, (l, c): (usize, usize)) -> Option<(usize, usize)> {
        match dir {
            Right if c < m[0].len()-1 => Some((l, c+1)),
            Left if c > 0 => Some((l, c-1)),
            Down if l < m.len()-1 => Some((l+1, c)),
            Up if l > 0 => Some((l-1, c)),
            _ => None,
        }
    }
}

fn bfs_from_pos(m: &Vec<Vec<u8>>, dists_to_start: &mut Vec<Vec<usize>>, start_pos: (usize, usize)) {
    let mut q = VecDeque::from([start_pos]);
    let mut visited = vec![vec![false; m[0].len()]; m.len()];
    dists_to_start[start_pos.0][start_pos.1] = 0;
    while let Some(p) = q.pop_front() {
        if visited[p.0][p.1] { continue }
        visited[p.0][p.1] = true;
        for n in [ (p.0+1,p.1), (p.0-1,p.1), (p.0,p.1+1), (p.0,p.1-1) ] {
            if m[n.0][n.1] != b'#' && !visited[n.0][n.1] {
                dists_to_start[n.0][n.1] = dists_to_start[p.0][p.1] + 1;
                q.push_back(n);
            }
        }
    }
}

fn main() -> Result<(), Box<dyn Error>> {

    let (mut start_pos, mut final_pos) = ((0, 0), (0, 0));
    let m: Vec<Vec<u8>> = std::fs::read_to_string("src/entry.txt")?
                .lines()
                .enumerate()
                .map(|(i, l)| {
                    let s = l.trim();
                    if let Some(start_c) = s.find('S') { start_pos = (i, start_c); }
                    if let Some(final_c) = s.find('E') { final_pos = (i, final_c); }
                    s.bytes().collect()
                }).collect();

    let mut dists_to_start = vec![vec![u32::MAX as usize; m[0].len()]; m.len()];
    let mut dists_to_final = vec![vec![u32::MAX as usize; m[0].len()]; m.len()];
    bfs_from_pos(&m, &mut dists_to_start, start_pos);
    bfs_from_pos(&m, &mut dists_to_final, final_pos);

    let mut cnt = 0;
    for i in 0..m.len() {
        for j in 0..m[0].len() {
            if m[i][j] != b'#' {
                for d in [Right, Left, Up, Down] {
                    if let Some(n) = Dir::neighbour(&m, d, (i, j)) {
                        if let Some(n_far) = Dir::neighbour(&m, d, n) {
                            if m[n.0][n.1] == b'#' && m[n_far.0][n_far.1] != b'#' {
                                let cur_dist = dists_to_start[i][j] + dists_to_final[i][j];
                                let new_dist_with_jump =  dists_to_start[i][j] + 2 + dists_to_final[n_far.0][n_far.1];

                                if cur_dist > new_dist_with_jump  &&  cur_dist - new_dist_with_jump >= 100 {
                                    cnt += 1;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    println!("{cnt}");

    fn is_inside(p: (isize, isize), m: &Vec<Vec<u8>>) -> bool {
        if p.0 >= 0 && p.0 < m.len() as isize && p.1 >= 0 && p.1 < m[0].len() as isize { true } else { false }
    }

    cnt = 0;
    for i in 0..m.len() {
        for j in 0..m[0].len() {
            if m[i][j] != b'#' {
                for l in -20isize..=20 {
                    let c_limit = 20-l.abs();
                    for c in -1*c_limit..=c_limit {
                        let p = (i as isize + l, j as isize + c);
                        if is_inside(p, &m) && m[p.0 as usize][p.1 as usize] != b'#' {
                            let cur_dist = dists_to_start[i][j] + dists_to_final[i][j];
                            let new_dist_with_jump =  dists_to_start[i][j]
                                                    + l.abs() as usize
                                                    + c.abs() as usize
                                                    + dists_to_final[p.0 as usize][p.1 as usize];

                            if cur_dist > new_dist_with_jump  &&  cur_dist - new_dist_with_jump >= 100 {
                // print!("({:?}) -> to start: {}, to final: {}, ", (i, j), dists_to_start[i][j], dists_to_final[i][j]);
                // println!("from neighbour{:?} to final: {}", n_far, dists_to_final[n_far.0][n_far.1]);
                                cnt += 1;
                            }
                        }
                    }
                }
            }
        }
    }
    println!("{cnt}");

    Ok(())
}
