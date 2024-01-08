const std = @import("std");
const print = std.debug.print;
const calculatedPrimes = @embedFile("primes.txt");
const input  = 33100000;
const stopDelivering = 50;
// const input = 1000;

const Factor = struct {
    val : usize,
    num : usize,
};

const Pair = struct {
    p1 : usize,
    p2 : usize,
};

//find all prime factors of a number
fn findFactors(f : []Factor, num : usize, primes : *std.ArrayList(usize)) void {
    var val = num;
    var i : usize = 0;
    for(primes.*.items) |prime| {
        if(val % prime == 0) {
            while(val % prime == 0) {
                val /= prime;
                f[i].val = prime;
                f[i].num += 1;
            }

            // all factors have been found
            if(val == 1) {
                return;
            }
            i += 1;
        }
    }
    //there aren't prime factors, so it's a prime
    if(f[0].num == 0) {
        // print("{} is prime.", .{num});
        primes.*.append(num) catch unreachable;
    }
}

fn clearFactors(f : []Factor) void {
    for(f) |*fac| {
        if(fac.num == 0) {
            break;
        }
        fac.*.num = 0;
        fac.*.val = 0;
    }
}

fn printFactors(f : []Factor) void {
    for(f, 0..) |fac, i| {
        if(fac.num == 0) {
            return;
        }
        if(i != 0) print("* {}^{} ", .{fac.val, fac.num}) else print("{}^{} ", .{fac.val, fac.num});
    }
}

fn presentsFromFactors(f : []Factor, index : usize) usize {
    //this will sum all the possible combinations of the factors, recursively
    //take 6: 2 * 3
    //when it reaches the end of the factors, it will return 1, this will be muiltplyed by all
    //powers of the previous factor, in this example only the three and 1(3^0), when coming back
    //to the 2, it will do the same thing, but now the 2 will multiply the result of the recursion:
    //2*(3^1 + 3^0) + 1*(3^1 + 3^0) = 6 + 3 + 2 + 1
    var sum : usize = 0;
    if(f[index].num == 0) {
        return 1;
    }
    const next = presentsFromFactors(f, index + 1);
    for(1..f[index].num+1) |i| {
        sum += std.math.pow(usize, f[index].val, i) * next;
    }
    sum += next;
    return sum;
}

pub fn main() !void {

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alok = arena.allocator();

    var primes = std.ArrayList(usize).init(alok);
    var iter = std.mem.tokenizeScalar(u8, calculatedPrimes, '\n');
    while(iter.next()) |prime| {
        const num = try std.fmt.parseInt(usize, prime, 10);
        try primes.append(num);
    }

    var factors = [_]Factor{ Factor{.num = 0, .val = 0} } ** 1024;
    var arr = try alok.alloc(usize, 1000000);
    @memset(arr, 0);

    //answer for part 1
    //my first part is very slow, but i enjoyed this recursive approach for calculate all combinations
    //of the factors, even if it's not very efficient
    for(3..input) |num| {
        findFactors(&factors, num, &primes);
        const p = presentsFromFactors(&factors, 0) * 10;
        clearFactors(&factors);
        if(p >= input) {
            print("part1 num {}: {}\n", .{num, p});
            break;
        }
    }

    //answer for part 2
    //saving every house presents firstly, then checking for the first that is greater than the input
    var i : usize = 0;
    var count : usize = 0;
    for(1..arr.len) |num| {
        i = num;
        count = 0;
        while(i < arr.len) : (i += num) {
            count += 1;
            arr[i] += num*11;
            if(count == stopDelivering) {
                break;
            }
        }
    }
    for(arr, 0..) |presents, j| {
        if(presents >= input) {
            print("part2 num {}: {}\n", .{j, presents});
            break;
        }
    }
}
