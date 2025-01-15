use std::error::Error;

const IS_PART_TWO: bool = true;
const PART_TWO_ERROR: isize = 10_000_000_000_000;

#[derive(Debug)]
struct Equation {
    ax: isize,
    bx: isize,
    ay: isize,
    by: isize,
    x: isize,
    y: isize,
}
impl Equation {
    fn new() -> Self {
        Equation {
            ax: 0, bx: 0, ay: 0, by: 0, x: 0, y: 0,
        }
    }
}

fn main() -> Result<(), Box<dyn Error>> {

    let s = std::fs::read_to_string("src/entry.txt").unwrap();

    let mut equations: Vec<Equation> = Vec::new();
    for l in s.lines() {
        let line = l.trim();
        if line.contains('A') || line.contains('B') {
            let mut it = line.split('+');
            it.next();
            if line.contains('A') {
                equations.push(Equation::new());
                let ax_str = it.next().unwrap();
                equations.last_mut().unwrap().ax = ax_str[..ax_str.find(',').unwrap()].parse()?;
                equations.last_mut().unwrap().ay = it.next().unwrap().trim().parse()?;
            } else {
                let bx_str = it.next().unwrap();
                equations.last_mut().unwrap().bx = bx_str[..bx_str.find(',').unwrap()].parse()?;
                equations.last_mut().unwrap().by = it.next().unwrap().trim().parse()?;
            }
        } else if line.contains("Prize") {
            let mut it = line.split('=');
            it.next();
            let x_str = it.next().unwrap();
            equations.last_mut().unwrap().x = x_str[..x_str.find(',').unwrap()].parse()?;
            equations.last_mut().unwrap().y = it.next().unwrap().trim().parse()?;
            if IS_PART_TWO {
                let e = equations.last_mut().unwrap();
                e.x += PART_TWO_ERROR;
                e.y += PART_TWO_ERROR;
            }
        }
    }

    let mut cnt = 0;
    for eq in &equations {
        // number of times the B button is clicked
        let m = (eq.y * eq.ax - eq.x * eq.ay) / (eq.ax * eq.by - eq.bx * eq.ay);
        // number of times the A button is clicked
        let n = (eq.x - eq.bx * m) / eq.ax;
        if n*eq.ax + m*eq.bx == eq.x && n*eq.ay + m*eq.by == eq.y {
            cnt += 3*n + m;
        }
    }

    println!("{}", cnt);

    Ok(())
}
