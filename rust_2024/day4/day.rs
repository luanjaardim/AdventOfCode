use std::error::Error;

fn main() -> Result<(), Box<dyn Error>> {

    let m : Vec<Vec<char>> = std::fs::read_to_string("src/entry.txt")
                    .unwrap()
                    .lines()
                    .map(|l| l.chars().collect::<Vec<char>>())
                    .collect();
    let (mut cnt, mut cnt2) = (0, 0);

    let is_inside_matrix = |m: &Vec<Vec<char>>, posx: isize, posy: isize| {
        posx >= 0 && posx < (m.len() as isize) && posy >= 0 && posy < (m[0].len() as isize)
    };

    for l_ind in 0..(m.len() as isize) {
        let l = &m[l_ind as usize];
        for c_ind in 0..(l.len() as isize) {
            if l[c_ind as usize] == 'X' {
                for i in -1..=1 {
                    'loop_label: for j in -1..=1 {
                        if is_inside_matrix(&m, l_ind+i, c_ind+j) &&
                           m[(l_ind+i) as usize][(c_ind+j) as usize] == 'M'
                           {
                               // println!("found M next to X at {:?}", (l_ind+i, c_ind+j));
                               let (mut x, mut y) = (i, j);
                               for to_find in ['A', 'S'] {
                                   x = if x < 0 { x-1 } else if x > 0 { x+1 } else { x };
                                   y = if y < 0 { y-1 } else if y > 0 { y+1 } else { y };
                                   if !is_inside_matrix(&m, l_ind+x, c_ind+y) ||
                                      to_find != m[(l_ind+x) as usize][(c_ind+y) as usize] {
                                       continue 'loop_label
                                   }
                               }
                               // println!("X at: ({} {}), S at: ({} {})", l_ind, c_ind, l_ind+x, c_ind+y);
                               cnt += 1;
                        }
                    }
                }
            }
            else if l[c_ind as usize] == 'A' {
                if is_inside_matrix(&m, l_ind+1, c_ind+1) &&
                   is_inside_matrix(&m, l_ind-1, c_ind+1) &&
                   is_inside_matrix(&m, l_ind+1, c_ind-1) &&
                   is_inside_matrix(&m, l_ind-1, c_ind-1) {
                       if ((m[(l_ind+1) as usize][(c_ind+1) as usize] == 'M' && m[(l_ind-1) as usize][(c_ind-1) as usize] == 'S') ||
                          (m[(l_ind+1) as usize][(c_ind+1) as usize] == 'S' && m[(l_ind-1) as usize][(c_ind-1) as usize] == 'M')) &&
                          ((m[(l_ind+1) as usize][(c_ind-1) as usize] == 'S' && m[(l_ind-1) as usize][(c_ind+1) as usize] == 'M') ||
                          (m[(l_ind+1) as usize][(c_ind-1) as usize] == 'M' && m[(l_ind-1) as usize][(c_ind+1) as usize] == 'S')) {
                              cnt2 += 1;
                          }
                   }
            }
        }
    }
    println!("{cnt} {cnt2}");

    Ok(())
}
