const std = @import("std");
const print = std.debug.print;
const file = @embedFile("entry.txt");

const Reindeer = struct {
    speed : usize,
    flyTime : usize,
    restTime : usize,
    whenChanged : usize = 0, //when changed its status from flying to resting or vice versa
    isResting : bool, //true if resting, false if flying
    currDistance : usize = 0,
    points : usize = 0, //part 2
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alok = arena.allocator();

    var reindeers = std.ArrayList(Reindeer).init(alok);

    var iter = std.mem.tokenizeScalar(u8, file, '\n');
    while(iter.next()) |line| {
        var words = std.mem.tokenizeScalar(u8, line, ' ');
        _ = words.next(); // skip name
        _ = words.next(); // skip can
        _ = words.next(); // skip fly
        const speed = try std.fmt.parseInt(usize, words.next().?, 10);

        _ = words.next(); // skip km/s
        _ = words.next(); // skip for
        const flyTime = try std.fmt.parseInt(usize, words.next().?, 10);

        _ = words.next(); // skip seconds,
        _ = words.next(); // skip but
        _ = words.next(); // skip then
        _ = words.next(); // skip must
        _ = words.next(); // skip rest
        _ = words.next(); // skip for
        const restTime = try std.fmt.parseInt(usize, words.next().?, 10);
        try reindeers.append(Reindeer{ .speed = speed, .flyTime = flyTime, .restTime = restTime, .isResting = false});
    }

    var maxCurrDist : usize = 0;
    for(0..2503) |s| {
        maxCurrDist = 0;
        for(reindeers.items) |*r| {
            //check if the reindeer is resting or flying
            //then update distance and points of each reindeer individually
            if(r.isResting) {
                if(s - r.whenChanged == r.restTime) {
                    r.isResting = false;
                    r.whenChanged = s;
                    r.currDistance += r.speed;
                }
            } else {
                if(s - r.whenChanged == r.flyTime) {
                    r.isResting = true;
                    r.whenChanged = s;
                } else {
                    r.currDistance += r.speed;
                }
            }
            maxCurrDist = @max(maxCurrDist, r.currDistance);
        }
        //count points for the second part solution
        for(reindeers.items) |*r| {
            if(r.currDistance == maxCurrDist) {
                r.points += 1;
            }
        }
    }
    var maxDist = reindeers.items[0].currDistance;
    var maxPoints = reindeers.items[0].points;
    for(1..reindeers.items.len) |i| {
        maxDist = @max(maxDist, reindeers.items[i].currDistance);
        maxPoints = @max(maxPoints, reindeers.items[i].points);
    }
    print("Part 1: {}\n", .{maxDist});
    print("Part 2: {}\n", .{maxPoints});
}
