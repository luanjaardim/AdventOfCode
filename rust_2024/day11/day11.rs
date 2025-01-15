use std::error::Error;

const END: usize = 25;
const MEM_LIMIT: usize = 1000000;

fn rec(mut num: usize, it: usize, mem: &mut Vec<Vec<usize>>) -> usize {
    for i in it..END {

        if num == 0 {
            num = 1;
            continue
        }
        let str_num = num.to_string();
        if str_num.len() & 0x1 == 0 {
            let half_ind = str_num.len() / 2;
            if num < MEM_LIMIT {
                if mem[i][num] != u32::MAX as usize {
                    return mem[i][num];
                } else {
                    mem[i][num] =
                        rec(str_num[0..half_ind].parse::<usize>().unwrap(), i+1, mem)
                        + rec(str_num[half_ind..].parse::<usize>().unwrap(), i+1, mem);
                    return mem[i][num]
                }
            } else {
                return
                    rec(str_num[0..half_ind].parse::<usize>().unwrap(), i+1, mem) 
                    + rec(str_num[half_ind..].parse::<usize>().unwrap(), i+1, mem)
            }

        } else {
            num *= 2024;
        }
    }
    // println!("{num}");
    1
}

fn main() -> Result<(), Box<dyn Error>> {

    // memoization matrix
    let mut mem = vec![vec![u32::MAX as usize; MEM_LIMIT]; END];
    let ans = std::fs::read_to_string("src/entry.txt")
        .unwrap()
        .split_whitespace()
        .map(|n| {
            rec(n.parse::<usize>().unwrap(), 0, &mut mem)
        }).sum::<usize>();
    println!("\n{ans}");

    Ok(())
}
