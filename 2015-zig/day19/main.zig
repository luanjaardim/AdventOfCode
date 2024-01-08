const std = @import("std");
const print = std.debug.print;
const file = @embedFile("entry.txt");
const Map = std.StringHashMap(std.ArrayList([]const u8));
const mem = std.mem;
const end = 43;

pub fn main() !void {

    var map = Map.init(std.heap.page_allocator);
    defer map.deinit();

    var cnt : usize = 1;
    var iter = mem.tokenizeAny(u8, file, " \n");
    while(iter.next()) |word| {
        _ = iter.next(); //skip the "=>"

        const s = iter.next().?;
        const entry = try map.getOrPut(word);
        if(entry.found_existing) {
            try entry.value_ptr.*.append(s);
        } else {
            entry.value_ptr.* = std.ArrayList([]const u8).init(std.heap.page_allocator);
            try entry.value_ptr.*.append(s);
        }

        //end of the possible substitutions
        if(cnt == end) {
            break;
        }
        cnt += 1;
    }
    const entry = iter.next().?;
    // print("entry: {s}\n", .{entry});
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const alok = arena.allocator();
    defer arena.deinit();
    var changes = std.ArrayList([]u8).init(alok);

    var it = map.iterator();
    while(it.next()) |e| {
        const key = e.key_ptr.*;
        for(e.value_ptr.*.items) |w| {
            for__ : for(0..entry.len) |i| {
                if(entry[i] == key[0] and mem.eql(u8, entry[i..i+key.len], key)) {
                    //create a new string with the substitution
                    const s = try std.fmt.allocPrint(alok, "{s}{s}{s}", .{entry[0..i], w, if(i+key.len-1 == entry.len) "" else entry[i+key.len..entry.len]});
                    //check if the string is already in the list
                    for(changes.items) |c| {
                        if(mem.eql(u8, c, s)) {
                            continue : for__;
                        }
                    }
                    //if not, add it
                    try changes.append(s);
                }
            }
        }
    }
    print("changes: {d}\n", .{changes.items.len});

    //print the whole map
//     var mapIt = map.iterator();
//     while(mapIt.next()) |e| {
//         print("{s} => {{", .{e.key_ptr.*});
//         for(e.value_ptr.*.items) |s| {
//             print("{s}, ", .{s});
//         }
//         print("}}\n", .{});
//     }

    //to solve the second half we must analyze the entry to see some points about the grammar pattern
    //
    // All it's productions have the from : X -> XX | X Rn X (YX)* Ar
    // where, X is a variable of the grammar, and Rn, Y and Ar are terminals
    // so, to find the number of steps to reach the molecule we can use these patterns
    //
    // and the formula: steps = qtdElements - count(Rn) - 2*count(Y) - count(Ar) - 1
    // that comes from the fact that:
    // X = XX -> X, steps = qtdElements -0 -0 -0 -1 = 1
    // X = XRnXAr -> X,steps = qtdElements -1 -0 -1 -1 = 1
    // X = XRnXYXAr -> X, steps = qtdElements -1 -2 -1 -1 = 1

    var count : usize = 0;
    var countSpecial : usize = 0;
    //find the quantity of elements the entry has, and count Rn, Y and Ar
    for(0..entry.len) |i| {
        if(map.contains(entry[i..i+1]) or (i+1 < entry.len and map.contains(entry[i..i+2]))) {
            count += 1;
        } else {
            if(i+1 < entry.len and (mem.eql(u8, entry[i..i+2], "Rn") or mem.eql(u8, entry[i..i+2], "Ar"))) {
                count += 1;
                countSpecial += 1;
            }
            if(mem.eql(u8, entry[i..i+1], "Y")) {
                count += 1;
                countSpecial += 2;
            }
        }
    }
    const steps = count - countSpecial - 1;
    print("steps: {d}\n", .{steps});
}

test "alloc n free test" {

    var map = Map.init(std.testing.allocator);
    defer {
        var it = map.iterator();
        while(it.next()) |e| {
            e.value_ptr.deinit();
        }
        map.deinit();
    }

    var cnt : usize = 1;
    var iter = mem.tokenizeAny(u8, file, " \n");
    while(iter.next()) |word| {
        _ = iter.next(); //skip the "=>"

        const s = iter.next().?;
        const entry = try map.getOrPut(word);
        if(entry.found_existing) {
            try entry.value_ptr.*.append(s);
        } else {
            entry.value_ptr.* = std.ArrayList([]const u8).init(std.testing.allocator);
            try entry.value_ptr.*.append(s);
        }

        //end of the possible substitutions
        if(cnt == end) {
            break;
        }
        cnt += 1;
    }
    const entry = iter.next().?;
    // print("entry: {s}\n", .{entry});
    var changes = std.ArrayList(u8).init(std.testing.allocator);
    defer {
        for(changes.items) |e| {
            std.testing.allocator.free(e.str);
        }
        changes.deinit();
    }

    var it = map.iterator();
    while(it.next()) |e| {
        const key = e.key_ptr.*;
        for(e.value_ptr.*.items) |w| {
            _ = w;
            for(0..entry.len) |i| {
                if(entry[i] == key[0] and mem.eql(u8, entry[i..i+key.len], key)) {

                    // print("local para substituir: {s}, at {} with {s}\n", .{key, i, changes.getLast().str});
                }
            }
        }
    }


}
