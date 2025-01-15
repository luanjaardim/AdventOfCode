use std::error::Error;

const second_problem: bool = true;

fn calculate(acc: usize, i: usize, v: &Vec<usize>, expected_value: usize) -> usize {
    if i == v.len() { return acc }
    if acc > expected_value { return acc }

    let mut val = calculate(acc + v[i], i+1, v, expected_value);
    if val == expected_value { return val }
    val = calculate(acc * v[i], i+1, v, expected_value);
    if val == expected_value { return val }
    if second_problem {
        let concat_num = format!("{}{}", acc, v[i]);
        val = calculate(concat_num.parse().unwrap(), i+1, v, expected_value);
        if val == expected_value { return val }
    }
    0
}

fn main() -> Result<(), Box<dyn Error>> {

    let s = std::fs::read_to_string("src/entry.txt").unwrap();
    let num = s.lines().fold(0, |acc, l| {
        let mut it = l.split_whitespace();
        let first = it.next().unwrap();
        let exp_value = (&first[..first.len()-1]).parse::<usize>().unwrap();
        let values: Vec<usize> = it.map(|n| n.parse().unwrap()).collect();
        acc + calculate(0, 0, &values, exp_value)
    });
    println!("{num}");
    Ok(())
}
