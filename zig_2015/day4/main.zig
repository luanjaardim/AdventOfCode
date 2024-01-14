const std = @import("std");
const print = std.debug.print;

const Problem = enum{
    first,
    second
};

pub fn main() !void {
    // const problem: Problem = .first;
    const problem: Problem = .second;
    const end = if(problem == .first) 5 else 6;

    var arena_alok = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_alok.deinit();

    const alok = arena_alok.allocator();

    //getting the input from the stdin, passing by command line with '< entry.txt'
    const input  = try std.io.getStdIn().reader().readAllAlloc(alok, 32);

    var numStr: []u8 = undefined;
    var outStr: []u8 = undefined;
    var out: [std.crypto.hash.Md5.digest_length]u8 = undefined;
    var num: usize = undefined;

    out_for: for(0..std.math.maxInt(usize)) |i| {
        print("{d}\n", .{i});
        //formatting a string to use on hash
        numStr = try std.fmt.allocPrint(alok, "{s}{d}", .{input[0..input.len-1], i});

        //using the zig std Md5 hash function
        std.crypto.hash.Md5.hash(numStr, &out, .{});
        //getting the result in hex
        outStr = try std.fmt.allocPrint(alok, "{X}", .{std.fmt.fmtSliceHexUpper(out[0..])});

        //if anyone is not equal to '0', we try again, brute force, yay!
        for(outStr[0..end]) |digit| { if(digit != '0') continue :out_for; }
        num = i;
        break;
    }

    print("{s}\n", .{outStr});
    print("num: {d}\n", .{num});
}

test "pos mem leak" {

    var arena_alok = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_alok.deinit();

    const alok = arena_alok.allocator();

    const input  = try std.io.getStdIn().reader().readAllAlloc(alok, 32);
    var numStr: []u8 = undefined;
    var out: [std.crypto.hash.Md5.digest_length]u8 = undefined;
    var outStr: []u8 = undefined;
    var num: usize = undefined;

    out_for: for(0..std.math.maxInt(usize)) |i| {
        print("{d}\n", .{i});
        numStr = try std.fmt.allocPrint(alok, "{s}{d}", .{input[0..input.len-1], i});
        std.crypto.hash.Md5.hash(numStr, &out, .{});
        outStr = try std.fmt.allocPrint(alok, "{X}", .{std.fmt.fmtSliceHexUpper(out[0..])});

        for(outStr[0..5]) |digit| { if(digit != '0') continue :out_for; }
        num = i;
        break;
    }

    print("num: {d}\n", .{num});

}
