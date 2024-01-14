const std = @import("std");
const print = std.debug.print;
const file = @embedFile("entry.txt");

const literalCount = struct {
    codeCount : u64,
    dataCount : u64,
    encodedCount : u64, // for the second problem
    prevWasSlash : bool,
    prevWasHexa : bool,

    fn increaseAll(self : *literalCount) void {
        self.codeCount += 1;
        self.dataCount += 1;
        self.encodedCount += 1;
    }
};

pub fn main() !void {

    var count = literalCount{
        .codeCount = 0,
        .dataCount = 0,
        .encodedCount = 0,
        .prevWasSlash = false,
        .prevWasHexa = false,
    };

    var iter = std.mem.tokenizeScalar(u8, file, '\n');

    while(iter.next()) |line| {
        count.encodedCount += 2;
        var i : usize = 0;
        while(i < line.len) {
            if(count.prevWasSlash) {
                if(line[i] == 'x') {
                    count.prevWasHexa = true;
                } else {
                    if(line[i] == '\\' or line[i] == '"') {
                        count.encodedCount += 1;
                    }
                    count.dataCount += 1;
                    count.codeCount += 2;
                    count.encodedCount += 2;
                }
                count.prevWasSlash = false;
            } else if(count.prevWasHexa) {
                i += 1;
                count.prevWasHexa = false;
                count.dataCount += 1;
                count.codeCount += 4;
                count.encodedCount += 4;
            } else {
                if(line[i] == '\\') {
                    count.prevWasSlash = true;
                    count.encodedCount += 1;
                } else if(line[i] == '"') {
                    count.codeCount += 1;
                    count.encodedCount += 2;
                } else {
                    count.increaseAll();
                }
            }
            i += 1;
        }
    }
    print("code count: {}\n", .{count.codeCount});
    print("data count: {}\n", .{count.dataCount});
    print("encoded count: {}\n", .{count.encodedCount});
    print("subtraction first problem: {}\n", .{count.codeCount - count.dataCount});
    print("subtraction second problem: {}\n", .{count.encodedCount - count.codeCount});
}
