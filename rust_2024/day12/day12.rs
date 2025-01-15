use std::{collections::HashMap, error::Error, process::exit};

fn is_inside<T>(m: &Vec<Vec<T>>, pos: (isize, isize)) -> bool {
    pos.0 >= 0 && pos.1 >= 0 && (pos.0 as usize) < m.len() && (pos.1 as usize) < m[0].len()
}

fn rec(m: &mut Vec<Vec<(u8, bool)>>, region_elems: &mut Vec<(isize, isize)>, pos: (isize, isize), elem: u8, area: usize, perim: usize) -> (usize, usize) {

    m[pos.0 as usize][pos.1 as usize] = (elem, true);
    let mut cur_peri = 4;
    let mut acc_area = 0;
    let mut acc_peri = 0;
    for &(x, y) in &[(pos.0+1, pos.1), (pos.0-1, pos.1), (pos.0, pos.1+1), (pos.0, pos.1-1)] {
        if is_inside(m, (x, y)) && m[x as usize][y as usize].0 == elem {
            cur_peri -= 1;
            if !m[x as usize][y as usize].1 {
                let (tmp_perim, tmp_area) = rec(m, region_elems, (x, y), elem, area, perim);
                acc_peri += tmp_perim;
                acc_area += tmp_area;
            }
        }
    }
    region_elems.push(pos);
    (perim+acc_peri+cur_peri, area+acc_area+1)
}

use RelativePos::*;
#[derive(Debug, PartialEq)]
enum RelativePos {
    Up,
    Down,
    Right,
    Left,
}
impl RelativePos {
    fn prev_dir(self) -> Self {
        match self {
            Right => Up,
            Up => Left,
            Left => Down,
            Down => Right,
        }
    }
    fn next_dir(self) -> Self {
        match self {
            Right => Down,
            Down => Left,
            Left => Up,
            Up => Right,
        }
    }
    fn neighbour_at(m: &Vec<Vec<u8>>, pos: (usize, usize), dir: RelativePos, search_val: u8) -> Option<(usize, usize)> {
        if pos.0 == 0 && dir == Up
           || pos.1 == 0 && dir == Left
           || pos.0 == m.len() - 1 && dir == Down
           || pos.1 == m[0].len() - 1 && dir == Right
        {
            return None
        }
        match dir {
            Right if m[pos.0][pos.1+1] == search_val => Some((pos.0, pos.1+1)),
            Down if m[pos.0][pos.1+1] == search_val => Some((pos.0, pos.1+1)),
            Left if m[pos.0][pos.1+1] == search_val => Some((pos.0, pos.1+1)),
            Up if m[pos.0][pos.1+1] == search_val => Some((pos.0, pos.1+1)),
            _ => None,
        }
    }
}

fn calculate_sides(elems: &Vec<(isize, isize)>) -> usize {
    let (mut max_x, mut min_x, mut max_y, mut min_y) = (std::usize::MIN, std::usize::MAX, std::usize::MIN, std::usize::MAX);
    for &(x, y) in elems {
        max_x = if (x as usize) > max_x { x as usize } else { max_x };
        min_x = if (x as usize) < min_x { x as usize } else { min_x };
        max_y = if (y as usize) > max_y { y as usize } else { max_y };
        min_y = if (y as usize) < min_y { y as usize } else { min_y };
    }
    let (x_len, y_len) = (1+max_x-min_x, 1+max_y-min_y);
    println!("{x_len} {y_len}");
    let mut m = vec![vec![b'.'; y_len]; x_len];
    for &(x, y) in elems {
        m[(x as usize) - min_x][(y as usize) - min_y] = b'#';
    }
    for l in m {
        for c in l {
            print!("{}", c as char);
        }
        println!();
    }
    println!("{:?}", elems.last().unwrap());
    exit(0);
    0
}

fn main() -> Result<(), Box<dyn Error>> {

    let mut m: Vec<Vec<(u8, bool)>> = std::fs::read_to_string("src/entry2.txt")
           .unwrap()
           .lines()
           .map(|l| 
                l.bytes()
                 .map(|c| (c, false))
                 .collect())
           .collect();

    let mut acc = 0;
    let mut perimeters = Vec::new();
    for i in 0..m.len() {
        for j in 0..m[i].len() {
            let c = m[i][j].0;
            if !m[i][j].1 {
                let (area, peri) = rec(&mut m, &mut perimeters, (i as isize, j as isize), c, 0, 0);
                calculate_sides(&perimeters);
                acc += area * peri;
            }
        }
    }
    println!("{acc}");

    Ok(())
}
