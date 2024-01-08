const std = @import("std");
const print = std.debug.print;

const file = @embedFile("entry.txt");

pub fn main() !void {
    //this is used for increase the number of operations the compiler makes to eval comptime blocks, default = 1000
    //passing the length of the file i can make the compiler execute this 'for' entirely at compile time!
    @setEvalBranchQuota(file.len);
    const s = comptime compBlock: {
        comptime var size: [4]usize = .{0, 0, 0, 0};
        inline for(file) |c| {
            switch (c) {
                '>' => size[0] += 1,
                '<' => size[1] += 1,
                '^' => size[2] += 1,
                'v' => size[3] += 1,
                else => {}
            }
        }
        break :compBlock size;
    }; //with all that calculated, i know how to declare a static matrix that can fit all possible moves of santa!

    //at compile time we discovered the min size of the matrix that
    //santa will be inside, even if all the equal moves of the file are in order
    var matHouses: [s[2]+s[3]+1][s[0]+s[1]+1]u1 = undefined;
    //zig can handle numbers with arbritary width
    //does not means it will only use 1 bit to store it's value, the size is one byte.

    //initializing it with zeros, we need & to get it's elements as pointers
    for(&matHouses) |*streets| {
        @memset(streets.*[0..], @as(u1, 0));
    }

    // first_problem(@TypeOf(matHouses), &matHouses, s[2], s[1]);
    second_problem(@TypeOf(matHouses), &matHouses, s[2], s[1]);
}

pub fn first_problem(comptime T: type, matHouses: *T, initial_x: usize, initial_y: usize) void {
    var housesWithPresents: usize = 1;
    var x: usize = initial_x;  //santa position x
    var y: usize = initial_y;  //santa position y
    var mat = matHouses;
    mat[x][y] = 1;

    for(file) |c| {
        switch (c) {
            '>' => y += 1,
            '<' => y -= 1,
            '^' => x -= 1,
            'v' => x += 1,
            else => continue,
        }
        if(mat[x][y] == @as(u1, 1)) continue; //if visited, it's a house that already has present
        mat[x][y] = @as(u1, 1);
        housesWithPresents += 1;
    }
    print("{}\n", .{housesWithPresents});
}

pub fn second_problem(comptime T: type, matHouses: *T, initial_x: usize, initial_y: usize) void {
    var housesWithPresents: usize = 1;
    var x: usize = initial_x;  //santa position x
    var y: usize = initial_y;  //santa position y
    var rx: usize = initial_x; //robot position x
    var ry: usize = initial_y; //robot position x

    const santaOrRobot = enum{
    //who is the turn to move?
        santa,
        robot,
    };
    var whoIsDelivering: santaOrRobot = .robot; //initializing with robot because it will change inside the 'for'
    var mat = matHouses;
    mat[x][y] = 1;

    for(file) |c| {
        whoIsDelivering = if(whoIsDelivering == .santa) .robot else .santa;
        switch (c) {
            '>' => {if(whoIsDelivering == .santa) y += 1 else ry += 1;},
            '<' => {if(whoIsDelivering == .santa) y -= 1 else ry -= 1;},
            '^' => {if(whoIsDelivering == .santa) x -= 1 else rx -= 1;},
            'v' => {if(whoIsDelivering == .santa) x += 1 else rx += 1;},
            else => {
                //if wasn't a move, change don't change the one delivering
                whoIsDelivering = if(whoIsDelivering == .santa) .robot else .santa;
                continue;
            }
        }
        if(whoIsDelivering == .santa) {
            if(mat[x][y] == @as(u1, 1)) continue;
            mat[x][y] = @as(u1, 1);
            housesWithPresents += 1;
        }
        else {
            if(mat[rx][ry] == @as(u1, 1)) continue;
            mat[rx][ry] = @as(u1, 1);
            housesWithPresents += 1;
        }
    }
    print("{}\n", .{housesWithPresents});
}

test "testArrayList" {
    const Listi32 = std.ArrayList(i32);
    const Matrix = std.ArrayList(Listi32);
    var vec = Listi32.init(std.testing.allocator);
    // defer vec.deinit(); //vec will be appended to mat and then deallocated later

    try vec.append(1);
    try vec.append(2);
    try vec.append(3);
    try vec.append(4);
    try vec.append(5);

    for(vec.items) |i| {
        print("{}\n", .{i});
    }

    //another way that involves change the owner of the memmory
    // {
    //     const slice = try vec.toOwnedSlice();
    //     //returning the owned memory to vec to use the defer to deallocate
    //     defer vec = Listi32.fromOwnedSlice(vec.allocator, slice);

    //     for(slice) |num| {
    //         print("{}\n", .{num});
    //     }
    // }

    var mat = try Matrix.initCapacity(std.testing.allocator, 128);
    defer {
        //free of the matrix elements
        for(mat.items) |item| {
            item.deinit();
        }
        //freee of the matrix
        mat.deinit();
    }
    try mat.append(vec);
    try mat.append(try Listi32.initCapacity(std.testing.allocator, 8));
    try mat.append(try Listi32.initCapacity(std.testing.allocator, 8));
    try mat.append(try Listi32.initCapacity(std.testing.allocator, 8));

    var oi = @as(Listi32, mat.items[2]);
    try mat.items[2].append(10);
    try oi.append(5); //oi will override the value appended by mat.items[2], as have the same alocated address
    for(mat.items[2].items) |num| {
        print("{}\n", .{num});
    }
    for(oi.items) |num| {
        print("{}\n", .{num});
    }
}
