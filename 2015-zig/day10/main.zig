const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alok = arena.allocator();

    const input = "1113122113";
    var size : usize = input.len;
    //we will use two buffers, one will store the previous answer and the other will be used to fill the next answer
    //then we will keep alternating between them till the aswer is found
    var doubleList = [2][]u8{ try alok.alloc(u8, input.len * 2), try alok.alloc(u8, input.len * 2) };

    for (input, 0..) |c, i| {
        doubleList[0][i] = c;
    }
    for(0..50) |i| {
        //get the index of the buffer that is being used to fill the next answer
        const inWork = i & 1;
        const toFill = (~inWork) & 1;

        //this will store the index to write chars
        var k: usize = 0;
        //counts the repetition of the current char
        var count: usize = 0;
        //stores the previous char
        var prevElem: u8 = doubleList[inWork][0];
        for(0..size+1) |j| {
            const c = doubleList[inWork][j];
            if (c != prevElem) {
                //convert the int to string
                const buff = try std.fmt.allocPrint(alok, "{}", .{count});
                //if the buffer is not big enough, we need to reallocate it
                if (k + buff.len + 1 >= doubleList[toFill].len) {
                    doubleList[toFill] = try alok.realloc(doubleList[toFill], doubleList[toFill].len * 2);
                }
                for (buff) |char| {
                    doubleList[toFill][k] = char;
                    k += 1;
                }
                doubleList[toFill][k] = prevElem;
                k += 1;
                count = 1;
                prevElem = c;
            } else {
                count += 1;
            }
        }
        //update the size of the answer
        size = k;
        if (i == 39 or i == 49) {
            if(i == 39) {
                print("first answer {}\n", .{size});
            } else {
                print("second answer {}\n", .{size});
            }
        }
    }
}

test "test insertSlice" {
    print("\n", .{});
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const alok = arena.allocator();

    const input = "1113122113";
    var size : usize = input.len;
    var doubleList = [2][]u8{ try alok.alloc(u8, input.len * 2), try alok.alloc(u8, input.len * 2) };

    for (input, 0..) |c, i| {
        doubleList[0][i] = c;
    }
    for(0..50) |i| {
        const inWork = i & 1;
        const toFill = (~inWork) & 1;
        // print("{}: inWork: {}, toFill: {}\n", .{i, inWork, toFill});
        // print("{s}\n", .{doubleList[inWork][0..size]});
        var k: usize = 0;
        var count: usize = 0;
        var prevElem: u8 = doubleList[inWork][0];
        for(0..size+1) |j| {
            const c = doubleList[inWork][j];
            if (c != prevElem) {
                const buff = try std.fmt.allocPrint(alok, "{}", .{count});
                // print("ind: {}\n", .{k + buff.len + 2});
                if (k + buff.len + 2 >= doubleList[toFill].len) {
                    print("realloc\n", .{});
                    doubleList[toFill] = try alok.realloc(doubleList[toFill], doubleList[toFill].len * 2);
                }
                for (buff) |char| {
                    doubleList[toFill][k] = char;
                    k += 1;
                }
                doubleList[toFill][k] = prevElem;
                doubleList[toFill][k + 1] = 0;
                k += 1;
                count = 1;
                prevElem = c;
            } else {
                count += 1;
            }
        }
        // print("k: {}\n", .{k});
        size = k;
        // print("size: {}\n", .{size});
        print("i = {}\n", .{i});
        if (i == 39 or i == 49) {
            print("answer size {}, and the string {s}\n", .{size, "kk"});
        }
    }
}
