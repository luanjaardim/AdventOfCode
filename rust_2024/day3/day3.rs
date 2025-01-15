use std::{cmp::Ordering, error::Error, io::BufRead};

use regex::{Regex};

fn main() -> Result<(), Box<dyn Error>> {
    let s = std::fs::read_to_string("src/entry.txt")?;
    let mut r = Regex::new(r"(mul\(\d{1,3},\d{1,3}\))")?;
    let mut acc = 0;
    for e in r.find_iter(&s) {
        let found = e.as_str();
        let mut it = found[4..found.len()-1].split(',');
        let (num1, num2) = (it.next().unwrap().parse::<u64>()?, it.next().unwrap().parse::<u64>()?);
        acc += num1 * num2;
    }
    println!("{acc}");
    acc = 0;

    let mut enable = true;
    r = Regex::new(r"(mul\(\d{1,3},\d{1,3}\)|do\(\)|don\'t\(\))")?;
    for e in r.find_iter(&s) {
        let found = e.as_str();
        if let Ordering::Equal = found.cmp("do()") { enable = true; }
        else if let Ordering::Equal = found.cmp("don\'t()") { enable = false; }
        else if enable {
            let mut it = found[4..found.len()-1].split(',');
            let (num1, num2) = (it.next().unwrap().parse::<u64>()?, it.next().unwrap().parse::<u64>()?);
            acc += num1 * num2;
        }

    }
    println!("{acc}");

    Ok(())
}
