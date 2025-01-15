use std::fs;

fn main() {
    let mut buf = vec![0 as i64; 50];
    let res = fs::read_to_string("src/entry.txt")
        .unwrap()
        .lines()
        .fold(0 as u32, |acc, line| {
            let mut last_ind = 0;
            for (i, num) in line.split_whitespace().enumerate() {
                buf[i] = num.parse().unwrap();
                last_ind = i;
            }
            // increasing
            let diff_fn = if buf[0] < buf[last_ind] { |d| { d < 0 } } else { |d| { d > 0 }  };
            for i in 0..last_ind {
                let diff = buf[i] - buf[i+1];
                if !diff_fn(diff) || diff.abs() > 3 { return acc }
                // print!("{diff} ");
            }
            // println!("{:?}", &buf[0..last_ind+1]);
            acc + 1
        });


    let res2 = fs::read_to_string("src/entry.txt")
        .unwrap()
        .lines()
        .fold(0 as u32, |acc, line| {
            let mut last_ind = 0;
            for (i, num) in line.split_whitespace().enumerate() {
                buf[i] = num.parse().unwrap();
                last_ind = i;
            }
            // increasing
            let mut tolerated = false;
            let qtd_true = [buf[0] < buf[last_ind], buf[0] < buf[last_ind/2], buf[last_ind/2] < buf[last_ind]].iter().fold(0, |acc, &b| if b { acc + 1 } else { acc });
            let diff_fn = if qtd_true >= 2 { |d| { d < 0 } } else { |d| { d > 0 }  };
            let is_valid = |d: i64| { diff_fn(d) && d.abs() <=3 };
            for i in 0..last_ind {
                let diff = buf[i] - buf[i+1];
                if !diff_fn(diff) || diff.abs() > 3 { 
                    if !tolerated {
                        // The last level is removed
                        if i+1 == last_ind { return acc + 1 }
                        // The first diff is already wrong, the first or the second element
                        // can be wrong, so we will compare the first and the third element
                        // if everything is right, then the second was the problem and we
                        // override it with the first, else we just ignore the first element
                        else if i == 0 && i+2 <= last_ind
                        {
                            // has the correct signal has the correct magnitude
                            if is_valid(buf[0] - buf[2]) { buf[1] = buf[0]; }
                        }
                        // For every other case we override the next element with the current one
                        else if i+2 <= last_ind {
                            if is_valid(buf[i] - buf[i+2]) { buf[i+1] = buf[i]; }
                            else if is_valid(buf[i-1] - buf[i+1]) { () }
                            else {
                                // println!("{:?}", &buf[0..=last_ind]);
                                return acc
                            }
                        }
                        else {
                            panic!("Shit2!!!");
                        }
                        tolerated = true; // only one bad level is tolerated
                        continue
                    }
                    // println!("{:?}", &buf[0..=last_ind]);
                    return acc
                }
                // print!("{diff} ");
            }
            // println!("{:?}", &buf[0..last_ind+1]);
            acc + 1
        });
    println!("{res} {res2}");
}
