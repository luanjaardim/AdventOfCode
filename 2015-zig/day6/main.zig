const std = @import("std");
const file = @embedFile("entry.txt");
const mem = std.mem;

pub fn main() !void {

    const first_problem = false;
    const second_problem = true;

    @setEvalBranchQuota(1001);
    var mat: [1000][1000]u8 = comptime mat__: {
        var innerMat: [1000][1000]u8 = undefined;
        for(&innerMat) |*line| {
            @memset(line[0..], 0);
        }
        break :mat__ innerMat;
    };
    var qtdOn: usize = 0;   //answer first_problem
    var levelOn: usize = 0; //answer second_problem

    const actionToExec = enum {
        setOn,
        setOff,
        Toggle
    };
    var currAction: actionToExec = undefined;

    var split = mem.tokenizeScalar(u8, file, '\n');
    var lineSplit: @TypeOf(split) = undefined;
    var numberSplit: @TypeOf(split) = undefined;
    var word: []const u8  = undefined;
    var x1: usize = 0;
    var y1: usize = 0;
    var x2: usize = 0;
    var y2: usize = 0;

    while(split.next()) |line| {

        //spliting by the whitespace between words
        lineSplit = mem.tokenizeScalar(u8, line, ' ');

        //if null just continue the loop, in our case that won't happen
        word = lineSplit.next() orelse continue;
        //check for the command
        if(mem.eql(u8, word[0..], "turn")) {
            word = lineSplit.next() orelse continue;
            if(mem.eql(u8, word[0..], "on")) currAction = .setOn else currAction = .setOff;
        }
        else currAction = .Toggle;

        //parsing the numbers of the command
        word = lineSplit.next() orelse continue;
        numberSplit = mem.tokenizeScalar(u8, word, ',');
        x1 = try std.fmt.parseInt(usize, numberSplit.next() orelse continue, 10);
        y1 = try std.fmt.parseInt(usize, numberSplit.next() orelse continue, 10);
        _ = lineSplit.next(); //useless word "through"
        word = lineSplit.next() orelse continue;
        numberSplit = mem.tokenizeScalar(u8, word, ',');
        x2 = try std.fmt.parseInt(usize, numberSplit.next() orelse continue, 10);
        y2 = try std.fmt.parseInt(usize, numberSplit.next() orelse continue, 10);

        //matrix changes for the first problem
        if(first_problem == true) {
            switch(currAction) {
                .setOn => {
                for(x1..x2+1) |i| {
                    for(y1..y2+1) |j| {
                        //if it was already on, doesn't count
                        if(mat[i][j] == 0) {
                            qtdOn+=1;
                            mat[i][j] = 1;
                        }
                }
                }},
                .setOff => {
                for(x1..x2+1) |i| {
                    for(y1..y2+1) |j| {
                        //if it was already off, doesn't count
                        if(mat[i][j] == 1) {
                            qtdOn-=1;
                            mat[i][j] = 0;
                        }
                }
                }},
                .Toggle => {
                for(x1..x2+1) |i| {
                    for(y1..y2+1) |j| {
                        if(mat[i][j] == 1) {
                            qtdOn-=1;
                            mat[i][j] = 0;
                        } else {
                            qtdOn+=1;
                            mat[i][j] = 1;
                        }
                }

                }}
            }
        }
        //matrix changes for the second problem
        if(second_problem == true) {
            switch(currAction) {
                .setOn => {
                for(x1..x2+1) |i| {
                    for(y1..y2+1) |j| {
                        levelOn += 1;
                        mat[i][j] += 1;
                }
                }},
                .setOff => {
                for(x1..x2+1) |i| {
                    for(y1..y2+1) |j| {
                        if(mat[i][j] > 0) {
                            levelOn -= 1;
                            mat[i][j] -= 1;
                        }
                }
                }},
                .Toggle => {
                for(x1..x2+1) |i| {
                    for(y1..y2+1) |j| {
                        levelOn += 2;
                        mat[i][j] += 2;
                }

                }}
            }
        }
    }
    if(first_problem) std.debug.print("{}\n", .{qtdOn});
    if(second_problem) std.debug.print("{}\n", .{levelOn});
}
