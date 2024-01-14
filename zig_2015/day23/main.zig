const std = @import("std");
const print = std.debug.print;
const file = @embedFile("entry.txt");

const InstOpCode = enum {
    jio, // jump if one
    jie, // jump if even
    jmp, // jump
    inc, // increment
    tpl, // triple
    hlf, // half
};

const Instruction = struct {
    opCode: InstOpCode,
    register: u8,
    offset: isize,
};

fn executeCode(instructions : []Instruction, len : usize, r : []usize) void {
    var i : usize = 0;
    var registers = r;
    while(i < len) {
        // print("i: {}, a: {}, b: {}\n", .{ i, registers[0], registers[1] });
        switch(instructions[i].opCode) {
           .jio => {
               if(registers[if(instructions[i].register == 'a') 0 else 1] == 1) {
                    if(instructions[i].offset < 0) {
                        i -= @intCast(instructions[i].offset * -1);
                    } else {
                        i += @intCast(instructions[i].offset);
                    }
                    continue;
               }
            },
            .jie => {
                if(registers[if(instructions[i].register == 'a') 0 else 1] & 1 == 0) {
                    if(instructions[i].offset < 0) {
                        i -= @intCast(instructions[i].offset * -1);
                    } else {
                        i += @intCast(instructions[i].offset);
                    }
                    continue;
                }
            },
            .jmp => {
                if(instructions[i].offset < 0) {
                    i -= @intCast(instructions[i].offset * -1);
                } else {
                    i += @intCast(instructions[i].offset);
                }
                continue;
            },
            .inc => {
                if(instructions[i].register == 'a') {
                    registers[0] += 1;
                } else {
                    registers[1] += 1;
                }
            },
            .tpl => {
                if(instructions[i].register == 'a') {
                    registers[0] *= 3;
                } else {
                    registers[1] *= 3;
                }
            },
            .hlf => {
                if(instructions[i].register == 'a') {
                    registers[0] /= 2;
                } else {
                    registers[1] /= 2;
                }
            },
        }
        i += 1;
    }
}

pub fn main() !void {

    var instructions = [_]Instruction{Instruction{.register= 0, .opCode = InstOpCode.jmp, .offset=0}} ** 50;
    var len : usize = 0;
    var iter = std.mem.tokenizeScalar(u8, file, '\n');
    while(iter.next()) |line| {
        var words = std.mem.tokenizeScalar(u8, line, ' ');
        const instruc_string = words.next().?;
        const op = for__ : for([_][]const u8 { "jio", "jie", "jmp", "inc", "tpl", "hlf" }, 0.. ) |inst, i| {
            if (std.mem.eql(u8, inst, instruc_string)) {
                break : for__ i;
            }
        } else 0;
        const register = words.next().?; //is it's the jmp instruction, this will be the offset
        const instruction = inst__ : {
            const code : InstOpCode = @enumFromInt(op);
            if(op == @intFromEnum(InstOpCode.jio) or op == @intFromEnum(InstOpCode.jie)) {
                const offset = try std.fmt.parseInt(isize, words.next().?, 10);
                break : inst__ Instruction{ .opCode = code, .register = register[0], .offset = offset };
            } else {
                break : inst__
                    if(code != InstOpCode.jmp)
                        Instruction{ .opCode = code, .register = register[0], .offset = 0 }
                    else
                        Instruction{ .opCode = code, .register = 0, .offset = try std.fmt.parseInt(isize, register, 10) };
            }
        };
        instructions[len] = instruction;
        len += 1;
    }
    var registers = [_]usize{ 0, 0 };
    executeCode(&instructions, len, &registers);
    print("Part 1: {}\n", .{ registers[1] });
    registers[0] = 1;
    registers[1] = 0;
    executeCode(&instructions, len, &registers);
    print("Part 2: {}\n", .{ registers[1] });
}
