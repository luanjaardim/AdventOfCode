const std = @import("std");
const print = std.debug.print;
const file  = @embedFile("entry.txt");

//this function update the sum by a reference and returns the new index that the parent function must continue
fn secondProblem(f : []const u8, start : usize, beginChar : u8, sum : *isize) !usize {
    var i : usize = start;
    var begin : usize = 0;
    var end : usize = 0;
    var hasRed : bool = false;
    var localSum : isize = 0;
    while(i < f.len) : (i += 1) {
        //find red
        if(i + 2 < f.len and f[i] == 'r' and f[i+1]  == 'e' and f[i+2] == 'd') {
            hasRed = true;
            i += 2;
        }
        switch(f[i]) {
            '{' => {
                //start a recursion to the inner bracket
                i = try secondProblem(f, i+1, '{', &localSum);
            },
            '[' => {
                //start a recursion to the inner bracket
                i = try secondProblem(f, i+1, '[', &localSum);
            },
            '}' => {
                if(beginChar == '{') {
                    sum.* += if(hasRed) 0 else localSum;
                    return i; //we don't need to add 1 here, because when it returns the call the while will add one to i
                }
            },
            ']' => {
                if(beginChar == '[') {
                    sum.* += localSum;
                    return i; //we don't need to add 1 here, because when it returns the call the while will add one to i
                }
            },
            else => {
                //sum numbers to localSum
                if((f[i] >= '0' and f[i] <= '9') or f[i] == '-') {
                    begin = i;
                    i += 1;
                    while(i < f.len and f[i] >= '0' and f[i] <= '9') : (i += 1) {}
                    end = i;
                    i-=1;
                    localSum += try std.fmt.parseInt(isize, f[begin..end], 10);
                }
            }
        }

    }
    if(beginChar != ' ') return error.Algo_deu_merda;
    sum.* += localSum;
    return 0;
}

pub fn main() !void {
    var i : usize = 0;
    var begin : usize = 0;
    var end : usize = 0;
    var sum : isize = 0;
    //first half code
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
    print("First problem solution: {}\n", .{sum});

    sum = 0;
    //second half code
    _ = try secondProblem(file[0..file.len], 0, ' ', &sum);
    print("Second problem solution: {}\n", .{sum});
}
