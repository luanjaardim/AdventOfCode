const std = @import("std");
const print = std.debug.print;
const size = 6100;
const mul  = 252533;
const mod  = 33554393;
const initialMatrix = [6][6]usize {
    .{20151125,  18749137,  17289845,  30943339,  10071777,  33511524},
    .{31916031,  21629792,  16929656,   7726640,  15514188,   4041754},
    .{16080970,   8057251,   1601130,   7981243,  11661866,  16474243},
    .{24592653,  32451966,  21345942,   9380097,  10600672,  31527494},
    .{   77061,  17552253,  28094349,   6899651,   9250759,  31663883},
    .{33071741,   6796745,  25397450,  24659492,   1534922,  27995004}
};

const Pair = struct {
    x: usize,
    y: usize,
};
const input = Pair{.x = 2981, .y = 3075};

pub fn main() !void {

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alok = arena.allocator();

    const inf = std.math.maxInt(usize); //any value to fill the matrix
    var m = try alok.alloc([]usize, size);
    for(0..m.len) |i| {
        m[i] = try alok.alloc(usize, size);
        @memset(m[i], inf);
    }

    //filling with the initial matrix
    for(initialMatrix, 0..) |l, i| {
        for(l, 0..) |e, j| {
            m[i][j] = e;
        }
    }

    var i : usize = 0;
    var j : usize = 0;
    var next_i : usize = 0;
    var next_j : usize = 0;
    //calculating intermediate values till the input is solved
    while(i != input.x - 1 or j != input.y - 1) {
        if(i == 0) {
            next_i = j + 1;
            next_j = 0;
        } else {
            next_i = i - 1;
            next_j = j + 1;
        }
        m[next_i][next_j] = m[i][j] * mul;
        m[next_i][next_j] %= mod;
        i = next_i;
        j = next_j;
    }
    print("Part 1: {}\n", .{m[i][j]});
    print("Thank you for everything!! See you on 2016. (im talking with myself)\n", .{});
}
