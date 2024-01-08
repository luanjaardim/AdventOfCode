const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const heap = std.heap;
const file = @embedFile("entry.txt");
const array = std.ArrayList;

const Node = struct {
    orig : u8,
    dest : u8,
    distance : usize
};

const Paths = struct {
    longest : usize,
    shortest : usize
};

fn minPath(distMatrix : [][]usize, visiting : u8, visited : []bool) Paths {
    var p = Paths{ .longest = 0, .shortest = std.math.maxInt(usize)};
    var allVisited = true;
    visited[visiting] = true; //the node cannot visit itself
    for(0..visited.len) |toVisit| {
        if(!visited[toVisit]) {
            allVisited = false;
            //check if the not visited is reachable
            if(distMatrix[visiting][toVisit] != std.math.maxInt(usize)) {
                visited[toVisit] = true;
                //minPath can return a infinite value, that happens when the node cannot
                //reach any of the still not visited nodes
                const dist = minPath(distMatrix, @intCast(toVisit), visited);
                if(dist.shortest == std.math.maxInt(usize)) {
                    continue;
                }

                //print elem distance, neighbour, dist and distMax
                if(p.shortest > dist.shortest + distMatrix[visiting][toVisit]) {
                    p.shortest = dist.shortest + distMatrix[visiting][toVisit];
                }
                if(p.longest < dist.longest + distMatrix[visiting][toVisit]) {
                    p.longest = dist.longest + distMatrix[visiting][toVisit];
                }
                visited[toVisit] = false;
                continue; //continue to search for better paths
            }
        }
    }
    visited[visiting] = false;
    if(allVisited) { // end of recursion, visited every node
        return .{ .longest = 0, .shortest = 0 };
    }
    return p;
}

pub fn main() !void {

    var arena = heap.ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();
    const alok = arena.allocator();

    //used for mapping the names to numbers
    var map = std.StringHashMap(u8).init(alok);
    var id : u8 = 0;

    //used for storing the distances
    var arrDistances = array(Node).init(alok);

    var iter = mem.tokenizeScalar(u8, file, '\n');

    //reading the file and inserting the nodes
    while(iter.next()) |line| {
        var words = mem.tokenizeScalar(u8, line, ' ');
        const entry1 = try map.getOrPut(words.next() orelse unreachable);
        if(!entry1.found_existing) {
            entry1.value_ptr.* = id;
            id += 1;
        }
        //discarting the "to"
        _ = words.next();
        const entry2 = try map.getOrPut(words.next() orelse unreachable);
        if(!entry2.found_existing) {
            entry2.value_ptr.* = id;
            id += 1;
        }
        //discarting the "="
        _ = words.next();
        const dist = try std.fmt.parseInt(usize, words.next() orelse unreachable, 10);

        //double link the nodes
        try arrDistances.append(Node{.orig = entry1.value_ptr.*, .dest = entry2.value_ptr.*, .distance = dist});
        try arrDistances.append(Node{.orig = entry2.value_ptr.*, .dest = entry1.value_ptr.*, .distance = dist});
    }

    var distanceMatrix = try alok.alloc([]usize, map.count());
    for(0..map.count()) |i| {
        distanceMatrix[i] = try alok.alloc(usize, map.count());
        @memset(distanceMatrix[i], std.math.maxInt(usize));
        distanceMatrix[i][i] = 0;
    }
    //fill matrix with distances
    for(arrDistances.items) |elem| {
        distanceMatrix[elem.orig][elem.dest] = elem.distance;
    }

    var minDistance : usize = std.math.maxInt(usize);
    var maxDistance : usize = 0;
    const visited = try alok.alloc(bool, distanceMatrix.len);
    @memset(visited, false);

    //walking through the matrix from every possible start point
    for(0..distanceMatrix.len) |i| {
        const p = minPath(distanceMatrix, @intCast(i), visited);
        minDistance = @min(minDistance, p.shortest);
        maxDistance = @max(maxDistance, p.longest);
    }
    print("minDistance {}\n", .{minDistance});
    print("maxDistance {}\n", .{maxDistance});

    //printing the matrix of distances
    for(distanceMatrix) |line| {
        for(line) |elem| {
            var buf = [_]u8{' '} ** 5;
            if(elem == std.math.maxInt(usize)) {
                buf[0] = 'i';
                buf[1] = 'n';
                buf[2] = 'f';
            } else {
                _ = std.fmt.formatIntBuf(&buf, elem, 10, .lower, std.fmt.FormatOptions{});
            }
            for(buf) |c| {
                print("{c}", .{c});
            }
        }
        print("\n", .{});
    }
}

test "inserting and getting elements from hash" {

    print("\n", .{});
    var arena = heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const alok = arena.allocator();

    var map = std.StringHashMap(u8).init(alok);
    const entry = try map.getOrPut("foo");
    entry.value_ptr.* = 10;


    print("key and value = {any}\n", .{map.get("foo") orelse null});

    //alloc a matrix with the same arena, this will be deallocated at the defer too
    var matrix = try alok.alloc([]usize, 10);
    for(0..matrix.len) |i| {
        matrix[i] = try alok.alloc(usize, 10);
        for(matrix[i]) |*j| {
            j.* = i;
        }
    }
    for(matrix) |line| {
        for(line) |col| {
            print("{} ", .{col});
        }
        print("\n", .{});
    }
}

test "arraylist of struct" {
    var list = std.ArrayList(u8).init(std.testing.allocator);
    defer list.deinit();
    try list.append(1);
    try list.append(2);
    try list.append(3);
    for(list.items) |num| {
        print("{}\n", .{num});
    }

    const pair = struct{x : u8, y : u8};
    var mlist = std.MultiArrayList(pair);
    mlist.append(std.testing.allocator, pair{.x = 1, .y = 2});
    const sla = mlist.slice().items(.x);
    print("slice len = {}\n", .{sla.len});
}
