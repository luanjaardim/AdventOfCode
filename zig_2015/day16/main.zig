const std = @import("std");
const print = std.debug.print;
const file = @embedFile("entry.txt");
const mem = std.mem;

const dontRemember : i8 = -1;
const Aunt = struct {
    children    : i8 = dontRemember,
    cats        : i8 = dontRemember,
    samoyeds    : i8 = dontRemember,
    pomeranians : i8 = dontRemember,
    akitas      : i8 = dontRemember,
    vizslas     : i8 = dontRemember,
    goldfish    : i8 = dontRemember,
    trees       : i8 = dontRemember,
    cars        : i8 = dontRemember,
    perfumes    : i8 = dontRemember,
};

fn propMatch(a : i8, b : i8) bool {
    if(b == -1) return true //we don't know the property
    else return a == b;
}

fn propMatchGreater(a : i8, b : i8) bool {
    if(b == -1) return true //we don't know the property
    else return a < b;
}

fn propMatchFewer(a : i8, b : i8) bool {
    if(b == -1) return true //we don't know the property
    else return a > b;
}

pub fn main() !void {
    const my_aunt = Aunt{
        .children = 3,
        .cats = 7,
        .samoyeds = 2,
        .pomeranians = 3,
        .akitas = 0,
        .vizslas = 0,
        .goldfish = 5,
        .trees = 3,
        .cars = 2,
        .perfumes = 1,
    };
    var id : usize = 0;
    var iter = std.mem.tokenizeScalar(u8, file, '\n');
    while(iter.next()) |line| {
        id += 1;

        var words = std.mem.tokenizeAny(u8, line, ",: ");
        _ = words.next(); // skip "Sue"
        _ = words.next(); // skip id

        var aunt = Aunt{};
        //fills aunt with the properties
        while(words.next()) |w| {
            if(mem.eql(u8, "children", w)) {
                aunt.children = try std.fmt.parseInt(i8, words.next().?, 10);
            } else if (mem.eql(u8, "cats", w)) {
                aunt.cats = try std.fmt.parseInt(i8, words.next().?, 10);
            } else if (mem.eql(u8, "samoyeds", w)) {
                aunt.samoyeds = try std.fmt.parseInt(i8, words.next().?, 10);
            } else if (mem.eql(u8, "pomeranians", w)) {
                aunt.pomeranians = try std.fmt.parseInt(i8, words.next().?, 10);
            } else if (mem.eql(u8, "akitas", w)) {
                aunt.akitas = try std.fmt.parseInt(i8, words.next().?, 10);
            } else if (mem.eql(u8, "vizslas", w)) {
                aunt.vizslas = try std.fmt.parseInt(i8, words.next().?, 10);
            } else if (mem.eql(u8, "goldfish", w)) {
                aunt.goldfish = try std.fmt.parseInt(i8, words.next().?, 10);
            } else if (mem.eql(u8, "trees", w)) {
                aunt.trees = try std.fmt.parseInt(i8, words.next().?, 10);
            } else if (mem.eql(u8, "cars", w)) {
                aunt.cars = try std.fmt.parseInt(i8, words.next().?, 10);
            } else if (mem.eql(u8, "perfumes", w)) {
                aunt.perfumes = try std.fmt.parseInt(i8, words.next().?, 10);
            } else {
                print("unknown property: {s}\n", .{w});
                std.os.exit(1);
            }
        }
        //compare the properties with the ones of my_aunt
        if(propMatch(my_aunt.children, aunt.children)
           and propMatch(my_aunt.akitas, aunt.akitas)
           and propMatch(my_aunt.cars, aunt.cars)
           and propMatch(my_aunt.cats, aunt.cats)
           and propMatch(my_aunt.goldfish, aunt.goldfish)
           and propMatch(my_aunt.perfumes, aunt.perfumes)
           and propMatch(my_aunt.pomeranians, aunt.pomeranians)
           and propMatch(my_aunt.samoyeds, aunt.samoyeds)
           and propMatch(my_aunt.trees, aunt.trees)
           and propMatch(my_aunt.vizslas, aunt.vizslas)) {
            print("aunt {d} matches the first answer\n", .{id});
        }
        if(propMatch(my_aunt.children, aunt.children)
           and propMatch(my_aunt.akitas, aunt.akitas)
           and propMatch(my_aunt.cars, aunt.cars)
           and propMatch(my_aunt.perfumes, aunt.perfumes)
           and propMatch(my_aunt.samoyeds, aunt.samoyeds)
           and propMatchGreater(my_aunt.trees, aunt.trees)
           and propMatchGreater(my_aunt.cats, aunt.cats)
           and propMatchFewer(my_aunt.goldfish, aunt.goldfish)
           and propMatchFewer(my_aunt.pomeranians, aunt.pomeranians)
           and propMatch(my_aunt.vizslas, aunt.vizslas)) {
            print("aunt {d} matches the second answer\n", .{id});
        }
    }
}
