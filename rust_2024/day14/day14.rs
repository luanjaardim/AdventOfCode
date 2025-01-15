use std::{collections::HashSet, error::Error};

const X_MAX: isize = 101;
const X_MID: isize = 50;
const Y_MAX: isize = 103;
const Y_MID: isize = 51;
// const X_MAX: isize = 11;
// const X_MID: isize = 5;
// const Y_MAX: isize = 7;
// const Y_MID: isize = 3;
const SECONDS: isize = 100;
const IS_SECOND_PART: bool = false;

#[derive(Debug)]
struct Robot {
    init_pos: (isize, isize),
    vel: (isize, isize)
}

fn main() -> Result<(), Box<dyn Error>> {

    let reg_numbers = regex::Regex::new(r"-?[\d]+")?;
    let robots: Vec<Robot> = std::fs::read_to_string("src/entry.txt")?.lines().map(|l| {
        let mut r = Robot { init_pos: (0, 0), vel: (0, 0) };
        let mut it = reg_numbers.find_iter(l);
        let mut parse_fn = move || { it.next().unwrap().as_str().parse::<isize>().unwrap() };
        r.init_pos = (parse_fn(), parse_fn());
        r.vel = (parse_fn(), parse_fn());
        r
    }).collect();
    let mut quantities = [[0, 0], [0, 0]];
    let (mut x, mut y) = (0, 0);
    for r in &robots {
        let (final_pos_x, final_pos_y) = ((r.init_pos.0 + r.vel.0 * SECONDS).rem_euclid(X_MAX), (r.init_pos.1 + r.vel.1 * SECONDS).rem_euclid(Y_MAX));
        if final_pos_x == X_MID || final_pos_y == Y_MID { continue }
        x = if final_pos_x < X_MID { 0 } else { 1 };
        y = if final_pos_y < Y_MID { 0 } else { 1 };
        // println!("{:?}", (final_pos_x, final_pos_y));
        quantities[x][y] += 1;
    }

    // this will print the matrix constantly to the stdout
    // redirect it to a file and then grep for a long string of '@'
    // you must run it for some time so it can find the tree!
    if IS_SECOND_PART {
        let mut positions = HashSet::new();
        let mut secs = 100;
        loop {
            positions.clear();
            for r in &robots {
                let final_pos = ((r.init_pos.0 + r.vel.0 * secs).rem_euclid(X_MAX), (r.init_pos.1 + r.vel.1 * secs).rem_euclid(Y_MAX));
                positions.insert(final_pos);
            }
            println!("seconds elapsed: {}", secs);
            secs += 1;
            for x in 0..X_MAX {
                for y in 0..Y_MAX {
                    print!("{}", if positions.contains(&(x,y)) { '@' } else { '.' });
                }
                println!();
            }

            println!();
            println!();
        }
    }


    println!("{}", quantities[0][0] * quantities[0][1] * quantities[1][0] * quantities[1][1]);
    Ok(())
}
