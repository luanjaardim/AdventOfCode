const std = @import("std");
const print = std.debug.print;
const file = @embedFile("entry.txt");
const matSize = 100;

const Pair = struct {
    x : isize,
    y : isize,
};

fn solve(doubleMat : [2][matSize][matSize]bool, isSecond : bool) usize {
    var m = doubleMat;
    const turns = 100;
    var matInWork : usize = 0;
    var matToUpdate : usize = 0;

    for(0..turns) |turn|{
        matInWork = turn & 1;
        matToUpdate = (~turn) & 1;
        const m1 = &m[matInWork];
        const m2 = &m[matToUpdate];

        for(0..matSize) |i| {
            for(0..matSize) |j| {

                var pos : usize = 0;
                var count: usize = 0;
                while(pos < 9) : (pos += 1) {
                    //(pos / 3) and (pos % 3) can only be 0, 1 or 2, so x and y can only be -1, 0 or 1 plus the current position
                    const x : isize = @as(isize, @intCast(i)) - @as(isize, @intCast(pos / 3)) + 1;
                    const y : isize = @as(isize, @intCast(j)) - @as(isize, @intCast(pos % 3)) + 1;
                    count += matAt(m1, .{.x = x, .y = y});
                }
                if(m1[i][j]) {
                    count -= 1;
                    //this if is to avoid updating the corners of the matrix at second half of the problem
                    if(!(isSecond and (i == 0 or i == matSize-1) and (j == 0 or j == matSize-1))) {
                        m2[i][j] = if(count == 2 or count == 3) true else false;
                    }
                } else {
                    //this if is to avoid updating the corners of the matrix at second half of the problem
                    if(!(isSecond and (i == 0 or i == matSize-1) and (j == 0 or j == matSize-1))) {
                        m2[i][j] = if(count == 3) true else false;
                    }
                }
            }
        }
    }
    var totalOn : usize = 0;
    for(m[matToUpdate]) |row| {
        for(row) |c| {
            // if(c) print("#", .{}) else print(".", .{});
            if(c) totalOn += 1;
        }
        // print("\n", .{});
    }
    // print("\n", .{});
    return totalOn;
}

fn matAt(m : *[matSize][matSize]bool, pos : Pair) usize {
    if(pos.x < 0 or pos.x > matSize-1 or pos.y < 0 or pos.y > matSize-1) {
        return 0;
    }
    else {
        return if(m[@as(usize, @intCast(pos.x))][@as(usize, @intCast(pos.y))]) 1 else 0;
    }
}

pub fn main() !void {

    //contains a matrix with the current state the matrix to update the state to the next iteration
    var doubleMat = [_][matSize][matSize]bool {[_][matSize]bool{ [_]bool{false} **  matSize} ** matSize} ** 2;
    var iter = std.mem.tokenizeScalar(u8, file, '\n');

    var l : usize = 0;
    while(iter.next()) |line| {
        for(line, 0..) |c, j| {
            if(c == '.') doubleMat[0][l][j] = false else if(c == '#') doubleMat[0][l][j] = true;
        }
        l += 1;
    }

    print("total on first half: {}\n", .{solve(doubleMat, false)});

    for(0..2) |i| {
        doubleMat[i][0][0]                 = true;
        doubleMat[i][matSize-1][0]         = true;
        doubleMat[i][0][matSize-1]         = true;
        doubleMat[i][matSize-1][matSize-1] = true;
    }
    print("total on second half: {}\n", .{solve(doubleMat, true)});
}
