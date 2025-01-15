use std::fs;
use std::collections::HashMap;

fn main() {
    let (mut first_l, mut second_l) : (Vec<i64>, Vec<i64>) = fs::read_to_string("src/entry.txt")
                .unwrap()
                .lines()
                .map(|line| {
                    let mut nums = line.split_whitespace();
                    (nums.next().unwrap().parse::<i64>().unwrap(), nums.next().unwrap().parse::<i64>().unwrap())
                }).unzip();

    first_l.sort();
    second_l.sort();
    let d: i64 = first_l.iter().enumerate().map(|(i, n)| (n - second_l[i]).abs()).sum();

    let mut m: HashMap<i64, i64> = first_l.iter().map(|&n| (n, 0 as i64)).collect();
    for elem in second_l {
        if let Some(v) = m.get_mut(&elem) {
            *v += 1;
        }
    }
    let sum2: i64 = m.iter().map(|(&num, &qtd)| num * qtd).sum();

    println!("{d} {sum2}");
}
