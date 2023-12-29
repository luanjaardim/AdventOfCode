const std = @import("std");
const print = std.debug.print;
const file  = @embedFile("entry.txt");

pub fn main() !void {
    var begin : usize = 0;
    var end : usize = 0;
    var i : usize = 0;
    var sum : isize = 0;
    while(i < file.len) : (i += 1) {
        const c = file[i];
        if((c >= '0' and c <= '9') or c == '-') {
            begin = i;
            i += 1;
            while(i < file.len and file[i] >= '0' and file[i] <= '9') : (i += 1) {}
            end = i;
            sum += try std.fmt.parseInt(isize, file[begin..end], 10);
        }
    }
    print("Sum: {}\n", .{sum});
}
