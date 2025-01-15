use std::{cmp::Reverse, collections::HashSet, error::Error};

use Dir::*;
#[derive(Debug, PartialEq, Eq, Clone, Copy)]
enum Dir {
    Right, Left, Up, Down
}
impl Dir {
    fn neighbour(dir: Dir, (l, c): (usize, usize)) -> (usize, usize) {
        match dir {
            Right => (l, c+1),
            Left => (l, c-1),
            Down => (l+1, c),
            Up => (l-1, c),
        }
    }
    fn oposite(dir: Dir) -> Dir {
        match dir {
            Right => Left,
            Left => Right,
            Down => Up,
            Up => Down,
        }
    }
}

#[derive(Debug, Clone)]
struct Node {
    cost: usize,
    pos: (usize, usize),
    dir: Dir,
}
impl Node {
    fn new(cost: usize, pos: (usize, usize), dir: Dir) -> Self { Node {cost, pos, dir } }
}
impl PartialEq for Node {
    fn eq(&self, other: &Self) -> bool { self.cost == other.cost }
    fn ne(&self, other: &Self) -> bool { self.cost != other.cost }
}
impl PartialOrd for Node {
    fn lt(&self, other: &Self) -> bool { self.cost < other.cost }
    fn le(&self, other: &Self) -> bool { self.cost <= other.cost }
    fn gt(&self, other: &Self) -> bool { self.cost > other.cost }
    fn ge(&self, other: &Self) -> bool { self.cost >= other.cost }
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
        Some(self.cost.cmp(&other.cost))
    }
}
impl Eq for Node { }
impl Ord for Node {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        self.cost.cmp(&other.cost)
    }
    fn max(self, other: Self) -> Self
        where
            Self: Sized, {
        if self.cost > other.cost { self } else { other }
    }
    fn min(self, other: Self) -> Self
        where
            Self: Sized, {
        if self.cost < other.cost { self } else { other }
    }
}

#[derive(Debug, Clone)]
struct Point {
    cost: usize, // Cost to get into the point
    from: Option<Dir>,   // The direction that we got into this point
    to: Option<Dir>,     // The direction we gone out of this point
}

fn main() -> Result<(), Box<dyn Error>> {
    let m: Vec<Vec<u8>> = std::fs::read_to_string("src/entry.txt")?
                .lines()
                .map(|l|{
                    l.trim().bytes().collect()
                }).collect();

    let first_pos: (usize, usize) = (m.len()-2, 1);
    let first_dir: Dir = Dir::Right;
    let mut pos_to_visit = std::collections::BinaryHeap::from([ Reverse(Node::new(0, first_pos, first_dir)) ]);
    let mut visited: Vec<Vec<Point>> = m.iter().map(|l| l.iter().map(|_| Point{cost: 0, from: None, to: None}).collect()).collect();
    let mut queue = vec![];

    while let Some(p) = pos_to_visit.pop() {
        let n = p.0;
        if visited[n.pos.0][n.pos.1].from.is_some() { continue }
        visited[n.pos.0][n.pos.1].cost = n.cost;
        visited[n.pos.0][n.pos.1].from = Some(Dir::oposite(n.dir));
        queue.push(n.clone());
        // println!("{}", n.cost);
        // for l in 0..m.len() {
        //     for c in 0..m[l].len() {
        //         if l == n.pos.0 && c == n.pos.1 {
        //             print!("X")
        //         } else { print!("{}", m[l][c] as char) }
        //     }
        //     println!();
        // }
        //     println!();
        if m[n.pos.0][n.pos.1] == b'E' {
            visited[n.pos.0][n.pos.1].to = Some(n.dir);
            break
        }

        for d in [Dir::Right, Dir::Down, Dir::Left, Dir::Up] {
            let neighbour = Dir::neighbour(d, n.pos);
            if m[neighbour.0][neighbour.1] != b'#' {
                let neighbour_cost = n.cost + (if n.dir == d { 1 } else { 1001 });
                pos_to_visit.push(Reverse(Node::new(neighbour_cost, neighbour, d)))
            }
        }
    }
    fn get_valid_neighbours(set: &mut HashSet<(usize, usize)>, m: &mut Vec<Vec<Point>>, pos: (usize, usize)) {
        let p_point = m[pos.0][pos.1].clone();
        let mut dirs = vec![ Right, Left, Up, Down ];
        if let Some(to) = p_point.to {
            dirs.remove(to as usize);
        }
        for d in dirs {
            let n = Dir::neighbour(d, pos);
            if m[n.0][n.1].from.is_some() {
                let n_point = &mut m[n.0][n.1];
                n_point.to = Some(Dir::oposite(d));
                let mut diff: isize = 1;
                // println!("{:?}: p: {:?}, n: {:?}", n, p_point, n_point);
                if n_point.from.unwrap() != Dir::oposite(n_point.to.unwrap()) {
                    diff += 1000;
                } else if p_point.from.unwrap() != Dir::oposite(p_point.to.unwrap()) && Dir::oposite(d) == p_point.to.unwrap() {
                    diff -= 1000;
                }
                // println!("diff: {}", diff);
                if p_point.cost as isize - n_point.cost as isize == diff {
                    set.insert(n);
                    get_valid_neighbours(set, m, n);
                }
            }
        }
    }

    // for l in &m {
    //     for c in l {
    //         print!("{}", *c as char);
    //     }
    //     println!();
    // }
    // for l in 0..m.len() {
    //     for c in 0..m[l].len() {
    //         print!("{}", if !h.contains(&(l, c)) { m[l][c] as char } else { 'o' });
    //     }
    //     println!()
    // }
    let (last_l, last_c) = (1, visited[1].len()-2);
    println!("{}", visited[last_l][last_c].cost);

    let mut h = HashSet::from([(1, m[1].len()-2)]);
    get_valid_neighbours(&mut h, &mut visited, (1, m[1].len()-2));
    println!("{}", h.len());

    Ok(())
}
