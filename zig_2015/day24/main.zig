const std = @import("std");
const print = std.debug.print;
const file = @embedFile("entry.txt");
var sum : usize = 0;

//presents -> list of presents
//configuration -> current configuration, it has all the presents that are currently in the front configuration
//visited -> presents that are visited already
//startInd -> start index of the presents list, presents before were already considered
//curInd -> current index of the configuration, the last element that was added to the configuration
//curSum -> current sum of the configuration
//minLen -> minimum length found, from all the configurations that have the especified sum
//quant -> minimum quantum entanglement found, from all the configurations that have the especified sum
fn findMinConfiguration(presents : *std.ArrayList(u8), configuration : [50]u8, visited : []bool, startInd : usize, curInd : usize, curSum : usize, minLen : *usize, quant : *usize) void {
    if(curInd + 1 > minLen.*) {
        return ;
    }
    var quantumEntanglement : usize = 1;
    var config = configuration;
    for(presents.*.items[startInd..], startInd..) |p, i| {
        if(visited[i]) {
            continue;
        }
        if(curSum + p == sum) {
            config[curInd] = p;
            if(curInd + 1 < minLen.*) {
                minLen.* = curInd + 1;
                quant.* = std.math.maxInt(usize);
            }
            for(config[0..curInd+1]) |c| {
                quantumEntanglement *= c;
            }
            quant.* = @min(quantumEntanglement, quant.*);
        }
    }
    quantumEntanglement = std.math.maxInt(usize);
    for(presents.*.items[startInd..], startInd..) |p, i| {
        if(curSum + p > sum or visited[i]) {
            continue;
        }
        visited[i] = true;
        config[curInd] = p;
        findMinConfiguration(presents, config, visited, i, curInd + 1, curSum + p, minLen, quant);
        visited[i] = false;
    }
}

pub fn main() !void {

    var presents = std.ArrayList(u8).init(std.heap.page_allocator);
    defer presents.deinit();

    var iter = std.mem.tokenizeScalar(u8, file, '\n');
    while(iter.next()) |num| {
        const p = try std.fmt.parseInt(u8, num, 10);
        sum += p;
        try presents.append(p);
    }
    //sort in descending order for better performance
    std.sort.pdq(u8, presents.items, {}, std.sort.desc(u8));
    const totalSum = sum;
    sum = totalSum / 3;
    const config = [_]u8{ 0 } ** 50;
    var visited = [_]bool{ false } ** 50;
    var minLen : usize = std.math.maxInt(usize);
    var quantumEntanglement : usize = std.math.maxInt(usize);
    findMinConfiguration(&presents, config, &visited, 0, 0, 0, &minLen, &quantumEntanglement);
    print("part1 quantum entanglement: {}\n", .{quantumEntanglement});

    quantumEntanglement = std.math.maxInt(usize);
    minLen = std.math.maxInt(usize);
    sum = totalSum / 4;
    @memset(&visited, false);
    findMinConfiguration(&presents, config, &visited, 0, 0, 0, &minLen, &quantumEntanglement);
    print("part2 quantum entanglement: {}\n", .{quantumEntanglement});
}
