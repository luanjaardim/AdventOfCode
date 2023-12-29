const std = @import("std");
const print = std.debug.print;
const file = @embedFile("entry.txt");

//all zero matrix
// const map = [_][8]isize{ std.mem.zeroes([8]isize) };
var map = [_][8]isize{ [8]isize{ 0, 0, 0, 0, 0, 0, 0, 0 } } ** 8;
fn getIndex(char : u8) !usize {
    if(char >= 'A' and char <= 'G') return char - 'A';
    if(char == 'M') return 'H' - 'A';

    return error.NotExpectedChar;
}

pub fn main() !void {

    var iter = std.mem.tokenizeScalar(u8, file, '\n');
    while (iter.next()) |line| {
        var words = std.mem.tokenizeScalar(u8, line, ' ');
        const x = try getIndex(words.next().?[0]); //this will return a number to represent the person name using the first char of the name

        _ = words.next(); //skip the word "would"
        var happiness : isize = if(std.mem.eql(u8, words.next().?, "lose")) -1 else 1; //if the word is "lose" then the happiness is -1, otherwise it is 1
        happiness *= try std.fmt.parseInt(isize, words.next().?, 10); //get the happiness number

        _ = words.next(); //skip the word "happiness"
        _ = words.next(); //skip the word "units"
        _ = words.next(); //skip the word "by"
        _ = words.next(); //skip the word "sitting"
        _ = words.next(); //skip the word "next"
        _ = words.next(); //skip the word "to"

        const y = try getIndex(words.next().?[0]); //this will return a number to represent the person name using the first char of the name
        map[x][y] = happiness; //fill the map with the happiness between x and y
    }

    //HARDCODED PERMUTATION
    var visited = [_]bool{ false, false, false, false, false, false, false, false };
    var sum : isize = 0;
    var min : isize = std.math.maxInt(isize);

    for(0..map.len) |a| {
        visited = [_]bool{ false, false, false, false, false, false, false, false };
        visited[a] = true;

        for(0..map.len) |b| {
            if(visited[b]) continue;
            visited[b] = true;

            for(0..map.len) |c| {
                if(visited[c]) continue;
                visited[c] = true;

                for(0..map.len) |d| {
                    if(visited[d]) continue;
                    visited[d] = true;

                    for(0..map.len) |e| {
                        if(visited[e]) continue;
                        visited[e] = true;

                        for(0..map.len) |f| {
                            if(visited[f]) continue;
                            visited[f] = true;

                            for(0..map.len) |g| {
                                if(visited[g]) continue;
                                visited[g] = true;

                                for(0..map.len) |h| {
                                    if(visited[h]) continue;
                                    //the better way to understand the vector bellow is to imagine that
                                    //every element is the happiness of each person, this is calculated by
                                    //for example: map[a][b] + map[a][h] = happiness of a
                                    //it's the sum of the happiness of a with b and a with h,
                                    //but, to solve the second problem, i am switching some links of happiness
                                    //to remove the worst link between two neighbours, at the end this won't
                                    //change the answer because at, some point, the link between b and a would be found,
                                    //at the calculation of the happiness of b, so we can change the vector to be
                                    //the happines between neighbours
                                    const v : @Vector(map.len, isize) = [_]isize{
                                        map[a][b] + map[b][a], //this is the happiness between a and b
                                        map[b][c] + map[c][b],
                                        map[c][d] + map[d][c],
                                        map[d][e] + map[e][d],
                                        map[e][f] + map[f][e],
                                        map[f][g] + map[g][f],
                                        map[g][h] + map[h][g],
                                        map[h][a] + map[a][h]
                                    };
                                    const cost = @reduce(.Add, v);
                                    if(sum < cost) {
                                        sum = cost;
                                        //if the optimal solution is updated, then we need to remove the worst seating
                                        //of the combination, that will be the one with the lowest happiness
                                        min = @reduce(.Min, v);
                                        // print("new permutation: {any}\n", .{v});
                                    }
                                }
                                visited[g] = false;
                            }
                            visited[f] = false;
                        }
                        visited[e] = false;
                    }
                    visited[d] = false;
                }
                visited[c] = false;
            }
            visited[b] = false;
        }
    }
    print("sum: {}\n", .{sum});
    print("min: {}\n", .{min});
    print("sum - min: {}\n", .{sum - @as(i64, @intCast(@abs(min)))});
}
