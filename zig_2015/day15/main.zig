const std = @import("std");
const print = std.debug.print;
const file = @embedFile("entry.txt");

const Ingredient = struct {
    capacity: isize,
    durability: isize,
    flavor: isize,
    texture: isize,
    calories: isize,
};

pub fn main() !void {

    var iter = std.mem.tokenizeScalar(u8, file, '\n');
    var ingredients = std.ArrayList(Ingredient).init(std.heap.page_allocator);
    defer ingredients.deinit();

    while(iter.next()) |line| {
        var words = std.mem.tokenizeAny(u8, line, " ,");

        _ = words.next(); // skip name
        _ = words.next(); // skip capacity
        const capacity = try std.fmt.parseInt(isize, words.next().?, 10);

        _ = words.next(); // skip durability
        const durability = try std.fmt.parseInt(isize, words.next().?, 10);

        _ = words.next(); // skip flavor
        const flavor = try std.fmt.parseInt(isize, words.next().?, 10);

        _ = words.next(); // skip texture
        const texture = try std.fmt.parseInt(isize, words.next().?, 10);

        _ = words.next(); // skip calories
        const calories = try std.fmt.parseInt(isize, words.next().?, 10);

        try ingredients.append(Ingredient {
            .capacity = capacity,
            .durability = durability,
            .flavor = flavor,
            .texture = texture,
            .calories = calories,
        });
    }

    //brute force solution, testing every possible combination
    var result1 : usize = 0; //result to the first half
    var result2 : usize = 0; //result to the second half
    for(0..100) |i| {
        for(0..100-i) |j| {
            for(0..100-i-j) |k| {
                const w = 100-i-j-k;
                //i, j, k and w are the quantities of the ingredients
                var cap : isize = 0;
                var dur : isize = 0;
                var fla : isize = 0;
                var tex : isize = 0;
                var cal : isize = 0;
                //stores the current configuration of the ingredients
                const configuration = [_]isize {@intCast(i), @intCast(j), @intCast(k), @intCast(w)};
                for(ingredients.items, 0..) |elem, ind| {
                    cap += elem.capacity   * configuration[ind];
                    dur += elem.durability * configuration[ind];
                    fla += elem.flavor     * configuration[ind];
                    tex += elem.texture    * configuration[ind];
                    cal += elem.calories   * configuration[ind];
                }
                const result = @max(0, cap) * @max(0, dur) * @max(0, fla) * @max(0, tex);
                result1 = @max(result1, result);
                if(cal == 500) {
                    result2 = @max(result2, result);
                }
            }
        }
    }
    print("result1: {d}\n", .{result1});
    print("result2: {d}\n", .{result2});
}

test "array list alloc" {

    var iter = std.mem.tokenizeScalar(u8, file, '\n');
    var ingredients = std.ArrayList(Ingredient).init(std.testing.allocator);
    defer ingredients.deinit();

    while(iter.next()) |line| {
        var words = std.mem.tokenizeAny(u8, line, " ,");

        _ = words.next(); // skip name
        _ = words.next(); // skip capacity
        const capacity = try std.fmt.parseInt(isize, words.next().?, 10);

        _ = words.next(); // skip durability
        const durability = try std.fmt.parseInt(isize, words.next().?, 10);

        _ = words.next(); // skip flavor
        const flavor = try std.fmt.parseInt(isize, words.next().?, 10);

        _ = words.next(); // skip texture
        const texture = try std.fmt.parseInt(isize, words.next().?, 10);

        _ = words.next(); // skip calories
        const calories = try std.fmt.parseInt(isize, words.next().?, 10);

        try ingredients.append(Ingredient {
            .capacity = capacity,
            .durability = durability,
            .flavor = flavor,
            .texture = texture,
            .calories = calories,
        });
    }
    for(ingredients.items) |i| {
        print("{any}\n", .{i});
    }
}
