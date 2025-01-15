use std::error::Error;

#[derive(Clone, Copy, PartialEq)]
enum Dir {
    Up,
    Right,
    Down,
    Left,
}
impl Dir {
    fn change_dir(&self) -> Self {
        match self {
            Dir::Up => Dir::Right,
            Dir::Right => Dir::Down,
            Dir::Down => Dir::Left,
            Dir::Left => Dir::Up,
        }
    }
}

fn main() -> Result<(), Box<dyn Error>> {
    let s = std::fs::read_to_string("src/entry.txt").unwrap();
    let mut g_pos: (isize, isize) = (0, 0);
    let mut cur_dir = Dir::Up;

    let mut m: Vec<Vec<char>> = s.lines().enumerate().map(|(i, l)| {
            let line = l.trim();
            if let Some(j) = line.find(|c| c=='^') {
                g_pos = (i as isize, j as isize);
            }
            line.chars().collect()
    }).collect();
    let is_inside_m = |(pos_x, pos_y) : (isize, isize), m: &Vec<Vec<char>>|
            pos_x >= 0 && pos_y >= 0 && pos_x < m.len() as isize && pos_y < m[0].len() as isize;

    fn next_pos((pos_x, pos_y): (isize, isize), dir: Dir) -> (isize, isize) {
        match dir {
            Dir::Up => (pos_x-1, pos_y),
            Dir::Right => (pos_x, pos_y+1),
            Dir::Down => (pos_x+1, pos_y),
            Dir::Left => (pos_x, pos_y-1),
        }
    }

    let first_challenge = false;

    let mut cnt = 0;
    let mut next;
    if first_challenge {
        cnt += 1;
        m[g_pos.0 as usize][g_pos.1 as usize] = 'X';
        loop {
            next = next_pos(g_pos, cur_dir);
            if !is_inside_m(next, &m) { break }

            if m[next.0 as usize][next.1 as usize] == '#' {
                cur_dir = Dir::change_dir(&cur_dir);
                continue
            } else if m[next.0 as usize][next.1 as usize] == '.' {
                m[next.0 as usize][next.1 as usize] = 'X';
                cnt += 1;
            }
            g_pos = next;
        }
    } else {
        m[g_pos.0 as usize][g_pos.1 as usize] = 'X';
        const M_SIZE: usize = 130;
        let mut m_visited;
        loop {
            next = next_pos(g_pos, cur_dir);
            if !is_inside_m(next, &m) { break }

            if m[next.0 as usize][next.1 as usize] == '#' {
                cur_dir = Dir::change_dir(&cur_dir);
                continue
            } else if m[next.0 as usize][next.1 as usize] == '.' {
                let mut tmp_pos = g_pos;
                let mut tmp_dir = Dir::change_dir(&cur_dir);
                let mut tmp_next = next;
                m[next.0 as usize][next.1 as usize] = '#';
                m_visited = [[None; M_SIZE]; M_SIZE];
                m_visited[tmp_pos.0 as usize][tmp_pos.1 as usize] = Some(tmp_dir);
                loop {
                    tmp_next = next_pos(tmp_pos, tmp_dir);
                    if !is_inside_m(tmp_next, &m) { break }

                    let n = m_visited[tmp_next.0 as usize][tmp_next.1 as usize];
                    if m[tmp_next.0 as usize][tmp_next.1 as usize] == '#' {
                        tmp_dir = Dir::change_dir(&tmp_dir);
                        continue
                    } else if n.is_some() && n.unwrap() == tmp_dir {
                        cnt += 1;
                        break
                    } else {
                        m_visited[tmp_next.0 as usize][tmp_next.1 as usize] = Some(tmp_dir);
                    }
                    tmp_pos = tmp_next;
                }
                m[next.0 as usize][next.1 as usize] = 'X';
            }
            g_pos = next;
        }
    }

    println!("{cnt}");
    Ok(())
}
