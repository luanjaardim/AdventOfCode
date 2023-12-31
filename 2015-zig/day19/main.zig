const std = @import("std");
const print = std.debug.print;
const file = @embedFile("entry.txt");
const Map = std.StringHashMap(std.ArrayList([]const u8));
const mem = std.mem;
const end = 43;

pub fn main() !void {

    var map = Map.init(std.heap.page_allocator);
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
        // print("at key: {s}\n", .{key});
        // print("\n", .{});
        for(e.value_ptr.*.items) |w| {
            for__ : for(0..entry.len) |i| {
                const s = try std.fmt.allocPrint(alok, "{s}{s}{s}", .{entry[0..i], w, if(i+key.len-1 == entry.len) "" else entry[i+key.len..entry.len]});
                if(entry[i] == key[0] and mem.eql(u8, entry[i..i+key.len], key)) {
                    for(changes.items) |c| {
                        if(mem.eql(u8, c, s)) {
                            continue : for__;
                        }
                    }
                    try changes.append(s);
                }
            }
        }
    }
    // for(changes.items) |c| {
    //     var buf = [_]u8{0} ** 1024;
    //     const sla = try std.fmt.bufPrint(&buf, "{s}{s}{s}\n", .{entry[0..c.pos], c.str, entry[c.pos+c.prevLen..entry.len]});
    //     try std.io.getStdOut().writer().print("{s}", .{sla});
    // }
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
