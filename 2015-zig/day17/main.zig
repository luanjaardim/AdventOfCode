const std = @import("std");
const print = std.debug.print;
const file = @embedFile("entry.txt");

pub fn main() !void {

    var containers = std.ArrayList(usize).init(std.heap.page_allocator);
    defer containers.deinit();

    var numbers = std.mem.tokenizeScalar(u8, file, '\n');
    while(numbers.next()) |num| {
        try containers.append(try std.fmt.parseInt(usize, num, 10));
    }
    var total : usize = 0;
    var qtdMinUse : usize = 0;
    var minUse : usize = std.math.maxInt(usize);

    for(1..@as(u32, 1) << @as(u5, @intCast(containers.items.len))) |num| {
        //iteration is the number that will be used to select a set of containers
        //it's values are from 1 to 2^(qtd containers), every bit of the number represents
        //if the ith container will be added or not
        var iteration : usize = num;
        var i : usize = 0; //stores the index of the container to add
        var j : usize = 0; //counts the number of containers that were used
        var curSum : usize = 0;
        while(iteration != 0) {
            //gets the less significant bit
            if(iteration & 1 != 0) {
                //if the ith bit is one and this container
                curSum += containers.items[i];
                j += 1;
            }
            //discarts the first bit and gets the next
            iteration >>= 1;
            i += 1;
        }

        //if the sum reached the 150 cost add one to the total and check if the
        //quantity of containers is fewer than the previous(and if equal add one)
        if(curSum == 150) {
            total += 1;
            if(j < minUse) {
                minUse = j;
                qtdMinUse = 1;
            } else if(j == minUse) {
                qtdMinUse += 1;
            }
        }
    }
    print("Part 1: {}\n", .{total});
    print("Part 2: {}\n", .{qtdMinUse});
}
