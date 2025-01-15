use std::{collections::{HashMap, BTreeSet}, error::Error};

fn find_combs(sequences: &Vec<String>, patterns: &Vec<&str>, all_possibilities: bool) -> usize {
    let mut q = Vec::new();
    let mut cnt = 0;
    let mut b_str;
    let mut b_pat;
    for s in sequences {
        q.clear();
        b_str = 0;
        b_pat = 0;
        // println!("sequence: {s}");

        'inf_loop: loop {
            // std::thread::sleep(std::time::Duration::from_secs(1));
            for i in b_pat..patterns.len() {
                let p = patterns[i];
                if (&s[b_str..]).len() >= p.len() && &s[b_str..b_str+p.len()] == p {
                    q.push(Pattern { ind: b_str, ind_pattern: i, len: p.len() });
                    b_str += p.len();
                    b_pat = 0;
                    // println!("trying with: {p}, {:?}", q.last());
                    continue 'inf_loop
                }
            }
            if b_str == s.len() {
                // println!("sequence: {s}, is possible");
                cnt += 1;
                if !all_possibilities { break }
            }
            if !q.is_empty() {
                let pat = q.pop().unwrap();
                b_str = pat.ind;
                b_pat = pat.ind_pattern + 1;
                // println!("giving up on {}", &s[pat.ind..pat.ind+pat.len]);
            } else { break }
        }
    }
    cnt
}

fn solve_second_half<'a>(sequence: &'a str, patterns: &BTreeSet<&str>, memo: &mut HashMap<&'a str, usize>) -> Option<usize> {
    let mut impossible = true;
    let mut cnt = 0;
    if sequence.is_empty() { return Some(1) }
    for &p in patterns.iter() {
        if sequence.len() >= p.len() && &sequence[0..p.len()] == p {
            if let Some(mem) = memo.get(&sequence[p.len()..]){
                cnt += mem;
                impossible = false;
            }
            else if let Some(after) = solve_second_half(&sequence[p.len()..], patterns, memo) {
                cnt += after;
                memo.insert(&sequence[p.len()..], after);
                impossible = false;
            }
        }
    }
    if impossible { None }
    else { Some(cnt) }
}

#[derive(Debug)]
struct Pattern {
    ind: usize,
    ind_pattern: usize,
    len: usize,
}

fn main() -> Result<(), Box<dyn Error>> {
    let s = std::fs::read_to_string("src/entry.txt")?;
    let mut it = s.lines();
    let patterns: Vec<&str> = it.next().unwrap().split(", ").collect();
    it.next();

    let sequences: Vec<String> = it.map(|l| l.trim().to_string()).collect();
    // println!("{patterns:?}");
    // println!("{sequences:?}");

    // let res = find_combs(&sequences, &patterns, false);
    // println!("{res}");
    // let res = find_combs(&sequences, &patterns, true);
    // println!("{res}");

    // patterns.sort_by(|a, b| a.len().cmp(&b.len()));
    // println!("{patterns:?}");
    let patterns_set: BTreeSet<&str> = patterns.iter().map(|&p| p).collect();
    let mut calculated_pat_combs: HashMap<&str, usize> = patterns.iter().map(|&p| (p, find_combs(&vec![p.to_string()], &patterns, true))).collect();
    calculated_pat_combs.insert("", 1);
    // println!("{patterns_from_subpatterns:?}");
    let mut res = 0;
    for s in &sequences {
        // println!("seq: {s}");
        res += match solve_second_half(s, &patterns_set, &mut calculated_pat_combs) {
            Some(n) => {
                // println!("s is solvable with {n} combs");
                // println!("expected: {}", find_combs(&vec![s.clone()], &patterns, true));
                n
            },
            None => {
                // println!("s is not solvable");
                0
            },
        }
    }
    println!("{res}");

    Ok(())
}
