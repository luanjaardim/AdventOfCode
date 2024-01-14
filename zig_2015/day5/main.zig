const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const file = @embedFile("entry.txt");

pub fn main() !void {
    // try first_problem();
    try second_problem();
}

pub fn first_problem() !void {
    var vowels: usize = 0;
    var twiceInRow: bool = false;
    const badSubStrs = comptime [_][]const u8{"ab", "cd", "pq", "xy"};

    var qtdNiceStrings: usize = 0;

    var split = mem.tokenize(u8, file, "\n"); //split the text to get the different lines
    ext_loop: while(split.next()) |word| {
        vowels = 0;
        twiceInRow = false;
        // std.debug.print("-----------------\n", .{});
        // std.debug.print("{s}\n", .{word});

        var w = mem.window(u8, word, 2, 1);
        while(w.next()) |tup| {
            switch(tup[0]) {
                'a', 'e', 'i', 'o', 'u' => vowels += 1,
                else => {},
            }
            if(tup[0] == tup[1]) twiceInRow = true;
            inline for(badSubStrs) |badSub| {
                if(mem.eql(u8, badSub, tup)) {
                    std.debug.print("has badSub: {s}\n", .{badSub});
                    continue :ext_loop;
                }

            }
        }
        switch(word[word.len - 1]) { //in the while above the last char is not checked as vowel
            'a', 'e', 'i', 'o', 'u' => vowels += 1,
            else => {},
        }
        // std.debug.print("has {} vowels\n", .{vowels});
        // if(twiceInRow) std.debug.print("have twice in a row chars\n", .{})
        // else std.debug.print("does not have twice in a row chars\n", .{});

        if(vowels > 2 and twiceInRow) {
            // std.debug.print("Is a nice string!\n", .{});
            qtdNiceStrings += 1;
        }
    }
    std.debug.print("{}\n", .{qtdNiceStrings});
}

fn second_problem() !void {

    var split = mem.tokenize(u8, file, "\n");
    //for the alphabet we have 26 chars, if a pair of them to an array there is 26*26 possible
    //combinations, so i will make an array of 26*26 =  positions to store if some pair has already
    //appeared in the word
    var map: [676]bool = undefined;
    @memset(map[0..], false);
    var pairPos: [15]u16 = undefined; //will store the pair positions of each word to set false after that
    var prevChar: u8 = 0; //stores the previous first tup char

    var i: usize = 0;
    var currPos: u16 = std.math.maxInt(u16); //pos on map of each tup
    var hasDoubleSub: bool = false;
    var hasTwoEqualsWithMid: bool = false;

    var qtdNiceWords: usize = 0;

    while(split.next()) |word| { //iterate over all words of the file
        prevChar = 0;
        i = 0;
        hasDoubleSub = false;
        hasTwoEqualsWithMid = false;

        var w = mem.window(u8, word, 2, 1); //a window of two neighbours chars

        while(w.next()) |tup| {
            //the current tup[0] is the previous tup[1]
            if(prevChar == tup[1]) hasTwoEqualsWithMid = true;

            if(@as(u16, @intCast(getMapPos(tup[0], tup[1]))) == currPos) {
                currPos = std.math.maxInt(u16); //if it overlaps set the currPos to unreachable value
                continue;
            } else {
                currPos = @intCast(getMapPos(tup[0], tup[1]));
            }

            //saving all the pair positions on map, so we can restore it, setting the positions to false
            pairPos[i] = currPos;

            //if the currPos has already been visited, a tup had the same value before on the word(equal tup)
            if(map[currPos]) hasDoubleSub = true
            //else just set it's position to true
            else map[currPos] = true;

            prevChar = tup[0];
            i += 1;
            if(hasDoubleSub and hasTwoEqualsWithMid) break;
        }

        if(hasDoubleSub and hasTwoEqualsWithMid) {
            qtdNiceWords += 1;
        }
        for(0..i) |pos| {
            //restoring every used position of the map to it's default value
            map[pairPos[pos]] = false;
        }
    }
    std.debug.print("{}\n", .{qtdNiceWords});
}

fn getMapPos(firstChar: u8, secondChar: u8) usize {
    return 26*@as(usize, (firstChar - 'a')) + @as(usize, (secondChar - 'a'));
}
