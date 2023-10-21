const std = @import("std");
const mem = std.mem;
const file = @embedFile("entry.txt");

fn getPos(name: []const u8) u16 {
    if(name.len == 1) return 676 + @as(u16, @intCast(name[0] - 'a'))
    else return @as(u16, @intCast(name[0] - 'a')) + 26*@as(u16, @intCast(name[1] - 'a'));
}

pub fn main() !void {

    //plus 26 for just one chars
    var map: [26*26+26]u16 = undefined;
    @memset(map[0..], 0);

    var split = mem.tokenizeScalar(u8, file, '\n');
    var words: @TypeOf(split) = undefined;

    // const operations = ;
    const Ops = enum(u3) {
        And, Or, Not, Lshift, Rshift, JustStore
    };

    var currValues: [2]u16 = [_]u16{ 0, 0 };
    var currIndex: usize = undefined;
    var currOp: Ops = undefined;
    var currDest: u16 = undefined;

    while(split.next()) |line| {
        words = mem.tokenizeScalar(u8, line, ' ');
        @memset(currValues[0..], 0);
        currIndex = 0;
        currOp = .JustStore;

        words_for__ : while(words.next()) |word| {
            if(mem.eql(u8, "->", word)) {
                currDest = getPos((words.next() orelse continue)[0..]);
                break;
            }
            inline for([_][]const u8 {"AND", "OR", "NOT", "LSHIFT", "RSHIFT"}, 0..) |str, i| {
                if(mem.eql(u8, str[0..], word[0..])) {
                    currOp = @enumFromInt(i);
                    continue : words_for__;
                }
            }
            currValues[currIndex] = std.fmt.parseInt(u16, word, 10) catch parse_error__ : {
                break : parse_error__ map[getPos(word)];
            };
            currIndex += 1;
        }
        // std.debug.print("{any}\n", .{currValues});
        // std.debug.print("{any}\n", .{currOp});
        // std.debug.print("{any}\n", .{currDest});

        switch (currOp) {
            .And => {
                map[currDest] = (currValues[0] & currValues[1]);
            },
            .Or => {
                // std.debug.print("{}\n", .{(currValues[0] | currValues[1])});
                map[currDest] = (currValues[0] | currValues[1]);
            },
            .Not => {
                map[currDest] = (~currValues[0]);
            },
            .Lshift => {
                map[currDest] = (currValues[0] << @intCast(currValues[1]));
            },
            .Rshift => {
                map[currDest] = (currValues[0] >> @intCast(currValues[1]));
            },
            .JustStore => {
                map[currDest] = currValues[0];
            }
        }
    }
    std.debug.print("{}\n", .{map[getPos("a")]});
}

test "array of strings" {

    const oi: []const u8 = "sla";
    std.debug.print("{s}\n", .{@typeName(@TypeOf(oi))});
}
