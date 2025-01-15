use std::{error::Error, io::{BufRead, Read}};

fn first_q() {

    let mut m: Vec<Vec<u8>> = Vec::new();
    let s = std::fs::read_to_string("src/entry.txt").unwrap();
    let mut it = s.lines();
    let mut robot_pos = (0, 0);
    while let Some(l) = it.next() {
        if l.is_empty() {
            break
        } else {
            m.push(l.bytes().collect());
            if let Some(r_pos) = l.find('@') {
                robot_pos = (robot_pos.0, r_pos);
            }
            if robot_pos.1 == 0 {
                robot_pos = (robot_pos.0+1, 0);
            }
        }
    };
    let moves = it.fold(String::new(), |mut acc, s| { acc.push_str(s.trim()); acc });

    let mut tmp_pos;
    '_loop_: for c in moves.bytes() {
        let d: (isize, isize) = match c {
            b'>' => (0, 1),
            b'<' => (0, -1),
            b'^' => (-1, 0),
            b'v' => (1, 0),
            _ => panic!("Found an unexpected char"),
        };

        tmp_pos = robot_pos;
        // println!("moving to {}", c as char);
        // std::thread::sleep(std::time::Duration::from_millis(500));
        // let mut b = [0; 1];
        // std::io::stdin().read_exact(&mut b).unwrap();
        loop {
            tmp_pos = (((tmp_pos.0 as isize) + d.0) as usize, ((tmp_pos.1 as isize) + d.1) as usize);
            if m[tmp_pos.0][tmp_pos.1] == b'#' {
                // println!("Could not realize the movement");
                continue '_loop_
            }
            else if m[tmp_pos.0][tmp_pos.1] == b'.' { 
                // println!("{robot_pos:?}");
                // println!("{:?}: {}", tmp_pos, m[tmp_pos.0][tmp_pos.1] as char);
                break
            }
        }
        while tmp_pos != robot_pos {
            m[tmp_pos.0][tmp_pos.1] = m[((tmp_pos.0 as isize) - d.0) as usize][((tmp_pos.1 as isize) - d.1) as usize];
            tmp_pos = (((tmp_pos.0 as isize) - d.0) as usize, ((tmp_pos.1 as isize) - d.1) as usize);
        }
        m[robot_pos.0][robot_pos.1] = b'.';
        robot_pos = (((robot_pos.0 as isize) + d.0) as usize, ((robot_pos.1 as isize) + d.1) as usize);


        // for (i, l) in m.iter().enumerate() {
        //     for c in l {
        //         print!("{}", *c as char);
        //     }
        //     println!("   line: {i}");
        // }
    }
    let mut cnt = 0;
    for i in 0..m.len() {
        for j in 0..m[i].len() {
            if m[i][j] == b'O' {
                cnt += 100 * i + j;
            }
        }
    }
    println!("{cnt}");
}

fn second_q() {
    let mut m: Vec<Vec<u8>> = Vec::new();
    let s = std::fs::read_to_string("src/entry.txt").unwrap();
    let mut it = s.lines();
    let mut robot_pos = (0, 0);
    while let Some(l) = it.next() {
        if l.is_empty() {
            break
        } else {
            m.push(l.bytes().flat_map(|c| {
                match c {
                    b'.' => [b'.', b'.'],
                    b'@' => [b'@', b'.'],
                    b'#' => [b'#', b'#'],
                    b'O' => [b'[', b']'],
                    _ => panic!("Unknown char"),
                }
            }).collect());
            if let Some(r_pos) = l.find('@') {
                robot_pos = (robot_pos.0, r_pos*2);
            }
            if robot_pos.1 == 0 {
                robot_pos = (robot_pos.0+1, 0);
            }
        }
    };
    let moves = it.fold(String::new(), |mut acc, s| { acc.push_str(s.trim()); acc });

    for l in m {
        for c in l {
            print!("{}", c as char);
        }
        println!();
    }
    println!("{robot_pos:?}");

}

fn main() -> Result<(), Box<dyn Error>> {

    // first_q();
    second_q();
    Ok(())
}
