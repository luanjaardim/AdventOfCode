use std::error::Error;

const A: usize = 0;
const B: usize = 1;
const C: usize = 2;

fn solve(regs: &mut [u128; 3], out: &mut Vec<u128>, program: &Vec<u8>, a: u128) {
    *regs = [a, 0, 0];
    out.clear();
    let mut instructions = program.iter();

    fn get_operand_value(op: u128, regs: &[u128; 3]) -> u128 {
        match op {
            0..=3 => op,
            4..=6 => regs[(op - 4) as usize],
            _ => panic!("Invalid operand"),
        }
    }

    while let Some(instruction) = instructions.next() {
        let literal = *instructions.next().unwrap() as u128;
        let combo = get_operand_value(literal, &regs);
        // println!("instruction {instruction} with literal {literal} and combo {combo}");
        match instruction {
            // div
            0 => regs[A] /= 1 << combo,
            1 => regs[B] ^= literal,
            2 => regs[B] = combo & 0x7,
            3 => if regs[A] == 0 { () } else {
                instructions = program[(literal as usize)..].iter()
            },
            4 => regs[B] ^= regs[C],
            5 => out.push(combo & 0x7),
            6 => regs[B] = regs[A] / (1 << combo),
            7 => regs[C] = regs[A] / (1 << combo),
            _ => panic!("Unknown instruction"),
        }
    }
}

fn main() -> Result<(), Box<dyn Error>> {

    let mut a = 59397658;
    let mut regs = [a, 0, 0];
    let program: Vec<u8> = "2,4,1,1,7,5,4,6,1,4,0,3,5,5,3,0,".bytes().step_by(2).map(|n| n - b'0').collect();
    let mut out = vec![];
    solve(&mut regs, &mut out, &program, a);
    println!("first half: {:?}", out);

    // The second half output follows a pattern that it's useful to find the solution
    // Firstly, we only want outputs that has the same size of the program
    // and so, i printed the very first output to have a new size
    // these values of 'A' have a specific format, at least for my input:
    //      a: 0 -> [5]
    //      a: 8 -> [1, 5]
    //      a: 64 -> [5, 1, 5]
    //      a: 512 -> [5, 5, 1, 5]
    //      a: 4096 -> [5, 5, 5, 1, 5]
    //      a: 32768 -> [5, 5, 5, 5, 1, 5]
    //      a: 262144 -> [5, 5, 5, 5, 5, 1, 5]
    //      a: 2097152 -> [5, 5, 5, 5, 5, 5, 1, 5]
    //      ...
    //
    //  These numbers are our old friends powers of 2: (8 = 2^3, 64 = 2^6, ...),
    //  therefore our 'a' should be at least 2^(i*3), where i is the program.len() - 1.
    //     a: 59397658 -> [5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5]. Has the same len of program? true
    //
    //  With a start point we can analyze how the values behave for a increasing 'a':
    //
    //      a: 35184372088832 -> [5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5].
    //      a: 35184372088832 -> [2, 1, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5].
    //      a: 35184372088832 -> [1, 5, 6, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5].
    //      a: 35184372088832 -> [3, 5, 5, 7, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5].
    //
    //  The number at left change faster than the ones at right, but how do they change?
    //  Let's print the output for every solution that changes some index with value 5 for the first time
    //  and we will also calculate the difference between these values
    //
    //      [7, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5]
    //      diff since the previous a -> 2
    //      [5, 7, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5]
    //      diff since the previous a -> 14
    //      [5, 5, 7, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5]
    //      diff since the previous a -> 112
    //      [5, 5, 5, 7, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5]
    //      diff since the previous a -> 896
    //      [5, 5, 5, 5, 7, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5]
    //      diff since the previous a -> 7168
    //      [5, 5, 5, 5, 5, 7, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5]
    //      diff since the previous a -> 57344
    //      [5, 5, 5, 5, 5, 5, 7, 5, 5, 5, 5, 5, 5, 5, 1, 5]
    //      diff since the previous a -> 458752
    //      [5, 5, 5, 5, 5, 5, 5, 7, 5, 5, 5, 5, 5, 5, 1, 5]
    //      diff since the previous a -> 3670016
    //      ...
    //
    //  The 'diff' above is calculated between the value for the 'a' register
    //  that changed the previous 5 and the current value of 'a', when
    //  we change some 5, to change the next we need to increase 'a' by
    //  that 'diff' (the first diff is between the first index change and
    //  the first 'a' that has the same len of program)
    //
    //  And they follow a rule too, the next diff is always 2**(i*3 + 1) * 7, for each i
    //  starting from 0 at the second diff (so the first diff needs to be added after).
    //
    //  With all this, we know that after the value 2^((program.len()-1)*3) + 2 + 14
    //  the second index of 'out' will start to change, let's print some outputs for 'a'.
    //
    //  for loop starting from the value above -1, to see the first change:
    //      0: [2, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5]
    //      1: [5, 7, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5]
    //      2: [5, 7, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5]
    //      3: [5, 7, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5]
    //      4: [2, 7, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5]
    //      5: [1, 7, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5]
    //      6: [1, 7, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5]
    //      7: [3, 7, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5]
    //      8: [2, 7, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5]
    //      9: [1, 6, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5]
    //      10: [5, 6, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5]
    //      11: [4, 6, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5]
    //      12: [0, 6, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5]
    //      13: [1, 6, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5]
    //      14: [1, 6, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5]
    //      15: [3, 6, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5]
    //      16: [2, 6, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5]
    //      17: [5, 1, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5]
    //      ...
    //
    //  After the first change, that needed the first value with len equals to program
    //  to be increased with 14+2, the second index starts to increase periodically every time we
    //  increase 8 to 'a'. And the same occurs to the other indexes, but multipling this period by 2^3 each time.
    //      - For the third index every change occurs with 2^3 * 2^3 = 64.
    //      - For the fourth index every change occurs with 2^3 * 2^3 * 2^3 = 512.
    //      ... (You can print it if you do not believe me.)
    //
    //  This means that, we need 2**(i*3) to some index i change its value.
    //
    //  With all this we came to our final expression( at coding we will use '1 <<' instead of power(^) ):
    //      starting a => a = (1 << len(program)-1 * 3) + 2 + 7 * sum((1 << i*3 + 1) for i in 0..len(program)-1)
    //      to change index x => a += (1 << x*3)

    a = (1 << (program.len()-1)*3)
        + 2
        + 7 * (0..program.len()-1).map(|i| 1 << (i*3 + 1)).sum::<u128>();

    'inf_loop: loop {
        solve(&mut regs, &mut out, &program, a);
        for i in (0..program.len()).rev() {
            if out[i] != program[i] as u128 {
                a += 1 << (i*3);
                continue 'inf_loop
            }
        }
        break
    }
    println!("second half A: {a}");
    solve(&mut regs, &mut out, &program, a);
    println!("{out:?}\n{program:?}");

    Ok(())
}
