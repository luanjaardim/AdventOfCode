const std = @import("std");
const m = std.mem;
const print = std.debug.print;

//opening the content of a file at compile time
const file = @embedFile("entry.txt");

pub fn main() !void {
    // try base_fn(first_problem);
    try base_fn(second_problem);
}

//base_fn receives a function pointer to first or second problem, and then execute it
fn base_fn(problem: *const fn (@Vector(3, usize)) usize) !void {
    var paper_qt: usize = 0;

    //split the file on x or \n chars, returns a iterator over the slices
    var sides = m.tokenizeAny(u8, file[0..file.len - 1], "x\n");

    var aux: usize = 0;
    var areas: @Vector(3, usize) = [_]usize{0, 0, 0}; //l, w, h

    //iterating over with while, when next return null, end the loop
    while(sides.next()) |side| {
        //convert the slice on a Number, in this case we don't need the signal
        const sideAsNumber = try std.fmt.parseUnsigned(usize, side, 10);
        areas[aux] = sideAsNumber;

        //when we have all the dimensions, we calculate the paper used
        if(aux == 2) {
            //calling the calculation of the first or second problem
            paper_qt += problem(areas);
        }
        aux = (aux+1)%3;
    }
    print("{}\n", .{paper_qt});
}

fn first_problem(in_vec: @Vector(3, usize)) usize {
    //shuffle to left rotate the vector, another SIMD function could be used to do this
    var vec = @shuffle(usize, in_vec, undefined, @Vector(3, i32){1, 2, 0});
    //calculating all possible areas -> l*w, w*h, h*l
    vec = in_vec * vec;

    //sum to double and then reduce with Add to get the sum of all sides area
    // areas + areas => 2*l*w, 2*w*h, 2*h*l
    // reduce(2*l*w, 2*w*h, 2*h*l) => 2*l*w + 2*w*h + 2*h*l
    //and at the final we sum with the smallest area
    return @reduce(.Add, vec + vec) + @min(vec[0], @min(vec[1], vec[2]));
}

fn second_problem(in_vec: @Vector(3, usize)) usize {
    //storing the double of each dimension, so the smallest perimeter will
    // be the add reduce of all doubled dimensions minus the double of the greatest
    // vec => 2l, 2w, 2h; smallest perimeter => 2l + 2w + 2h - max(2l, 2w, 2h)
    var vec = in_vec + in_vec;

    return @reduce(.Mul, in_vec) //reducing with .Mul to get the volume
           + @reduce(.Add, vec)  //summ all doubled dimensions
           - @max(@max(vec[0], vec[1]), vec[2]); //removing the double of the greatest
}

test "vector" {
    const V: @Vector(100, usize) = @splat(1);
    const sla = @reduce(.Add, V);
    print("{}\n", .{sla});
    var v: @Vector(5, usize) = [_]usize{1, 2, 3, 4, 5};
    const new_v = @shuffle(usize, v, undefined, @Vector(5, i32){ 1, 2, 3, 4, 0});
    print("{}\n", .{new_v});

}
