const std = @import("std");
const print = std.debug.print;
const fs = std.fs;

pub fn main() !void {
    // try first_problem();
    try second_problem();
}

pub fn readFile(alok: std.mem.Allocator) ![]u8 {
    const file = try fs.cwd().openFile("entry.txt", .{}); //open a file
    defer file.close(); //close the file at end of the scope


    //getting the size of the file to alloc a buffer for it
    const file_size = (try file.stat()).size;
    return try file.readToEndAlloc(alok, file_size);
}

pub fn first_problem() !void {

    var alok_arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer alok_arena.deinit(); //free the memory at the end of the scope
    const buffer = try readFile(alok_arena.allocator());

    var level: isize = 0;
    for(buffer) |c| {  //iterating over buffer
        level += switch (c) {
            '(' => 1,
            ')' => -1,
            else => 0,
        };
    }
    print("{d}\n", .{level});
}

pub fn second_problem() !void {

    var alok_arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer alok_arena.deinit(); //free the memory at the end of the scope
    const buffer = try readFile(alok_arena.allocator());

    var level: isize = 0;
    //pos is initialized with return of a scope, we can return a value to it
    //by giving it a name, a label, to call it when we break
    const pos = ret_pos: {
        //this for iterates over buffer and over a range starting from 1
        for(buffer, 1..) |c, pos| {
        level += switch (c) {
            '(' => 1,
            ')' => -1,
            else => 0,
        };
        if(level == -1)
            break :ret_pos pos;
        }
        break :ret_pos 0;
    };
    print("{d}\n", .{pos});
}

test "mem leak" {
    var alok_arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer alok_arena.deinit(); //free the memory at the end of the scope
    //if we comment out the line above we get a error on the test

    const buffer = try readFile(alok_arena.allocator());

    print("{d}\n", .{buffer.len});
}
