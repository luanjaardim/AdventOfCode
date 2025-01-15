use std::{cmp::Reverse, collections::BinaryHeap, error::Error};

const SIZE: usize = 71;
// const SIZE: usize = 7;
const BYTES: usize = 1024;
// const BYTES: usize = 12;

fn solve(m: &mut Vec<Vec<u8>>, positions: &Vec<(usize, usize)>, num: usize) -> usize {

    // reset matrix
    m.iter_mut().for_each(|l| l.fill(b'.'));

    // fill with falling bytes
    for i in 0..num {
        let p = positions[i];
        m[p.1][p.0] = b'#';
    }
    // for l in &m {
    //     for c in l {
    //         print!("{}", *c as char);
    //     }
    //     println!()
    // }

    fn get_neighbours(p: (usize, usize)) -> [Option<(usize, usize)>; 4] {
        let (x, y) = p;
        [
            (if x > 0 { Some((x-1, y)) } else { None }),
            (if x < SIZE-1 { Some((x+1, y)) } else { None }),
            (if y > 0 { Some((x, y-1)) } else { None }),
            (if y < SIZE-1 { Some((x, y+1)) } else { None }),
        ]
    }

    let mut h = BinaryHeap::from([Reverse((0, (0, 0)))]);
    let mut visited = vec![vec![false; SIZE]; SIZE];
    let mut res = 0;
    while let Some(p) = h.pop() {
        let pos = p.0.1;
        let cost = p.0.0;
        if visited[pos.0][pos.1] == true { continue }
        if pos.0 == SIZE-1 && pos.1 == SIZE-1 {
            res = cost;
            break
        }
        // println!("{:?}", p.0);
        visited[pos.0][pos.1] = true;
        for neighbour in get_neighbours(pos) {
            if let Some(n) = neighbour {
                if visited[n.0][n.1] || m[n.0][n.1] == b'#' { continue }
                h.push(Reverse((cost + 1, n)));
            }
        }
        // println!("{h:?}");
        // for l in 0..m.len() {
        //     for c in 0..m[l].len() {
        //         print!("{}", if visited[l][c] { 'o' } else { m[l][c] as char });
        //     }
        //     println!()
        // }
        // std::thread::sleep(std::time::Duration::from_secs(1));
    }
    return res;
}

fn main() -> Result<(), Box<dyn Error>> {
    let v: Vec<(usize, usize)> = std::fs::read_to_string("src/entry.txt")?
            .lines()
            .map(|l| {
                 match l.trim().split(',').map(|n| n.parse::<usize>().unwrap()).collect::<Vec<usize>>()[..] {
                     [a, b, ..] => (a, b),
                     _ => unreachable!(),
                 }
            }).collect();

    let mut m = vec![vec![b'.'; SIZE]; SIZE];
    let mut res = solve(&mut m, &v, BYTES);
    println!("{res}");

    let mut last_impossible = v.len();
    let mut highest_possible = BYTES;
    // Searching for the correct number of bytes that has no possible path by using binary search
    'out: loop {
        let mid = 1 + (highest_possible + last_impossible)/2;
        if mid == last_impossible {
            for i in (0..last_impossible).rev() {
                res = solve(&mut m, &v, i);
                if res != 0 { res = i; break 'out }
            }
        }
        let res = solve(&mut m, &v, mid);
        if res == 0 {
            last_impossible = mid;
        } else {
            highest_possible = mid;
        }
    }
    println!("{:?}", v[res]);

    Ok(())
}
