use std::error::Error;

fn first_q() {
    let mut s = std::fs::read("src/entry.txt").unwrap();
    s.pop(); // remove \n
    let mut v: Vec<usize> = s.iter().map(|&digit| digit as usize - '0' as usize).collect();

    // even indexes for files and odd for free blocks
    let mut last_id = (s.len()-1)/2;
    let mut last_file_ind = if (s.len() & 0x1) == 0x0 { s.len()-2 } else { s.len()-1 };

    let (mut id, mut ind, mut cnt) = (0, 0, 0);
    for (i, &n_val) in v.clone().iter().enumerate() {
        // println!("for char {} from index {ind} to {}\n\tid: {id}, index on real string: {i}", (n_val as u8 + 48) as char, ind + n_val -1);
        if i & 0x1 == 0x0 && last_id != id {
            cnt += (ind..ind+n_val).map(|j| j*id).sum::<usize>();
            id += 1;
        } else {
            let end = ind + (if last_id == id { std::cmp::min(n_val, v[last_file_ind]) } else { n_val });
            cnt += (ind..end).map(|j| {
                // println!("{j} {last_file_qt}");
                while v[last_file_ind] <= 0 {
                    if last_id <= id { return 0 }
                    last_file_ind -= 2;
                    last_id -= 1;
                    // if last_id == 6 { println!("here"); }
                }
                // println!("it: {last_id}");
                v[last_file_ind] -= 1;
                last_id * j
            }).sum::<usize>();
            if last_id == id && v[last_file_ind] == 0 { break }
        }
        // println!("\tresulted value: {}", res);
        ind += n_val;
    }

    println!("{cnt}");
}

fn second_q() {

    let mut s = std::fs::read("src/entry.txt").unwrap();
    s.pop(); // remove \n
    let mut ind: isize = 0;
    let mut v: Vec<(usize, usize)> = s.iter().map(|&digit| {
        let num = digit as usize - '0' as usize;
        let res = (ind as usize, num);
        ind += num as isize;
        res
    }).collect();

    let last_file_ind = if (s.len() & 0x1) == 0x0 { s.len()-2 } else { s.len()-1 };
    // println!("{:?}", v);

    let mut cnt = 0;
    for last in (0..=last_file_ind).rev().step_by(2) {
        let last_id = last/2;
        for free in (1..last).step_by(2) {
            if v[free].1 >= v[last].1 {
                // println!("at free: {} with number {} fill with {} {} -> {}", free, v[free].1, v[last].1, last_id, last_id * (v[free].0..v[free].0+v[free].1).sum::<usize>());
                // println!("{:?}", (v[free].0..v[free].0+v[last].1).collect::<Vec<usize>>());
                cnt += last_id * (v[free].0..v[free].0+v[last].1).sum::<usize>();
                v[free] = (v[free].0+v[last].1, v[free].1-v[last].1);
                v[last] = (v[last].0, 0);
                break
            }
        }
    }

    ind = -1;
    cnt += v.iter().step_by(2).map(|&(i, qnt)| {
        ind += 1;
        // println!("id: {} at {} with len {} -> {}", ind, i, qnt, (ind as usize) * (i..i+qnt).sum::<usize>());
        (ind as usize) * (i..i+qnt).sum::<usize>()
    }).sum::<usize>();

    println!("{cnt}");
}

fn main() -> Result<(), Box<dyn Error>> {

    first_q();
    second_q();
    Ok(())
}
