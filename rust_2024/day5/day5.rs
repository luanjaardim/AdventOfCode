use std::{collections::{HashMap, HashSet}, error::Error};

fn main() -> Result<(), Box<dyn Error>> {

    let s = std::fs::read_to_string("src/entry.txt")?;
    let mut it = s.lines();

    let (mut x, mut y) = (0, 0);
    let mut m: HashMap<usize, HashSet<usize>> = HashMap::new();
    while let Some(line) = it.next() {
        if line.len() == 0 {
            break
        }
        let mut s = line.split(|c| c == '|');
        (x, y) = (s.next().unwrap().parse()?, s.next().unwrap().parse()?);

        if m.get(&x).is_none() {
            m.insert(x, HashSet::new());
        }
        m.get_mut(&x).unwrap().insert(y);
    }

    let (mut val, mut cnt, mut cnt2) = (0, 0, 0);
    let mut ordered_numbers = vec![];
    let mut incorrect_ordered_numbers = vec![];
    let mut still_correct = true;
    while let Some(line) = it.next() {
        ordered_numbers.clear();
        incorrect_ordered_numbers.clear();
        still_correct = true;
        for num in line.split(|c| c == ',') {
            val = num.parse::<usize>()?;
            for prev_num in &ordered_numbers {
                if !still_correct { break }
                if m.get(&val).is_some() && m.get(&val).unwrap().contains(prev_num) {
                    still_correct = false;
                    incorrect_ordered_numbers = ordered_numbers.clone();
                }
            }
            if still_correct { ordered_numbers.push(val); }
            else {
                // Second part, only check sequence that is not ordered
                let mut add_at = -1;
                for (i, prev_num) in incorrect_ordered_numbers.iter().enumerate() {
                    if m.get(&val).is_some() && m.get(&val).unwrap().contains(prev_num) {
                        add_at = i as isize;
                        break
                    }
                }
                if add_at == -1 { incorrect_ordered_numbers.push(val); }
                else { incorrect_ordered_numbers.insert(add_at as usize, val); }
            }
        }
        if still_correct { cnt += ordered_numbers[ordered_numbers.len()/2]; }
        else { cnt2 += incorrect_ordered_numbers[incorrect_ordered_numbers.len()/2]; }
    }
    println!("{cnt} {cnt2}");

    Ok(())
}
