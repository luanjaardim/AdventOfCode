const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const file = @embedFile("entry.txt");

const Operand = struct {
    isVal : bool,
    val : u16,
};

const OpsType = enum(u3) {
    Not, And, Or, Lshift, Rshift, JustStore, None
};

const Operation = struct {
    typeOp: OpsType,
    op1: Operand,
    op2: Operand,
    done: bool = false,
    val: u16,
};

fn getPos(name: []const u8) u16 {
    if(name.len == 1) return 676 + @as(u16, @intCast(name[0] - 'a'))
    else return @as(u16, @intCast(name[0] - 'a')) + 26*@as(u16, @intCast(name[1] - 'a'));
}

fn calculateValue(map : []Operation, pos: u16) u16 {

    if(map[pos].done) {
        return map[pos].val;
    }
    else {
        switch(map[pos].typeOp) {
            .And => {
                map[pos].val = (if(map[pos].op1.isVal) map[pos].op1.val else calculateValue(map, map[pos].op1.val)) &
                               (if(map[pos].op2.isVal) map[pos].op2.val else calculateValue(map, map[pos].op2.val));
            },
            .Or => {
                map[pos].val = (if(map[pos].op1.isVal) map[pos].op1.val else calculateValue(map, map[pos].op1.val)) |
                               (if(map[pos].op2.isVal) map[pos].op2.val else calculateValue(map, map[pos].op2.val));
            },
            .Not => {
                map[pos].val = if(map[pos].op1.isVal) (~map[pos].op1.val) else (~calculateValue(map, map[pos].op1.val));
            },
            .Lshift => {
                map[pos].val = (if(map[pos].op1.isVal) map[pos].op1.val else calculateValue(map, map[pos].op1.val)) <<
                               @intCast(if(map[pos].op2.isVal) map[pos].op2.val else calculateValue(map, map[pos].op2.val));
            },
            .Rshift => {
                map[pos].val = (if(map[pos].op1.isVal) map[pos].op1.val else calculateValue(map, map[pos].op1.val)) >>
                               @intCast(if(map[pos].op2.isVal) map[pos].op2.val else calculateValue(map, map[pos].op2.val));
            },
            .JustStore => {
                map[pos].val = if(map[pos].op1.isVal) map[pos].op1.val else calculateValue(map, map[pos].op1.val);
            },
            else => {
                print("error: invalid operation type", .{});
                std.os.exit(1);
            }
        }
        map[pos].done = true;
        return map[pos].val;
    }
}

fn assemblyCircuit(map : []Operation, iter : mem.TokenIterator(u8, .scalar)) void {
    var inner_iter = iter;
    while(inner_iter.next()) |line| {
        var words = mem.tokenizeScalar(u8, line, ' ');

        var op : Operation = Operation{
            .typeOp = .None,
            .op1 = Operand{ .isVal = true, .val = 0},
            .op2 = Operand{ .isVal = true, .val = 0},
            .done = false,
            .val = 0,
        };

        word_for__ : while(words.next()) |word| {
            if(mem.eql(u8, "->", word)) {
                if(op.typeOp == .None) {
                    op.typeOp = .JustStore;
                }
                break : word_for__ ; //if the type was empty it will be a store operation
            }

            inline for ([_][]const u8{"NOT", "AND", "OR", "LSHIFT", "RSHIFT"}, 0..) |operation, ind| {
                if(mem.eql(u8, operation, word)) {
                    op.typeOp = @enumFromInt(ind);
                    continue : word_for__; //type of the operation found
                }
            }

            if((op.typeOp == .None) or (op.typeOp == .Not)) {
                //get the value as a number or as a position to a operation in map
                op.op1.val = std.fmt.parseInt(u16, word, 10) catch parse_err__ : {
                    op.op1.isVal = false;
                    break : parse_err__ getPos(word); //break catch block returning a value
                };
            } else {
                //get the value as a number or as a position to a operation in map
                op.op2.val = std.fmt.parseInt(u16, word, 10) catch parse_err__ :{
                    op.op2.isVal = false;
                    break : parse_err__ getPos(word); //break catch block returning a value
                };
            }
        }
        const word = words.next() orelse {
            print("error: line without a destination operand", .{});
            std.os.exit(1);
        };
        map[getPos(word)] = op;
    }
}

pub fn main() !void {

    // this map will store every operation that must be used for calculate
    // some wire, and the value of the operation it it was already calculated
    var map: [26*26+26]Operation =
        [_]Operation{Operation{
            .typeOp = .None,
            .op1 = Operand{ .isVal = true, .val = 0},
            .op2 = Operand{ .isVal = true, .val = 0},
            .done = false,
            .val = 0}
        } ** 702; //fills the array with the same value
    map[0].done = true;


    //this will iterate over the file lines
    const iter = mem.tokenizeScalar(u8, file, '\n');
    assemblyCircuit(&map, iter);
    print("First problem solution: {}\n", .{calculateValue(&map, getPos("a"))});

    const backupA = map[getPos("a")]; //backup the value of 'a' to override the signal of 'b'
    //clean the map to the solve the second problem
    @memset(&map, Operation{
            .typeOp = .None,
            .op1 = Operand{ .isVal = true, .val = 0},
            .op2 = Operand{ .isVal = true, .val = 0},
            .done = false,
            .val = 0
    });
    assemblyCircuit(&map, iter);
    map[getPos("b")] = backupA;
    print("Second problem solution: {}\n", .{calculateValue(&map, getPos("a"))});
}

test "array of strings" {

    const oi: []const u8 = "sla";
    print("{s}\n", .{@typeName(@TypeOf(oi))});
}
