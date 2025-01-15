use std::{collections::{HashMap, HashSet}, error::Error};

const first_answer: bool = false;

fn main() -> Result<(), Box<dyn Error>> {

    let s = std::fs::read_to_string("src/entry.txt").unwrap();
    let mut mat: Vec<Vec<char>> = s.lines().map(|l| l.chars().collect()).collect();
    let mut m: HashMap<char, Vec<(isize, isize)>> = HashMap::new();
    for i in 0..mat.len() {
        let l = &mut mat[i];
        for j in 0..l.len() {
            let c = l[j];
            if let Some(positions) = m.get_mut(&c) {
                positions.push((i as isize, j as isize));
                if !first_answer { l[j] = '#' }
            } else if c != '.' {
                m.insert(c, vec![(i as isize, j as isize)]);
                if !first_answer { l[j] = '#' }
            }
        }
    }

    let mut cnt = 0;
    let (mut antinode_x, mut antinode_y) = (0, 0);
    for (_, v) in m {
        for i in 0..v.len() {
            for j in 0..v.len() {
                if i == j { continue }

                let diff_x = v[i].0 - v[j].0;
                let diff_y = v[i].1 - v[j].1;

                antinode_x = v[i].0 + diff_x;
                antinode_y = v[i].1 + diff_y;
                while antinode_x >= 0 && antinode_y >= 0   &&
                      (antinode_x as usize) < mat.len()    &&
                      (antinode_y as usize) < mat[0].len()
                {
                    if mat[antinode_x as usize][antinode_y as usize] != '#' {
                       cnt += 1;
                       mat[antinode_x as usize][antinode_y as usize] = '#';
                    }
                    if first_answer { break }
                    antinode_x += diff_x;
                    antinode_y += diff_y;
                }
            }
        }
        if !first_answer {
            cnt += if v.len() > 1 { v.len() } else { 0 };
        }
    }
    for l in mat{
        for c in l{
            print!("{c} ");
        }
        println!("");
    }
    println!("{cnt}");

    Ok(())
}
